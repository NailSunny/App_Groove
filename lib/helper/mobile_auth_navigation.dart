import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/api_service/api_user.dart';
import 'package:groove_app/helper/mobile_role_resolver.dart';
import 'package:groove_app/helper/trainer_session.dart';
import 'package:groove_app/helper/user_role.dart';
import 'package:groove_app/routes/mobile_routes.dart';
import 'package:groove_app/api_service/mobile_auth_api.dart';

/// Вход в мобильное приложение: Client → home, Trainer → trainer.
/// Роль Admin в mobile не поддерживается.
Future<void> navigateAfterMobileLogin(BuildContext context) async {
  final profile = await fetchMyProfile();
  if (!context.mounted) return;

  if (profile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось загрузить профиль')),
    );
    return;
  }

  final role = await resolveMobileRole(profile);
  await persistUserSession(profile, role: role);
  await _navigateByRole(context, role);
}

/// Автологин на экране входа (mobile).
Future<void> navigateAfterMobileSessionRestore(
  BuildContext context,
  UserDto profile,
) async {
  final role = await resolveMobileRole(profile);
  await persistUserSession(profile, role: role);
  if (!context.mounted) return;
  await _navigateByRole(context, role, replace: true);
}

Future<void> _navigateByRole(
  BuildContext context,
  String role, {
  bool replace = false,
}) async {
  if (!context.mounted) return;

  switch (normalizeRole(role)) {
    case 'Admin':
      await clearMobileSession();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Вход администратора доступен только в десктопном приложении',
          ),
        ),
      );
      return;
    case 'Trainer':
      final route = MobileRoutes.trainer;
      if (replace) {
        Navigator.of(context).pushReplacementNamed(route);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      }
      return;
    default:
      final route = MobileRoutes.home;
      if (replace) {
        Navigator.of(context).pushReplacementNamed(route);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      }
  }
}

Future<void> navigateToMobileAuth(BuildContext context) async {
  await clearMobileSession();
  if (!context.mounted) return;
  Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(MobileRoutes.auth, (_) => false);
}
