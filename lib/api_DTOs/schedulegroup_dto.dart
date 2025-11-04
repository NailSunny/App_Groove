class TypeClassDto {
  final int id;
  final String name;

  TypeClassDto({required this.id, required this.name});

  factory TypeClassDto.fromJson(Map<String, dynamic> json) {
    return TypeClassDto(
      id: json['id'],
      name: json['name'],
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

  GroupClassScheduleDto({
    required this.id,
    required this.time,
    required this.hallNumber,
    required this.duration,
    required this.trainerName,
    required this.trainerSurname,
  });

  factory GroupClassScheduleDto.fromJson(Map<String, dynamic> json) {
    return GroupClassScheduleDto(
      id: json['id'],
      time: json['time'],
      hallNumber: json['hallNumber'],
      duration: json['duration'],
      trainerName: json['trainerName'],
      trainerSurname: json['trainerSurname'],
    );
  }
}
