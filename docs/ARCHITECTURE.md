# Architecture Overview

## High-level

```
┌──────────────────────────────┐        REST (JSON) + JWT        ┌─────────────────────────────┐
│        Flutter app           │ ──────────────────────────────▶ │      Express REST API        │
│  (Android / Windows / Web)   │ ◀────────────────────────────── │                              │
│                              │                                  │   Controllers → Services     │
│  Screen → Provider → Service │        Socket.IO (realtime)      │   → Mongoose Models          │
│        → ApiClient           │ ◀──────────────────────────────▶ │   Sockets: tracking.js       │
└──────────────────────────────┘                                  └──────────────┬──────────────┘
                                                                                  │
                                                                          ┌───────▼───────┐
                                                                          │    MongoDB    │
                                                                          └───────────────┘
```

## Frontend layers

1. **core** — framework-level concerns: colors, themes, routing table, constants, validators, formatters. No business logic.
2. **models** — immutable value objects with `fromJson` / `toJson`.
3. **services** — the only layer that performs I/O. `ApiClient` centralises HTTP, token injection, and automatic refresh-on-401. Other services (auth, ride, driver, card, transaction, geocoding, location, socket, tts) wrap a single concern.
4. **providers** — `ChangeNotifier`s holding UI state and orchestrating services. `SettingsProvider` owns Voice Navigation; `AuthProvider` owns the session; `RideProvider` owns the booking + live-tracking lifecycle; `PaymentProvider` owns cards + transactions.
5. **screens / widgets / components** — pure presentation. Screens read providers via `context.watch` and call provider methods on user actions.

## Backend layers

- **routes** declare endpoints + validation, delegate to **controllers**.
- **controllers** are thin: parse request, call **services/models**, shape response. Errors thrown as `ApiError` are caught by the central error middleware.
- **models** are Mongoose schemas with instance helpers (e.g. `User.comparePassword`, `User.toSafeJSON`).
- **services/fareService** is the pricing engine (base + per-km + per-min × tier multiplier).
- **sockets/tracking** simulates/streams the driver position along the route, advancing the ride status as it goes.

## Real-time ride flow

1. App `POST /rides` → backend assigns nearest available driver, computes fare + route, returns the ride.
2. App opens the tracking screen and emits `ride:subscribe`.
3. Backend streams `driver:location` every second: phase `arriving` (driver → pickup), then `in_progress` (pickup → dropoff), updating ride status in the DB and emitting `ride:status`.
4. On arrival the app marks the ride `completed`, which records a transaction.

## Why these choices

- **Provider** — simple, idiomatic, low-ceremony state management that scales well for an app this size.
- **flutter_map + OpenStreetMap** — zero-config, no API key, works identically on all three target platforms.
- **Socket.IO** — battle-tested realtime with automatic reconnection and room support (`ride:<id>`).
- **JWT + refresh tokens** — stateless auth with rev-ocable long-lived sessions.
