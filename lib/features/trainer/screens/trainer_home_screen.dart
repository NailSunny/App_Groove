import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/trainer/models/trainer_group_lesson.dart';
import 'package:groove_app/features/trainer/models/trainer_personal_lesson.dart';
import 'package:groove_app/features/trainer/services/trainer_api_service.dart';
import 'package:groove_app/features/trainer/utils/lesson_highlight.dart';
import 'package:groove_app/features/trainer/widgets/lesson_type_tabs.dart';
import 'package:groove_app/features/trainer/widgets/trainer_lesson_card.dart';
import 'package:groove_app/features/trainer/widgets/week_day_selector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:groove_app/helper/trainer_session.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _lessonTypeIndex = 0;
  DateTime _currentWeek = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;

  List<TrainerGroupLesson> _groupLessons = [];
  List<TrainerPersonalLesson> _personalLessons = [];
  bool _loading = true;
  String? _error;
  int? _trainerId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _init();
  }

  Future<void> _init() async {
    _trainerId = await resolveTrainerUserId();
    await _loadSchedule();
  }

  DateTime get _selectedDate =>
      WeekDaySelector.selectedDate(_currentWeek, _selectedDayIndex);

  Future<void> _loadSchedule() async {
    if (_trainerId == null) {
      setState(() {
        _loading = false;
        _error = 'Не найден профиль тренера';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_lessonTypeIndex == 0) {
        final data = await getTrainerGroupSchedule(
          date: _selectedDate,
          trainerId: _trainerId!,
        );
        if (!mounted) return;
        setState(() {
          _groupLessons = data;
          _loading = false;
        });
      } else {
        final data = await getTrainerPersonalSchedule(
          date: _selectedDate,
          trainerId: _trainerId!,
        );
        if (!mounted) return;
        setState(() {
          _personalLessons = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Моё расписание',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
          ),
        ),
        LessonTypeTabs(
          selectedIndex: _lessonTypeIndex,
          onChanged: (i) {
            setState(() => _lessonTypeIndex = i);
            _loadSchedule();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: WeekDaySelector(
            currentWeek: _currentWeek,
            selectedDayIndex: _selectedDayIndex,
            onWeekChanged: (w) {
              setState(() => _currentWeek = w);
              _loadSchedule();
            },
            onDaySelected: (i) {
              setState(() => _selectedDayIndex = i);
              _loadSchedule();
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MainPurple),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadSchedule,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_lessonTypeIndex == 0) {
      return _buildGroupList();
    }
    return _buildPersonalList();
  }

  Widget _buildGroupList() {
    if (_groupLessons.isEmpty) {
      return Center(
        child: Text(
          'Нет групповых занятий на этот день',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    final sorted = List<TrainerGroupLesson>.from(_groupLessons)
      ..sort((a, b) => a.startAt(_selectedDate).compareTo(b.startAt(_selectedDate)));

    final now = DateTime.now();
    final slots = <LessonTimeSlot>[];
    for (var i = 0; i < sorted.length; i++) {
      final l = sorted[i];
      slots.add(LessonTimeSlot(
        index: i,
        start: l.startAt(_selectedDate),
        end: l.endAt(_selectedDate),
      ));
    }
    final highlights = computeLessonHighlights(slots, now);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final lesson = sorted[index];
        final highlight =
            highlights[index] ?? TrainerLessonHighlight.normal;

        return TrainerLessonCard(
          title: lesson.direction,
          subtitle: '',
          timeRange: lesson.timeRange,
          hall: lesson.hall,
          footer: 'Записано: ${lesson.registeredCount}/${lesson.maxCapacity}',
          statusLabel: lessonStatusLabel(highlight),
          highlight: highlight,
        );
      },
    );
  }

  Widget _buildPersonalList() {
    if (_personalLessons.isEmpty) {
      return Center(
        child: Text(
          'Нет персональных занятий на этот день',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    final sorted = List<TrainerPersonalLesson>.from(_personalLessons)
      ..sort((a, b) => a.startAt(_selectedDate).compareTo(b.startAt(_selectedDate)));

    final now = DateTime.now();
    final slots = <LessonTimeSlot>[];
    for (var i = 0; i < sorted.length; i++) {
      final l = sorted[i];
      slots.add(LessonTimeSlot(
        index: i,
        start: l.startAt(_selectedDate),
        end: l.endAt(_selectedDate),
      ));
    }
    final highlights = computeLessonHighlights(slots, now);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final lesson = sorted[index];
        final highlight =
            highlights[index] ?? TrainerLessonHighlight.normal;

        return TrainerLessonCard(
          title: lesson.clientShortName,
          subtitle: lesson.direction,
          timeRange: lesson.timeRange,
          hall: lesson.hall,
          statusLabel: lessonStatusLabel(highlight),
          highlight: highlight,
        );
      },
    );
  }
}
