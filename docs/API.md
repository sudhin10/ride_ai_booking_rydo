# Rydo REST API Reference

Base URL: `http://localhost:5000/api`

All authenticated endpoints require: `Authorization: Bearer <accessToken>`.
Standard response envelope: `{ "success": true, ... }` or `{ "success": false, "message": "..." }`.

## Auth

| Method | Endpoint | Auth | Body | Description |
|-------|----------|------|------|-------------|
| POST | `/auth/register` | – | `name, email, password, phone` | Create account, returns tokens + user |
| POST | `/auth/login` | – | `email, password` | Returns `accessToken, refreshToken, user` |
| POST | `/auth/refresh` | – | `refreshToken` | New `accessToken` |
| POST | `/auth/logout` | ✓ | `refreshToken` | Revoke refresh token |
| GET | `/auth/me` | ✓ | – | Current user |
| POST | `/auth/forgot-password` | – | `email` | Sends reset code (demo code: `123456`) |
| POST | `/auth/reset-password` | – | `email, code, newPassword` | Reset password |

## Users

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| PATCH | `/users/profile` | `name, phone, avatarUrl, homeAddress, workAddress` | Update profile |
| PATCH | `/users/preferences` | `voiceNavigationEnabled, voiceNavigationPrompted, ttsSpeechRate` | Sync accessibility prefs |
| PATCH | `/users/password` | `currentPassword, newPassword` | Change password |
| POST | `/users/wallet/topup` | `amount` | Top up wallet balance |

## Drivers

| Method | Endpoint | Query | Description |
|-------|----------|-------|-------------|
| GET | `/drivers/nearby` | `lat, lng` | Available drivers sorted by distance |
| GET | `/drivers/:id` | – | Driver details |

## Rides

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| POST | `/rides/estimate` | `pickup, dropoff` | Fares for all 4 ride types |
| POST | `/rides` | `pickup, dropoff, rideType, paymentMethod` | Create ride, auto-assigns nearest driver |
| GET | `/rides` | – | Ride history |
| GET | `/rides/active` | – | Current active ride (or null) |
| GET | `/rides/:id` | – | Single ride |
| PATCH | `/rides/:id/status` | `status` (`arriving\|in_progress\|completed\|cancelled`) | Update lifecycle; `completed` creates a transaction |
| POST | `/rides/:id/rate` | `rating` (1–5) | Rate the trip |

`pickup` / `dropoff` shape: `{ "address": string, "lat": number, "lng": number }`

## Cards (mock/sandbox)

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| GET | `/cards` | – | List saved cards |
| POST | `/cards` | `holderName, number, expMonth, expYear` | Add card (stores only brand + last4) |
| PATCH | `/cards/:id/default` | – | Set default |
| DELETE | `/cards/:id` | – | Remove card |

## Transactions

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/transactions` | Wallet + ride payment ledger |

## Health

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/health` | `{ success, status: "ok", time }` |

## Socket.IO events

Connect to the server origin (e.g. `http://localhost:5000`).

| Direction | Event | Payload |
|-----------|-------|---------|
| client → server | `ride:subscribe` | `{ rideId }` |
| client → server | `ride:unsubscribe` | `{ rideId }` |
| client → server | `driver:location` | `{ rideId, lat, lng }` (for real driver clients) |
| server → client | `ride:status` | `{ rideId, status }` |
| server → client | `driver:location` | `{ rideId, lat, lng, index, total, phase, eta, ts }` |

## AI

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| POST | `/ai/assistant` | `message` | LLM ride assistant; returns `{ result: {reply,intent,pickup,dropoff,rideType,when,source}, aiEnabled }` |
| POST | `/ai/predict-fare` | `distanceKm, rideType, demandLevel?, hour?, dayOfWeek?` | ML fare/ETA/surge prediction |

## Reviews (AI sentiment)

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| POST | `/reviews` | `text, rideId?, driverId?, rating?` | Create review; backend attaches `sentiment {label,score,summary,source}` |
| GET | `/reviews` | – | User's reviews |
| GET | `/reviews/insights` | – | Aggregate sentiment breakdown |

## ML microservice (separate, port 8000)

| Method | Endpoint | Body | Description |
|-------|----------|------|-------------|
| GET | `/health` | – | status + model metrics (MAE/R²) |
| POST | `/predict` | `distanceKm, hour, dayOfWeek, rideType, demandLevel` | `predictedFare, predictedEtaMin, surgeMultiplier` |
