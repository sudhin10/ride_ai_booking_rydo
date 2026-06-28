import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Wraps secure storage (tokens) and shared preferences (settings/flags).
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---- tokens ----
  Future<void> saveTokens(String access, String refresh) async {
    await _secure.write(key: AppConstants.kAccessToken, value: access);
    await _secure.write(key: AppConstants.kRefreshToken, value: refresh);
  }

  Future<String?> get accessToken => _secure.read(key: AppConstants.kAccessToken);
  Future<String?> get refreshToken => _secure.read(key: AppConstants.kRefreshToken);

  Future<void> setAccessToken(String token) =>
      _secure.write(key: AppConstants.kAccessToken, value: token);

  Future<void> clearTokens() async {
    await _secure.delete(key: AppConstants.kAccessToken);
    await _secure.delete(key: AppConstants.kRefreshToken);
  }

  // ---- prefs ----
  bool getBool(String key, {bool fallback = false}) => _prefs?.getBool(key) ?? fallback;
  Future<void> setBool(String key, bool value) async => _prefs?.setBool(key, value);
  double getDouble(String key, {double fallback = 0.5}) => _prefs?.getDouble(key) ?? fallback;
  Future<void> setDouble(String key, double value) async => _prefs?.setDouble(key, value);
  String? getString(String key) => _prefs?.getString(key);
  Future<void> setString(String key, String value) async => _prefs?.setString(key, value);
}
