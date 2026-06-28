#!/usr/bin/env bash
# Rydo — one-terminal launcher (macOS / Linux).
# Runs the backend + ML service in the background, Flutter in the foreground.
# Stop everything with Ctrl+C.
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Make sure background services are killed when this script exits.
cleanup() { echo "\nStopping Rydo services..."; kill 0; }
trap cleanup EXIT INT TERM

echo "==> Starting backend (http://localhost:5000)"
( cd "$ROOT/backend" && npm install && npm run seed && npm run dev ) &

echo "==> Starting ML service (http://localhost:8000) [optional]"
( cd "$ROOT/ml-service" && pip install -r requirements.txt -q && uvicorn app:app --port 8000 ) &

# Give the backend a moment to boot.
sleep 6

echo "==> Launching Flutter app (Chrome)"
cd "$ROOT/frontend"
flutter pub get
# One-time platform scaffolding (safe to re-run; skips if present)
flutter create . --platforms=android,web,windows >/dev/null 2>&1 || true
flutter run -d chrome
