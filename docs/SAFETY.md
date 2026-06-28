# Safety & Fraud (lightweight)

Kept intentionally simple and explainable — not a heavy black-box system.

## Fraud / anomaly risk scoring
- On every ride request the backend (`services/fraudService.js`) computes a **0–100 risk score**, a **level** (low/medium/high), and the **flags** that triggered it.
- Signals: unusually long trips, fares far above the expected band, rapid repeat bookings (velocity), high recent cancellation rate, and high-value trips at odd hours.
- Stored on the `Ride` (`riskScore`, `riskLevel`, `riskFlags`) and returned in the ride payload, so it can drive review/blocking later.

## Rider safety
- **SOS button** on the live tracking screen opens a safety menu.
- **Share trip details** copies the live trip (driver, car, plate, route, fare) to share with someone.
- **Emergency contact** (set in Profile) for quick alerts; reminder to dial local emergency services.

## Existing security (already in the app)
- JWT access + refresh tokens, bcrypt password hashing, input validation, helmet headers, CORS allowlist, API rate limiting, and card data minimization (brand + last4 only).
