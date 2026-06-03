import 'package:flutter/material.dart';
import 'package:groove_app/app/app_flavor.dart';
import 'package:groove_app/app/groove_theme.dart';
import 'package:groove_app/app/theme_notifier.dart';
import 'package:groove_app/routes/admin_routes.dart';
import 'package:groove_app/routes/mobile_routes.dart';
import 'package:provider/provider.dart';

/// Корневой [MaterialApp] с маршрутами в зависимости от [AppScope.flavor].
class GrooveApp extends StatelessWidget {
  const GrooveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();

    if (AppScope.isAdmin) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: GrooveTheme.locale,
        supportedLocales: GrooveTheme.supportedLocales,
        localizationsDelegates: GrooveTheme.localizationsDelegates,
        theme: GrooveTheme.lightTheme(),
        darkTheme: GrooveTheme.darkTheme(),
        themeMode: theme.mode,
        initialRoute: AdminRoutes.auth,
        routes: adminRoutes,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: GrooveTheme.locale,
      supportedLocales: GrooveTheme.supportedLocales,
      localizationsDelegates: GrooveTheme.localizationsDelegates,
      theme: GrooveTheme.lightTheme(),
      darkTheme: GrooveTheme.darkTheme(),
      themeMode: theme.mode,
      initialRoute: MobileRoutes.auth,
      routes: mobileRoutes,
      onGenerateRoute: mobileOnGenerateRoute,
    );
  }
}
