/**
 * Lightweight fraud / anomaly risk scorer for a ride request.
 * Deliberately simple and explainable (a few clear signals) rather than a heavy
 * black-box model — easy to reason about and demo. Returns a 0–100 risk score,
 * a level, and the human-readable flags that contributed.
 */
function assess(ride, recentRides = []) {
  const flags = [];
  let score = 0;

  // 1. Unusually long trip
  if (ride.distanceKm > 60) {
    score += 30;
    flags.push('Unusually long trip distance');
  }

  // 2. Fare far outside the expected band for the distance
  const expected = 2.5 + ride.distanceKm * 1.4;
  if (ride.fare > expected * 2.2) {
    score += 25;
    flags.push('Fare significantly higher than expected');
  }

  // 3. Rapid repeat bookings (velocity) — many rides in a short window
  const fiveMinAgo = Date.now() - 5 * 60 * 1000;
  const recentCount = recentRides.filter((r) => new Date(r.createdAt).getTime() > fiveMinAgo).length;
  if (recentCount >= 3) {
    score += 25;
    flags.push('Multiple ride requests in a short period');
  }

  // 4. High recent cancellation rate
  const last10 = recentRides.slice(0, 10);
  const cancels = last10.filter((r) => r.status === 'cancelled').length;
  if (last10.length >= 4 && cancels / last10.length > 0.6) {
    score += 15;
    flags.push('High recent cancellation rate');
  }

  // 5. Odd-hour, high-value trip
  const hour = new Date().getHours();
  if ((hour >= 1 && hour <= 4) && ride.fare > 40) {
    score += 15;
    flags.push('High-value trip at an unusual hour');
  }

  score = Math.min(100, score);
  const level = score >= 60 ? 'high' : score >= 30 ? 'medium' : 'low';
  return { score, level, flags };
}

module.exports = { assess };
