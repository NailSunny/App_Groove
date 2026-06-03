class TrainerGroupLesson {
  final int id;
  final String direction;
  final String time;
  final int duration;
  final String hall;
  final int registeredCount;
  final int maxCapacity;

  TrainerGroupLesson({
    required this.id,
    required this.direction,
    required this.time,
    required this.duration,
    required this.hall,
    required this.registeredCount,
    required this.maxCapacity,
  });

  factory TrainerGroupLesson.fromJson(Map<String, dynamic> json) {
    return TrainerGroupLesson(
      id: json['id'] as int,
      direction: json['direction'] as String? ?? '',
      time: json['time'] as String? ?? '',
      duration: json['duration'] as int? ?? 60,
      hall: json['hall'] as String? ?? '',
      registeredCount: json['registeredCount'] as int? ?? 0,
      maxCapacity: json['maxCapacity'] as int? ?? 0,
    );
  }

  DateTime startAt(DateTime day) {
    final parts = time.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime endAt(DateTime day) =>
      startAt(day).add(Duration(minutes: duration));

  String get timeRange {
    final parts = time.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final start = DateTime(0, 1, 1, h, m);
    final end = start.add(Duration(minutes: duration));
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(start)} – ${fmt(end)}';
  }
}
