import 'dart:html';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'token';
  static const String _keyLastActive = 'last_active';
  static const int _sessionTimeout = 5; // Timeout in minutes

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await updateLastActive();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_keyLastActive, currentTime);
  }

  static Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_keyLastActive) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final difference =
        (currentTime - lastActive) / (1000 * 60); // Difference in minutes
    return difference >= _sessionTimeout;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyLastActive);
    window.location.reload();
  }
}
