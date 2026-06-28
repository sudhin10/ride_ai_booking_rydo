# Rydo Backend

Node.js + Express + MongoDB + Socket.IO REST API for the Rydo app.

## Setup

```bash
cp .env.example .env
npm install
npm run seed     # demo drivers + demo rider (rider@rydo.app / password123)
npm run dev      # nodemon, http://localhost:5000
# or: npm start
```

Requires MongoDB (local `mongodb://127.0.0.1:27017/rydo` or Atlas via `MONGO_URI`).

## Environment variables (`.env`)

| Key | Description |
|-----|-------------|
| `PORT` | API port (default 5000) |
| `MONGO_URI` | MongoDB connection string |
| `JWT_SECRET` / `JWT_EXPIRES_IN` | access token signing |
| `REFRESH_TOKEN_SECRET` / `REFRESH_TOKEN_EXPIRES_IN` | refresh token signing |
| `CORS_ORIGINS` | comma-separated allowlist, or `*` |

## Security

- Passwords hashed with **bcryptjs**.
- **JWT** access tokens (short-lived) + rotating **refresh tokens** stored per-user.
- **helmet**, **CORS**, **rate limiting** (600 req / 15 min on `/api`), and **express-validator** input validation.

## Real-time tracking (Socket.IO)

Client emits `ride:subscribe { rideId }`. The server then streams:
- `ride:status` — `arriving` → `in_progress` → `arrived_destination`
- `driver:location` — `{ lat, lng, index, total, phase, eta }` every second

See `../docs/API.md` for the full REST reference.
