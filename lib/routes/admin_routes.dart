import 'package:flutter/material.dart';
import 'package:groove_app/features/admin/screens/admin_home.dart';
import 'package:groove_app/features/admin/screens/admin_login_page.dart';

/// Маршруты десктопного приложения администратора.
abstract final class AdminRoutes {
  static const auth = '/';
  static const home = '/home';
}

final Map<String, WidgetBuilder> adminRoutes = {
  AdminRoutes.auth: (_) => const AdminLoginPage(),
  AdminRoutes.home: (_) => const AdminHomePage(),
};
