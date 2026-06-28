const axios = require('axios');
const env = require('../config/env');
const fareService = require('./fareService');

/**
 * Proxies fare/ETA/surge prediction to the Python ML microservice.
 * If the service is unreachable, falls back to the deterministic fare engine so
 * the app keeps working.
 */
async function predict({ distanceKm, hour, dayOfWeek, rideType = 'economy', demandLevel = 0.5 }) {
  try {
    const { data } = await axios.post(
      `${env.mlServiceUrl}/predict`,
      { distanceKm, hour, dayOfWeek, rideType, demandLevel },
      { timeout: 4000 }
    );
    return { ...data, source: 'ml-model' };
  } catch (e) {
    // eslint-disable-next-line no-console
    console.warn('[prediction] ML service unavailable, using rule-based fallback:', e.message);
    const base = fareService.PRICING[rideType] || fareService.PRICING.economy;
    const surge = 1 + Math.max(0, demandLevel - 0.5);
    const predictedFare =
      Math.round((base.base + distanceKm * base.perKm) * base.multiplier * surge * 100) / 100;
    const predictedEtaMin = Math.max(1, Math.round((distanceKm / 32) * 60 * (0.8 + demandLevel * 0.6)));
    return {
      predictedFare,
      predictedEtaMin,
      surgeMultiplier: Number(surge.toFixed(2)),
      source: 'fallback',
    };
  }
}

module.exports = { predict };
