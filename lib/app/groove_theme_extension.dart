import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';

/// Семантические цвета приложения (зависят от светлой/тёмной темы).
@immutable
class GrooveColors extends ThemeExtension<GrooveColors> {
  const GrooveColors({
    required this.scaffoldBackground,
    required this.cardBackground,
    required this.headerBackground,
    required this.onSurface,
    required this.onSurfaceSecondary,
    required this.onSurfaceMuted,
    required this.border,
    required this.logoAsset,
    required this.carouselDotInactive,
    required this.menuPanel,
  });

  final Color scaffoldBackground;
  final Color cardBackground;
  final Color headerBackground;
  final Color onSurface;
  final Color onSurfaceSecondary;
  final Color onSurfaceMuted;
  final Color border;
  final String logoAsset;
  final Color carouselDotInactive;
  final Color menuPanel;

  static const light = GrooveColors(
    scaffoldBackground: Color(0xFFF3EDF7),
    cardBackground: Color(0xFFFFFFFF),
    headerBackground: Color(0xFFE8DDF0),
    onSurface: Color(0xDE000000),
    onSurfaceSecondary: Color(0x99000000),
    onSurfaceMuted: Color(0x8A000000),
    border: Color(0xFFD0C4D8),
    logoAsset: 'images/Logo_Groove_Dark.png',
    carouselDotInactive: Color(0x4D000000),
    menuPanel: Color(0xFFEDE4F2),
  );

  static const dark = GrooveColors(
    scaffoldBackground: BackBlack,
    cardBackground: Color(0xFF2A2A2A),
    headerBackground: Color(0xFF1E1E1E),
    onSurface: TextWhite,
    onSurfaceSecondary: Color(0xB3FFFFFF),
    onSurfaceMuted: Color(0x8AFFFFFF),
    border: Color(0xFF2A2A2A),
    logoAsset: 'images/Logo_Groove.png',
    carouselDotInactive: Color(0x38FFFFFF),
    menuPanel: Color(0xFF1E1E1E),
  );

  @override
  GrooveColors copyWith({
    Color? scaffoldBackground,
    Color? cardBackground,
    Color? headerBackground,
    Color? onSurface,
    Color? onSurfaceSecondary,
    Color? onSurfaceMuted,
    Color? border,
    String? logoAsset,
    Color? carouselDotInactive,
    Color? menuPanel,
  }) {
    return GrooveColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      headerBackground: headerBackground ?? this.headerBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      border: border ?? this.border,
      logoAsset: logoAsset ?? this.logoAsset,
      carouselDotInactive: carouselDotInactive ?? this.carouselDotInactive,
      menuPanel: menuPanel ?? this.menuPanel,
    );
  }

  @override
  GrooveColors lerp(ThemeExtension<GrooveColors>? other, double t) {
    if (other is! GrooveColors) return this;
    return GrooveColors(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      headerBackground:
          Color.lerp(headerBackground, other.headerBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceSecondary:
          Color.lerp(onSurfaceSecondary, other.onSurfaceSecondary, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      logoAsset: t < 0.5 ? logoAsset : other.logoAsset,
      carouselDotInactive:
          Color.lerp(carouselDotInactive, other.carouselDotInactive, t)!,
      menuPanel: Color.lerp(menuPanel, other.menuPanel, t)!,
    );
  }
}

extension GrooveThemeContext on BuildContext {
  GrooveColors get groove =>
      Theme.of(this).extension<GrooveColors>() ?? GrooveColors.dark;
}
