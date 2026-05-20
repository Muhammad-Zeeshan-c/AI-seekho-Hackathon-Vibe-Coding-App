import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Service to handle authentication and session state on KaamKaar.
class AuthService {
  static String? _token;

  /// Retrieves the active JWT token
  static String? get token => _token;

  /// Retrieves default headers with Bearer token if logged in
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Login client, provider, or admin
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }

    _token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await saveSession(user, _token!);
    return data;
  }

  /// Register client or provider
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    Map<String, dynamic>? extra,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      if (extra != null) ...extra,
    };

    final response = await http.post(
      Uri.parse('$kApiBaseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Registration failed');
    }

    _token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await saveSession(user, _token!);
    return data;
  }

  /// Persists session token and user profile details locally
  static Future<void> saveSession(UserModel user, String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kAuthTokenKey, token);
    await prefs.setString(kAuthUserKey, jsonEncode(user.toJson()));
  }

  /// Restores session from SharedPreferences on app startup
  static Future<Map<String, dynamic>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(kAuthTokenKey);
    final userJson = prefs.getString(kAuthUserKey);

    if (token == null || userJson == null) {
      return null;
    }

    _token = token;
    try {
      final user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return {
        'token': token,
        'user': user,
      };
    } catch (e) {
      await clearSession();
      return null;
    }
  }

  /// Clears session storage upon logout
  static Future<void> clearSession() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kAuthTokenKey);
    await prefs.remove(kAuthUserKey);
  }
}
