# Rydo Frontend (Flutter)

Requires Flutter 3.27+. Cross-platform Flutter app — **Android, Windows, Web (Chrome)**.

## Setup

```bash
# One-time: generate native platform runners for this machine
flutter create . --platforms=android,web,windows

flutter pub get
```

## Run

```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d <device>    # Android
```

Point at a custom backend host:

```bash
flutter run --dart-define=API_BASE=http://192.168.1.50:5000
```

## Architecture (clean / layered)

```
lib/
├── core/        constants, theme, router, utils  (no business logic)
├── models/      immutable data models + JSON (de)serialization
├── services/    I/O boundary: REST (api_client), auth, ride, driver,
│                card, transaction, socket, tts, location, geocoding
├── providers/   ChangeNotifier state: auth, ride, payment, settings
├── screens/     UI by feature: onboarding, auth, home, booking,
│                payment, profile, history, settings
├── widgets/     generic reusable widgets (buttons, fields, overlays)
└── components/  domain UI (map, ride card, driver card, tiles)
```

State flows **Screen → Provider → Service → ApiClient → Backend**. Screens never call services directly except for read-only fetches (e.g. history).

## Permissions (after `flutter create .`)

- **Android** — add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  ```
  TTS uses the platform engine (no permission). The AI assistant's voice input uses `speech_to_text` (needs `RECORD_AUDIO`); typed input always works if the mic is unavailable.
- **Web / Windows** — no manifest changes required. The browser will prompt for location; the app falls back to the demo city centre if denied.

## Notes

- Maps use **OpenStreetMap** tiles — no API key required.
- Location gracefully falls back to San Francisco (matching seeded drivers) when GPS is unavailable.
- Voice Navigation uses `flutter_tts` and works on all three platforms.
