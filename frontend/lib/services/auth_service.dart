import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final _api = ApiClient.instance;
  final _storage = StorageService.instance;

  Future<UserModel> register(String name, String email, String password, String phone) async {
    final res = await _api.post(ApiEndpoints.register,
        auth: false, body: {'name': name, 'email': email, 'password': password, 'phone': phone});
    await _storage.saveTokens(res['accessToken'], res['refreshToken']);
    return UserModel.fromJson(res['user']);
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _api
        .post(ApiEndpoints.login, auth: false, body: {'email': email, 'password': password});
    await _storage.saveTokens(res['accessToken'], res['refreshToken']);
    return UserModel.fromJson(res['user']);
  }

  Future<UserModel?> currentUser() async {
    final token = await _storage.accessToken;
    if (token == null) return null;
    final res = await _api.get(ApiEndpoints.me);
    return UserModel.fromJson(res['user']);
  }

  Future<void> logout() async {
    final refresh = await _storage.refreshToken;
    try {
      await _api.post(ApiEndpoints.logout, body: {'refreshToken': refresh});
    } catch (_) {}
    await _storage.clearTokens();
  }

  Future<String> forgotPassword(String email) async {
    final res = await _api.post(ApiEndpoints.forgotPassword, auth: false, body: {'email': email});
    return res['message'] ?? 'Reset code sent';
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    await _api.post(ApiEndpoints.resetPassword,
        auth: false, body: {'email': email, 'code': code, 'newPassword': newPassword});
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _api.patch(ApiEndpoints.profile, body: data);
    return UserModel.fromJson(res['user']);
  }

  Future<UserModel> updatePreferences(Map<String, dynamic> data) async {
    final res = await _api.patch(ApiEndpoints.preferences, body: data);
    return UserModel.fromJson(res['user']);
  }

  Future<void> changePassword(String current, String next) async {
    await _api.patch(ApiEndpoints.changePassword,
        body: {'currentPassword': current, 'newPassword': next});
  }
}
