import 'package:groove_app/api_service/api_user.dart';
import 'package:groove_app/helper/mobile_role_resolver.dart';
import 'package:groove_app/helper/trainer_session.dart';
import 'package:groove_app/helper/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Есть ли сохранённая сессия тренера (JWT + роль Trainer).
Future<bool> hasTrainerSession() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  if (token == null || token.isEmpty) return false;

  final profile = await fetchMyProfile();
  if (profile == null) return false;

  final role = await resolveMobileRole(profile);
  if (!isTrainerRole(role)) return false;

  await persistUserSession(profile, role: role);
  return true;
}

/// Есть ли сохранённая сессия клиента (JWT + роль Client).
Future<bool> hasClientSession() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  if (token == null || token.isEmpty) return false;

  final profile = await fetchMyProfile();
  if (profile == null) return false;

  final role = await resolveMobileRole(profile);
  if (!isClientRole(role)) return false;

  await persistUserSession(profile, role: role);
  return true;
}

Future<void> clearMobileSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  await prefs.remove('userId');
  await prefs.remove('trainerId');
  await prefs.remove('userRole');
}
