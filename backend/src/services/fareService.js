const { distanceKm } = require('../utils/geo');

// Pricing model per ride type. Mock currency units.
const PRICING = {
  economy: { base: 2.5, perKm: 1.0, perMin: 0.2, multiplier: 1.0 },
  comfort: { base: 3.5, perKm: 1.4, perMin: 0.3, multiplier: 1.15 },
  premium: { base: 5.0, perKm: 2.0, perMin: 0.45, multiplier: 1.4 },
  van: { base: 4.5, perKm: 1.8, perMin: 0.4, multiplier: 1.3 },
};

const AVG_SPEED_KMH = 32;

function estimate(pickup, dropoff, rideType = 'economy') {
  const p = PRICING[rideType] || PRICING.economy;
  const km = Math.max(0.1, distanceKm(pickup, dropoff));
  const durationMin = Math.max(1, Math.round((km / AVG_SPEED_KMH) * 60));
  const raw = (p.base + km * p.perKm + durationMin * p.perMin) * p.multiplier;
  const fare = Math.round(raw * 100) / 100;
  return { distanceKm: Math.round(km * 100) / 100, durationMin, fare };
}

function estimateAll(pickup, dropoff) {
  return Object.keys(PRICING).map((type) => ({ rideType: type, ...estimate(pickup, dropoff, type) }));
}

module.exports = { estimate, estimateAll, PRICING };
