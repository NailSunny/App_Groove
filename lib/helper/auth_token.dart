import 'package:shared_preferences/shared_preferences.dart';

const _jwtKey = 'jwt_token';

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_jwtKey);
}

Future<void> saveAuthToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_jwtKey, token);
}

Future<void> clearAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_jwtKey);
}
