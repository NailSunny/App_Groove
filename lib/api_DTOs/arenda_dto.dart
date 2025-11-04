// models/free_hour_dto.dart
class FreeHourDto {
  final int hour;
  String get label => '$hour:00';

  FreeHourDto({required this.hour});

  factory FreeHourDto.fromJson(Map<String, dynamic> json) {
    return FreeHourDto(hour: json['hour']);
  }
}

// models/arenda_request_dto.dart
class ArendaRequestDto {
  final int userId;
  final DateTime date;
  final int startHour;
  final int durationHours;

  ArendaRequestDto({
    required this.userId,
    required this.date,
    required this.startHour,
    required this.durationHours,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "date": date.toIso8601String(),
        "startHour": startHour,
        "durationHours": durationHours,
      };
}
