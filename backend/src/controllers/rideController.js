const Ride = require('../models/Ride');
const Driver = require('../models/Driver');
const Transaction = require('../models/Transaction');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');
const fareService = require('../services/fareService');
const fraudService = require('../services/fraudService');
const { interpolateRoute, distanceKm } = require('../utils/geo');

// POST /api/rides/estimate  -> fares for every ride type
exports.estimate = asyncHandler(async (req, res) => {
  const { pickup, dropoff } = req.body;
  if (!pickup || !dropoff) throw new ApiError(400, 'pickup and dropoff are required');
  const options = fareService.estimateAll(pickup, dropoff);
  res.json({ success: true, options });
});

// POST /api/rides  -> create a ride request and auto-assign nearest driver
exports.createRide = asyncHandler(async (req, res) => {
  const { pickup, dropoff, rideType = 'economy', paymentMethod = 'card' } = req.body;
  if (!pickup || !dropoff) throw new ApiError(400, 'pickup and dropoff are required');

  const { distanceKm: dist, durationMin, fare } = fareService.estimate(pickup, dropoff, rideType);
  const route = interpolateRoute(pickup, dropoff, 40);

  // Simple, explainable fraud/anomaly risk scoring.
  const recentRides = await Ride.find({ user: req.user._id }).sort({ createdAt: -1 }).limit(10);
  const risk = fraudService.assess({ distanceKm: dist, fare }, recentRides);

  // Find nearest available driver of the requested tier (fallback to any).
  let driver = await Driver.findOne({ isOnline: true, isAvailable: true, 'car.type': rideType });
  if (!driver) driver = await Driver.findOne({ isOnline: true, isAvailable: true });

  const ride = await Ride.create({
    user: req.user._id,
    driver: driver ? driver._id : null,
    pickup,
    dropoff,
    rideType,
    paymentMethod,
    distanceKm: dist,
    durationMin,
    fare,
    route,
    status: driver ? 'accepted' : 'requested',
    riskScore: risk.score,
    riskLevel: risk.level,
    riskFlags: risk.flags,
  });

  if (driver) {
    driver.isAvailable = false;
    await driver.save();
  }

  const populated = await ride.populate('driver');
  res.status(201).json({ success: true, ride: populated });
});

// GET /api/rides  -> ride history for current user
exports.myRides = asyncHandler(async (req, res) => {
  const rides = await Ride.find({ user: req.user._id })
    .populate('driver')
    .sort({ createdAt: -1 });
  res.json({ success: true, rides });
});

// GET /api/rides/active -> current ongoing ride if any
exports.activeRide = asyncHandler(async (req, res) => {
  const ride = await Ride.findOne({
    user: req.user._id,
    status: { $in: ['requested', 'accepted', 'arriving', 'in_progress'] },
  })
    .populate('driver')
    .sort({ createdAt: -1 });
  res.json({ success: true, ride });
});

// GET /api/rides/:id
exports.getRide = asyncHandler(async (req, res) => {
  const ride = await Ride.findOne({ _id: req.params.id, user: req.user._id }).populate('driver');
  if (!ride) throw new ApiError(404, 'Ride not found');
  res.json({ success: true, ride });
});

// PATCH /api/rides/:id/status
exports.updateStatus = asyncHandler(async (req, res) => {
  const { status } = req.body;
  const allowed = ['arriving', 'in_progress', 'completed', 'cancelled'];
  if (!allowed.includes(status)) throw new ApiError(400, 'Invalid status');

  const ride = await Ride.findOne({ _id: req.params.id, user: req.user._id });
  if (!ride) throw new ApiError(404, 'Ride not found');

  ride.status = status;
  if (status === 'completed') {
    ride.completedAt = new Date();
    ride.paymentStatus = ride.paymentMethod === 'cash' ? 'pending' : 'paid';
    await Transaction.create({
      user: ride.user,
      ride: ride._id,
      type: 'ride_payment',
      amount: ride.fare,
      method: ride.paymentMethod,
      status: 'success',
      description: `Ride ${ride._id}`,
      reference: `TXN-${Date.now()}`,
    });
  }
  if (status === 'completed' || status === 'cancelled') {
    if (ride.driver) {
      const driver = await Driver.findById(ride.driver);
      if (driver) {
        driver.isAvailable = true;
        if (status === 'completed') driver.totalTrips += 1;
        await driver.save();
      }
    }
  }
  await ride.save();
  res.json({ success: true, ride: await ride.populate('driver') });
});

// POST /api/rides/:id/rate
exports.rateRide = asyncHandler(async (req, res) => {
  const { rating } = req.body;
  const ride = await Ride.findOne({ _id: req.params.id, user: req.user._id });
  if (!ride) throw new ApiError(404, 'Ride not found');
  ride.rating = Math.max(1, Math.min(5, Number(rating)));
  await ride.save();
  res.json({ success: true, ride });
});
