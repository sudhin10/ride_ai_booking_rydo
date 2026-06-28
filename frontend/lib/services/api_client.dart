import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

/// Thin HTTP wrapper: injects the bearer token, decodes JSON, and
/// transparently retries once after refreshing an expired access token.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = StorageService.instance;
  final Duration _timeout = const Duration(seconds: 20);

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.accessToken;
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Uri _uri(String path) => Uri.parse('${ApiEndpoints.baseUrl}$path');

  Future<dynamic> get(String path, {bool auth = true}) =>
      _send(() async => http.get(_uri(path), headers: await _headers(auth: auth)), path, auth);

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send(() async => http.post(_uri(path),
          headers: await _headers(auth: auth), body: jsonEncode(body ?? {})), path, auth);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send(() async => http.patch(_uri(path),
          headers: await _headers(auth: auth), body: jsonEncode(body ?? {})), path, auth);

  Future<dynamic> delete(String path, {bool auth = true}) =>
      _send(() async => http.delete(_uri(path), headers: await _headers(auth: auth)), path, auth);

  Future<dynamic> _send(Future<http.Response> Function() request, String path, bool auth,
      {bool retried = false}) async {
    http.Response res;
    try {
      res = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(408, 'Request timed out. Check your connection.');
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (res.statusCode == 401 && auth && !retried) {
      final refreshed = await _tryRefresh();
      if (refreshed) return _send(request, path, auth, retried: true);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final msg = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Request failed (${res.statusCode})';
    throw ApiException(res.statusCode, msg);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.refreshToken;
    if (refresh == null) return false;
    try {
      final res = await http
          .post(_uri(ApiEndpoints.refresh),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': refresh}))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _storage.setAccessToken(data['accessToken']);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
