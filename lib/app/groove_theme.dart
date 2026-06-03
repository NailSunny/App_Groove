import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';

/// Общая тема и локализация для mobile и admin flavor.
abstract final class GrooveTheme {
  static const locale = Locale('ru');
  static const supportedLocales = [Locale('ru'), Locale('en')];

  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        groove: GrooveColors.light,
      );

  static ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        groove: GrooveColors.dark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required GrooveColors groove,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark(useMaterial3: false) : ThemeData.light(useMaterial3: false);

    final colorScheme = base.colorScheme.copyWith(
      brightness: brightness,
      primary: MainPurple,
      secondary: ProcessYellow,
      surface: groove.cardBackground,
      onSurface: groove.onSurface,
      onPrimary: Colors.white,
    );

    const fontFamily = 'RubikMonoOne';
    final textTheme = base.textTheme.apply(
      bodyColor: groove.onSurface,
      displayColor: groove.onSurface,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: groove.scaffoldBackground,
      cardColor: groove.cardBackground,
      dividerColor: groove.border,
      iconTheme: IconThemeData(color: groove.onSurface),
      primaryColor: MainPurple,
      extensions: [groove],
      appBarTheme: AppBarTheme(
        backgroundColor: groove.scaffoldBackground,
        foregroundColor: groove.onSurface,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: groove.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          color: groove.onSurface,
        ),
      ),
      textTheme: textTheme,
      dialogTheme: DialogTheme(
        backgroundColor: groove.cardBackground,
        titleTextStyle: TextStyle(
          color: groove.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: groove.onSurfaceSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(color: groove.onSurface),
        backgroundColor: groove.cardBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: groove.onSurfaceSecondary),
        hintStyle: TextStyle(color: groove.onSurfaceMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ElementsPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MainPurple),
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: groove.onSurface,
        iconColor: groove.onSurface,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: MainPurple),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: MainPurple)),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(groove.onSurface),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          backgroundColor: const WidgetStatePropertyAll(MainPurple),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return MainPurple;
          return groove.onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MainPurple.withValues(alpha: 0.45);
          }
          return groove.border;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: groove.cardBackground,
        textStyle: TextStyle(color: groove.onSurface),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: groove.menuPanel,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: groove.cardBackground,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          color: groove.onSurface,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: TextStyle(color: groove.onSurface),
        decoration: BoxDecoration(
          border: Border.all(color: groove.border),
        ),
      ),
    );
  }
}
