class AppConstants {
  static const String appName = 'Rydo';
  static const String tagline = 'Book a ride in seconds';

  // Default map center (San Francisco) — matches seeded demo drivers.
  static const double defaultLat = 37.7749;
  static const double defaultLng = -122.4194;
  static const double defaultZoom = 14.0;

  // Shared-prefs keys
  static const String kFirstLaunch = 'first_launch';
  static const String kVoicePrompted = 'voice_prompted';
  static const String kVoiceEnabled = 'voice_enabled';
  static const String kSpeechRate = 'speech_rate';
  static const String kThemeMode = 'theme_mode';

  // Secure-storage keys
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
}
