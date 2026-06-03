import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/features/trainer/services/trainer_api_service.dart';
import 'package:groove_app/helper/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Id_user тренера для вызовов API (поле id_trainer в JSON = Id_user после слияния таблиц).
int? trainerUserIdFromUserDto(UserDto profile) {
  if (!isTrainerRole(profile.role)) return null;
  return profile.trainerId ?? profile.id_user;
}

/// Сохраняет userId, роль и trainerId после входа.
/// [role] — уже нормализованная роль (из [resolveMobileRole]).
Future<void> persistUserSession(UserDto profile, {required String role}) async {
  final prefs = await SharedPreferences.getInstance();
  final normalized = normalizeRole(role);
  await prefs.setInt('userId', profile.id_user);
  await prefs.setString('userRole', normalized);

  if (isTrainerRole(normalized)) {
    await prefs.setInt('trainerId', profile.trainerId ?? profile.id_user);
  } else {
    await prefs.remove('trainerId');
  }
}

/// Возвращает Id_user тренера: /api/Trainer/me, затем prefs.
Future<int?> resolveTrainerUserId() async {
  final prefs = await SharedPreferences.getInstance();

  final trainerProfile = await getTrainerProfile();
  if (trainerProfile != null) {
    await prefs.setInt('trainerId', trainerProfile.idTrainer);
    await prefs.setString('userRole', 'Trainer');
    return trainerProfile.idTrainer;
  }

  if (!isTrainerRole(prefs.getString('userRole'))) return null;

  final userId = prefs.getInt('userId');
  if (userId != null) {
    await prefs.setInt('trainerId', userId);
    return userId;
  }

  return prefs.getInt('trainerId');
}

@Deprecated('Используйте persistUserSession')
Future<void> persistTrainerSession(UserDto profile) =>
    persistUserSession(profile, role: profile.role ?? 'Client');
