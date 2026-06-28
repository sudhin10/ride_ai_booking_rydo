import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'settings_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final SettingsProvider settings;

  AuthProvider({required this.settings});

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool loading = false;
  String? error;

  Future<void> bootstrap() async {
    try {
      user = await _auth.currentUser();
      status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      if (user != null) await _syncSettings();
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _syncSettings() async {
    if (user == null) return;
    await settings.applyFromUser(
      enabled: user!.voiceNavigationEnabled,
      prompted: user!.voiceNavigationPrompted,
      rate: user!.ttsSpeechRate,
    );
  }

  Future<bool> login(String email, String password) =>
      _run(() => _auth.login(email, password));

  Future<bool> register(String name, String email, String password, String phone) =>
      _run(() => _auth.register(name, email, password, phone));

  Future<bool> _run(Future<UserModel> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await action();
      status = AuthStatus.authenticated;
      await _syncSettings();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    user = await _auth.updateProfile(data);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    user = await _auth.currentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
