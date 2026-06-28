# Voice Navigation (Accessibility)

Rydo includes an optional, accessibility-first **Voice Navigation** mode designed for visually impaired riders. When enabled, the app reads screens and ride updates aloud using the device's text-to-speech engine.

## First-launch prompt

On the very first launch, after the splash screen, the app shows the **Voice Navigation prompt** (`screens/onboarding/voice_prompt_screen.dart`). Crucially, the prompt **speaks itself aloud** regardless of the current setting, so a user who cannot see the screen still hears the choice and how to respond:

> "Welcome to Rydo. Would you like to enable voice navigation? This reads screens and ride updates aloud. Tap the top of the screen to enable, or the bottom to skip. You can change this anytime in Settings."

The large **Enable Voice Navigation** button sits at the top and **Not now** at the bottom, matching the spoken instructions. The choice is persisted so the prompt never appears again.

## Turning it on/off anytime

**Settings → Accessibility → Voice navigation** toggles the feature at any time. When on, an additional **Speech rate** slider (20%–100%) and a **Test voice** button appear.

## How it works

- `services/tts_service.dart` wraps `flutter_tts`. It is a singleton initialised at startup. All speech requests no-op silently when disabled, so screens can call `settings.speak(...)` unconditionally.
- `providers/settings_provider.dart` owns the enabled flag, the prompted flag, and the speech rate. It persists them locally (SharedPreferences) **and** syncs to the backend (`PATCH /users/preferences`) so the preference follows the user across devices.
- Every screen announces its purpose on entry (e.g. "Sign in screen. Please enter your email and password.") and key actions/state changes are spoken (ride confirmed, driver arriving, fare on completion, errors, etc.).
- Native semantics: buttons and ride-type cards are wrapped in `Semantics` so the platform screen reader (TalkBack / Narrator / browser AT) also works correctly alongside the in-app TTS.

## Settings persistence

| Where | What |
|-------|------|
| SharedPreferences | `voice_enabled`, `voice_prompted`, `speech_rate`, first-launch flag |
| Secure storage | auth tokens (not voice settings) |
| Backend (`User`) | `voiceNavigationEnabled`, `voiceNavigationPrompted`, `ttsSpeechRate` |

On login, the server-side preferences hydrate the local settings (`AuthProvider._syncSettings`), so a returning user's voice choice is restored automatically.
