import 'package:flutter/material.dart';
import 'package:groove_app/app/app_flavor.dart';
import 'package:groove_app/app/groove_app.dart';
import 'package:groove_app/app/theme_notifier.dart';
import 'package:provider/provider.dart';

/// Точка входа admin flavor: администратор (Windows, macOS, Linux).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppScope.flavor = AppFlavor.admin;
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const GrooveApp(),
    ),
  );
}
