import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/app/theme_notifier.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:provider/provider.dart';

/// Переключатель светлой / тёмной темы.
class ThemeModeSwitch extends StatelessWidget {
  final bool showLabel;

  ThemeModeSwitch({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final g = context.groove;
    final isDark = theme.isDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: g.onSurfaceSecondary,
          size: 20,
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            isDark ? 'Тёмная' : 'Светлая',
            style: TextStyle(color: g.onSurfaceSecondary, fontSize: 14),
          ),
        ],
        const SizedBox(width: 8),
        Switch(
          value: !isDark,
          onChanged: (_) => theme.toggle(),
          activeColor: MainPurple,
          activeTrackColor: MainPurple.withValues(alpha: 0.45),
          inactiveThumbColor: g.onSurfaceMuted,
          inactiveTrackColor: g.border,
        ),
      ],
    );
  }
}
