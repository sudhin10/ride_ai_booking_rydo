// Haversine distance in kilometres between two [lat, lng] points.
function distanceKm(a, b) {
  const R = 6371;
  const toRad = (d) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h = Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * R * Math.asin(Math.sqrt(h));
}

// Linear interpolation of N points along the straight line between pickup and dropoff.
// Good enough to simulate/stream a moving car when no routing engine is configured.
function interpolateRoute(pickup, dropoff, steps = 30) {
  const pts = [];
  for (let i = 0; i <= steps; i += 1) {
    const t = i / steps;
    pts.push([
      pickup.lat + (dropoff.lat - pickup.lat) * t,
      pickup.lng + (dropoff.lng - pickup.lng) * t,
    ]);
  }
  return pts;
}

module.exports = { distanceKm, interpolateRoute };
