import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/auth_service.dart';

/// Owns app-wide preferences: theme, first-launch flag and the Voice Navigation
/// (TTS) accessibility settings. Persists locally and syncs to the backend when
/// the user is authenticated.
class SettingsProvider extends ChangeNotifier {
  final _storage = StorageService.instance;
  final _tts = TtsService.instance;
  final _auth = AuthService();

  bool _voiceEnabled = false;
  bool _voicePrompted = false;
  double _speechRate = 0.5;
  ThemeMode _themeMode = ThemeMode.light;

  bool get voiceEnabled => _voiceEnabled;
  bool get voicePrompted => _voicePrompted;
  double get speechRate => _speechRate;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    _voiceEnabled = _storage.getBool(AppConstants.kVoiceEnabled);
    _voicePrompted = _storage.getBool(AppConstants.kVoicePrompted);
    _speechRate = _storage.getDouble(AppConstants.kSpeechRate, fallback: 0.5);
    final theme = _storage.getString(AppConstants.kThemeMode);
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    await _tts.init(enabled: _voiceEnabled, rate: _speechRate);
    notifyListeners();
  }

  bool get isFirstLaunch => !_storage.getBool(AppConstants.kFirstLaunch, fallback: false);

  Future<void> completeFirstLaunch() async {
    await _storage.setBool(AppConstants.kFirstLaunch, true);
  }

  /// Called from the first-launch voice prompt and the Settings toggle.
  Future<void> setVoiceEnabled(bool value, {bool sync = true}) async {
    _voiceEnabled = value;
    _voicePrompted = true;
    await _storage.setBool(AppConstants.kVoiceEnabled, value);
    await _storage.setBool(AppConstants.kVoicePrompted, true);
    await _tts.setEnabled(value);
    notifyListeners();
    if (value) {
      await _tts.announce('Voice navigation enabled. I will guide you through the app.',
          interrupt: true, force: true);
    }
    if (sync) {
      try {
        await _auth.updatePreferences(
            {'voiceNavigationEnabled': value, 'voiceNavigationPrompted': true});
      } catch (_) {/* offline-tolerant */}
    }
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value;
    await _storage.setDouble(AppConstants.kSpeechRate, value);
    await _tts.setRate(value);
    notifyListeners();
    try {
      await _auth.updatePreferences({'ttsSpeechRate': value});
    } catch (_) {}
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    await _storage.setString(AppConstants.kThemeMode, dark ? 'dark' : 'light');
    notifyListeners();
  }

  /// Convenience used across screens to speak only when voice mode is on.
  void speak(String message, {bool interrupt = false}) {
    if (_voiceEnabled) _tts.announce(message, interrupt: interrupt);
  }

  /// Hydrate from a server-side user record after login.
  Future<void> applyFromUser(
      {required bool enabled, required bool prompted, required double rate}) async {
    _voiceEnabled = enabled;
    _voicePrompted = prompted;
    _speechRate = rate;
    await _storage.setBool(AppConstants.kVoiceEnabled, enabled);
    await _storage.setBool(AppConstants.kVoicePrompted, prompted);
    await _storage.setDouble(AppConstants.kSpeechRate, rate);
    await _tts.init(enabled: enabled, rate: rate);
    notifyListeners();
  }
}
