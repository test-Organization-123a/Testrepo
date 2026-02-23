import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';

class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUser  = 'auth_user';

  static Future<void> saveAuth(AuthResult auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, auth.token);
    await prefs.setString(_kUser, jsonEncode(auth.user.toJson()));
  }

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUser);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }
}
