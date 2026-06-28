<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> dde3525 (Initial project upload)
# Rydo 🚖

A complete, production-grade **ride-booking application** built with **Flutter** (Android, Windows, Web/Chrome) and a **Node.js + Express + MongoDB** backend, with real-time driver tracking over **Socket.IO** and an optional **Voice Navigation** mode for visually impaired users.

This project is based on the Rydo UI design and extends it with a modern, premium look, clean architecture, secure authentication, and an accessibility-first voice mode.

---

## ✨ Features

- **Authentication** — sign up, sign in, forgot/reset password, JWT access + refresh tokens, bcrypt password hashing.
- **Home dashboard** — live OpenStreetMap map, nearby drivers, "where to?" search, Home/Work shortcuts.
- **Booking flow** — destination search (OSM Nominatim geocoding), fare estimation across 4 ride tiers (Economy, Comfort, Premium, Van), payment selection, ride confirmation.
- **Real-time tracking** — Socket.IO streams the driver from pickup → destination; the map animates the car and the ETA updates live.
- **Trip lifecycle** — accept → arriving → in progress → completed, with rating and trip history.
- **Payments (mock/sandbox)** — add/manage cards, default card, cash option, wallet with top-ups and a transaction ledger. *No real charges are processed.*
- **Profile & settings** — edit profile, dark mode, and the Voice Navigation controls.
- **♿ Voice Navigation** — on first launch the app asks (and speaks the question aloud) whether to enable text-to-speech guidance. When on, every screen and ride update is read aloud. Toggle and adjust speech rate anytime in **Settings**.

### 🤖 AI features
- **AI Ride Assistant (LLM / OpenAI)** — book rides by typing or speaking natural language ("book a comfort ride to the airport at 6pm"); intent is extracted and the booking is pre-filled. Works offline via a rule-based fallback.
- **Fare / ETA / surge prediction (scikit-learn)** — a FastAPI ML microservice predicts fare, ETA and surge; shown live on the Choose-a-ride screen.
- **Review sentiment analysis (NLP)** — ride reviews are classified positive/neutral/negative with a score.

See `docs/AI_FEATURES.md` for details.

### 🛡️ Safety & security
- **Fraud-risk scoring** — every ride gets a simple, explainable risk score + flags (long trips, fare anomalies, rapid repeats, cancellations).
- **SOS / share trip** — safety menu on the tracking screen to share live trip details and alert an emergency contact.
- **Core security** — JWT + refresh tokens, bcrypt, input validation, helmet, CORS, rate limiting, card-data minimization.

See `docs/SAFETY.md` for details.

---

## 🏗️ Tech stack

| Layer | Technology |
|------|------------|
| Frontend | Flutter 3.27+, Provider (state), flutter_map + OpenStreetMap, flutter_tts, socket_io_client, http, secure storage |
| Backend | Node.js, Express, MongoDB (Mongoose), Socket.IO, JWT, bcryptjs, helmet, express-validator |
| Realtime | Socket.IO (driver location streaming) |
| Maps | OpenStreetMap tiles (no API key required) |
| AI (GenAI) | OpenAI (chat) for the ride assistant + review sentiment, with rule-based fallbacks |
| AI (ML) | Python FastAPI + scikit-learn microservice for fare/ETA/surge prediction |

---

## 🚀 Quick start

### 1. Backend

```bash
cd backend
cp .env.example .env          # adjust MONGO_URI / JWT_SECRET if needed
npm install
npm run seed                  # creates demo drivers + a demo rider account
npm run dev                   # starts API on http://localhost:5000
```

Demo login created by the seed:
- **Email:** `rider@rydo.app`
- **Password:** `password123`

You need a running MongoDB. Either install it locally (`mongodb://127.0.0.1:27017/rydo`) or point `MONGO_URI` at MongoDB Atlas.

> **Optional — enable the GPT path:** set `OPENAI_API_KEY` in `backend/.env`. Without it, the assistant + sentiment use built-in fallbacks and still work.

### 1b. ML microservice (fare/ETA prediction)

```bash
cd ml-service
pip install -r requirements.txt
uvicorn app:app --port 8000     # auto-trains the model on first run
```

The Node backend talks to it via `ML_SERVICE_URL`. If it's not running, the backend falls back to a rule-based estimate.

### 2. Frontend

```bash
cd frontend
flutter create . --platforms=android,web,windows   # generates platform runners (one time)
flutter pub get
```

Run it:

```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run -d <device>    # Android emulator / device
```

> **API base URL:** auto-detected — `10.0.2.2:5000` on the Android emulator, `localhost:5000` on Web/Windows. To target another host:
> ```bash
> flutter run --dart-define=API_BASE=http://192.168.1.50:5000
> ```

See `docs/` for the full API reference, architecture overview, and the Voice Navigation deep dive.

---

## 📁 Project structure

```
rydo/
├── backend/            # Node.js + Express + MongoDB + Socket.IO API
│   └── src/
│       ├── config/     # env + db connection
│       ├── models/     # Mongoose schemas
│       ├── controllers/# request handlers
│       ├── routes/     # REST routes
│       ├── middleware/ # auth, validation, error handling
│       ├── services/   # fare pricing engine
│       ├── sockets/    # real-time tracking
│       └── utils/      # tokens, geo, helpers
├── ml-service/         # Python FastAPI + scikit-learn (fare/ETA/surge prediction)
│   ├── app.py          # FastAPI server
│   ├── train.py        # model training + evaluation
│   └── data_gen.py     # synthetic dataset generator
├── frontend/           # Flutter app (clean architecture)
│   └── lib/
│       ├── core/       # theme, router, constants, utils
│       ├── models/     # data models
│       ├── services/   # api, auth, ride, socket, tts, location...
│       ├── providers/  # state management (Provider)
│       ├── screens/    # all UI screens by feature
│       ├── widgets/    # generic reusable widgets
│       └── components/ # domain UI components
└── docs/               # API, architecture, voice navigation docs
```

---

## ⚠️ Scope & disclaimers

This is a fully functional, well-architected foundation with real (non-placeholder) logic throughout. Before shipping to real users you should still: add real payment processing, harden security/secrets, add automated tests + CI, configure store signing, and do device QA. Payments are **mock/sandbox only** — no money moves.

License: MIT.
<<<<<<< HEAD
=======
# ride_ai_booking_rydo
>>>>>>> 61652a3bc616bb60b804bfe203b508a5b282b4c1
=======
>>>>>>> dde3525 (Initial project upload)
