import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';

enum TrainerLessonHighlight { normal, next, ongoing }

class TrainerLessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timeRange;
  final String hall;
  final String? footer;
  final String? statusLabel;
  final TrainerLessonHighlight highlight;

  const TrainerLessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeRange,
    required this.hall,
    this.footer,
    this.statusLabel,
    this.highlight = TrainerLessonHighlight.normal,
  });

  Color get _backgroundColor {
    switch (highlight) {
      case TrainerLessonHighlight.ongoing:
        return MainPurple.withValues(alpha: 0.35);
      case TrainerLessonHighlight.next:
        return ElementsPurple.withValues(alpha: 0.85);
      case TrainerLessonHighlight.normal:
        return ElementsPurple.withValues(alpha: 0.55);
    }
  }

  Color? get _borderColor {
    switch (highlight) {
      case TrainerLessonHighlight.ongoing:
        return ProcessYellow;
      case TrainerLessonHighlight.next:
        return MainPurple;
      case TrainerLessonHighlight.normal:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: _borderColor != null
            ? Border.all(color: _borderColor!, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (statusLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: highlight == TrainerLessonHighlight.ongoing
                        ? ProcessYellow
                        : MainPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel!,
                    style: TextStyle(
                      color: highlight == TrainerLessonHighlight.ongoing
                          ? BackBlack
                          : TextWhite,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            timeRange,
            style: TextStyle(color: ProcessYellow, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Зал $hall',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
          ),
          if (footer != null) ...[
            SizedBox(height: 6),
            Text(
              footer!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
