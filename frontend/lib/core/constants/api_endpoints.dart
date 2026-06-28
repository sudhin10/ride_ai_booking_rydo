import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralised API configuration.
///
/// Base URL resolves automatically per platform:
///  - Android emulator -> 10.0.2.2 (host loopback)
///  - Web / Windows / iOS sim -> localhost
/// Override with --dart-define=API_BASE=http://your-host:5000
class ApiEndpoints {
  static const String _override = String.fromEnvironment('API_BASE', defaultValue: '');

  static String get host {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {/* Platform unavailable on web */}
    return 'http://localhost:5000';
  }

  static String get baseUrl => '$host/api';
  static String get socketUrl => host;

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String profile = '/users/profile';
  static const String preferences = '/users/preferences';
  static const String changePassword = '/users/password';
  static const String walletTopup = '/users/wallet/topup';

  // Rides
  static const String rides = '/rides';
  static const String rideEstimate = '/rides/estimate';
  static const String activeRide = '/rides/active';

  // Drivers
  static const String driversNearby = '/drivers/nearby';

  // AI
  static const String aiAssistant = '/ai/assistant';
  static const String aiPredictFare = '/ai/predict-fare';

  // Reviews
  static const String reviews = '/reviews';
  static const String reviewInsights = '/reviews/insights';

  // Cards & transactions
  static const String cards = '/cards';
  static const String transactions = '/transactions';
}
