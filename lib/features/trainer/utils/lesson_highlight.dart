import 'package:groove_app/features/trainer/widgets/trainer_lesson_card.dart';

class LessonTimeSlot {
  final int index;
  final DateTime start;
  final DateTime end;

  LessonTimeSlot({
    required this.index,
    required this.start,
    required this.end,
  });
}

/// Определяет подсветку: идёт сейчас / следующее / обычное.
Map<int, TrainerLessonHighlight> computeLessonHighlights(
  List<LessonTimeSlot> slots,
  DateTime now,
) {
  final result = <int, TrainerLessonHighlight>{};
  for (final s in slots) {
    result[s.index] = TrainerLessonHighlight.normal;
  }

  int? ongoingIndex;
  for (final s in slots) {
    if (!now.isBefore(s.start) && now.isBefore(s.end)) {
      ongoingIndex = s.index;
      break;
    }
  }

  if (ongoingIndex != null) {
    result[ongoingIndex] = TrainerLessonHighlight.ongoing;
    return result;
  }

  LessonTimeSlot? nextSlot;
  for (final s in slots) {
    if (s.start.isAfter(now)) {
      if (nextSlot == null || s.start.isBefore(nextSlot.start)) {
        nextSlot = s;
      }
    }
  }

  if (nextSlot != null) {
    result[nextSlot.index] = TrainerLessonHighlight.next;
  }

  return result;
}

String? lessonStatusLabel(TrainerLessonHighlight highlight) {
  switch (highlight) {
    case TrainerLessonHighlight.ongoing:
      return 'Идёт сейчас';
    case TrainerLessonHighlight.next:
      return 'Скоро';
    case TrainerLessonHighlight.normal:
      return null;
  }
}
