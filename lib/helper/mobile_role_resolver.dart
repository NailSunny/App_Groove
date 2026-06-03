import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/features/trainer/services/trainer_api_service.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:groove_app/helper/user_role.dart';

/// Определяет роль для mobile-приложения (профиль, JWT, trainerId, /api/Trainer/me).
Future<String> resolveMobileRole(UserDto profile) async {
  var role = normalizeRole(profile.role);

  if (role == 'Trainer' || role == 'Admin') return role;

  if (profile.trainerId != null && profile.trainerId == profile.id_user) {
    return 'Trainer';
  }

  final token = await getToken();
  if (token != null && token.isNotEmpty) {
    final jwtRole = normalizeRole(roleFromJwt(token));
    if (jwtRole == 'Trainer' || jwtRole == 'Admin') return jwtRole;
    if (jwtRole == 'Client') return 'Client';
  }

  if (role == 'Client') return 'Client';

  final trainerProfile = await getTrainerProfile();
  if (trainerProfile != null) return 'Trainer';

  return 'Client';
}
