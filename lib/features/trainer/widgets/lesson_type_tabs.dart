import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';

class LessonTypeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LessonTypeTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.groove;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: g.border)),
      ),
      child: Row(
        children: [
          _tab(context, 'Групповые', 0),
          _tab(context, 'Персональные', 1),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String title, int index) {
    final g = context.groove;
    final selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Container(
          decoration: BoxDecoration(
            border: selected
                ? const Border(
                    bottom: BorderSide(color: ProcessYellow, width: 3),
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? ProcessYellow : g.onSurfaceSecondary,
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
