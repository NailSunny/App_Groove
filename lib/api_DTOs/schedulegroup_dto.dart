class TypeClassDto {
  final int id;
  final String name;
  final String? description;

  TypeClassDto({required this.id, required this.name, this.description});

  factory TypeClassDto.fromJson(Map<String, dynamic> json) {
    return TypeClassDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class GroupClassScheduleDto {
  final int id;
  final String time;
  final String hallNumber;
  final int duration;
  final String trainerName;
  final String trainerSurname;
  final String direction;
  final int registeredCount;
  final int maxCapacity;

  GroupClassScheduleDto({
    required this.id,
    required this.time,
    required this.hallNumber,
    required this.duration,
    required this.trainerName,
    required this.trainerSurname,
    this.direction = '',
    this.registeredCount = 0,
    this.maxCapacity = 0,
  });

  factory GroupClassScheduleDto.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'];
    final timeStr = rawTime is String
        ? rawTime
        : rawTime != null
            ? rawTime.toString().split('.').first.substring(0, 5)
            : '';

    return GroupClassScheduleDto(
      id: json['id'] as int,
      time: timeStr,
      hallNumber: json['hallNumber']?.toString() ?? '',
      duration: json['duration'] as int? ?? 60,
      trainerName: json['trainerName']?.toString() ?? '',
      trainerSurname: json['trainerSurname']?.toString() ?? '',
      direction: json['direction']?.toString() ?? '',
      registeredCount: json['registeredCount'] as int? ?? 0,
      maxCapacity: json['maxCapacity'] as int? ?? 0,
    );
  }
}
