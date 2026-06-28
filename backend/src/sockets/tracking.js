const Ride = require('../models/Ride');
const Driver = require('../models/Driver');

// Holds active simulation intervals so we can cancel them on disconnect/complete.
const activeSimulations = new Map();

/**
 * Sets up Socket.IO real-time tracking.
 * Clients:
 *   emit 'ride:subscribe' { rideId }       -> server streams driver position
 *   emit 'ride:unsubscribe' { rideId }
 *   on  'driver:location' { rideId, lat, lng, index, total, eta, status }
 *   on  'ride:status' { rideId, status }
 */
function registerTracking(io) {
  io.on('connection', (socket) => {
    // eslint-disable-next-line no-console
    console.log(`[socket] connected ${socket.id}`);

    socket.on('ride:subscribe', async ({ rideId }) => {
      if (!rideId) return;
      socket.join(`ride:${rideId}`);
      try {
        await startSimulation(io, rideId);
      } catch (e) {
        socket.emit('ride:error', { message: e.message });
      }
    });

    socket.on('ride:unsubscribe', ({ rideId }) => {
      if (rideId) socket.leave(`ride:${rideId}`);
    });

    // Allow a driver client (or the app simulating one) to push real positions.
    socket.on('driver:location', ({ rideId, lat, lng }) => {
      if (!rideId) return;
      io.to(`ride:${rideId}`).emit('driver:location', { rideId, lat, lng, ts: Date.now() });
    });

    socket.on('disconnect', () => {
      // eslint-disable-next-line no-console
      console.log(`[socket] disconnected ${socket.id}`);
    });
  });
}

// Streams the driver moving: first toward the pickup, then along the route to dropoff.
async function startSimulation(io, rideId) {
  if (activeSimulations.has(rideId)) return;
  const ride = await Ride.findById(rideId).populate('driver');
  if (!ride) return;

  const room = `ride:${rideId}`;
  const driverStart = ride.driver
    ? { lat: ride.driver.location.coordinates[1], lng: ride.driver.location.coordinates[0] }
    : { lat: ride.pickup.lat + 0.01, lng: ride.pickup.lng + 0.01 };

  // Phase 1: driver -> pickup (arriving). Phase 2: pickup -> dropoff (in_progress).
  const toPickup = buildLeg(driverStart, ride.pickup, 20);
  const toDropoff = ride.route && ride.route.length ? ride.route : buildLeg(ride.pickup, ride.dropoff, 40);

  let phase = 'arriving';
  let path = toPickup;
  let i = 0;

  const tick = async () => {
    if (i >= path.length) {
      if (phase === 'arriving') {
        phase = 'in_progress';
        path = toDropoff;
        i = 0;
        await Ride.findByIdAndUpdate(rideId, { status: 'in_progress' });
        io.to(room).emit('ride:status', { rideId, status: 'in_progress' });
        return;
      }
      // Reached destination.
      clearInterval(activeSimulations.get(rideId));
      activeSimulations.delete(rideId);
      io.to(room).emit('ride:status', { rideId, status: 'arrived_destination' });
      return;
    }
    const [lat, lng] = path[i];
    const total = path.length;
    const remaining = total - i;
    const eta = Math.ceil((remaining / total) * (phase === 'arriving' ? ride.durationMin / 4 : ride.durationMin));
    io.to(room).emit('driver:location', {
      rideId,
      lat,
      lng,
      index: i,
      total,
      phase,
      eta,
      ts: Date.now(),
    });
    i += 1;
  };

  // Announce start, then begin streaming.
  io.to(room).emit('ride:status', { rideId, status: 'arriving' });
  await Ride.findByIdAndUpdate(rideId, { status: 'arriving' });
  const handle = setInterval(tick, 1000);
  activeSimulations.set(rideId, handle);
}

function buildLeg(a, b, steps) {
  const pts = [];
  for (let s = 0; s <= steps; s += 1) {
    const t = s / steps;
    pts.push([a.lat + (b.lat - a.lat) * t, a.lng + (b.lng - a.lng) * t]);
  }
  return pts;
}

module.exports = { registerTracking };
