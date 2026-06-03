import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';

/// Стили страниц с фирменным шрифтом RubikMonoOne.
abstract final class GroovePageStyles {
  static const fontFamily = 'RubikMonoOne';

  static TextStyle title(BuildContext context, {double size = 24}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle body(
    BuildContext context, {
    double size = 14,
    Color? color,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle muted(BuildContext context, {double size = 13}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    color: context.groove.onSurfaceSecondary,
  );

  /// Фон карточки: тёмная тема — фиолетовый, светлая — светлая карточка с рамкой.
  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? ElementsPurple : Theme.of(context).cardColor;
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final g = context.groove;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: cardBackground(context),
      borderRadius: BorderRadius.circular(12),
      border: isDark ? null : Border.all(color: g.border),
    );
  }
}
