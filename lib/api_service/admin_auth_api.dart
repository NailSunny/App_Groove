import 'package:groove_app/api_DTOs/login_dto.dart';
import 'package:groove_app/api_service/api_requests.dart';
import 'package:groove_app/api_service/api_user.dart';
import 'package:groove_app/helper/auth_token.dart';

/// Вход администратора. Возвращает null при успехе, иначе текст ошибки.
Future<String?> loginAdmin(LoginDto credentials) async {
  final loginResult = await loginUser(credentials);
  if (loginResult != 'Успешный вход') {
    return loginResult;
  }

  final profile = await fetchMyProfile();
  if (profile == null) {
    await _clearToken();
    return 'Не удалось получить профиль';
  }

  if (profile.role != 'Admin') {
    await _clearToken();
    return 'Доступ только для администраторов';
  }

  return null;
}

Future<void> logoutAdmin() async {
  await _clearToken();
}

Future<bool> hasAdminSession() async {
  final token = await getAuthToken();
  if (token == null || token.isEmpty) return false;

  final profile = await fetchMyProfile();
  return profile?.role == 'Admin';
}

Future<void> _clearToken() async => clearAuthToken();
