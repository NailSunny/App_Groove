import 'package:flutter/material.dart';
import 'package:groove_app/api_service/cart_provider.dart';
import 'package:groove_app/app/app_flavor.dart';
import 'package:groove_app/app/groove_app.dart';
import 'package:groove_app/app/theme_notifier.dart';
import 'package:provider/provider.dart';

/// Точка входа mobile flavor: клиенты и тренеры (Android, iOS).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppScope.flavor = AppFlavor.mobile;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const GrooveApp(),
    ),
  );
}
