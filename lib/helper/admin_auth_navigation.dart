import 'package:flutter/material.dart';
import 'package:groove_app/routes/admin_routes.dart';

Future<void> navigateAfterAdminLogin(BuildContext context) {
  return Navigator.of(context).pushNamedAndRemoveUntil(
    AdminRoutes.home,
    (_) => false,
  );
}

Future<void> navigateToAdminAuth(BuildContext context) {
  return Navigator.of(context).pushNamedAndRemoveUntil(
    AdminRoutes.auth,
    (_) => false,
  );
}
