import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';

/// Логотип студии: светлая тема — Logo_Groove_Dark.png, тёмная — Logo_Groove.png.
class GrooveLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const GrooveLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      context.groove.logoAsset,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
