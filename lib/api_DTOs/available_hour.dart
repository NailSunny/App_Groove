class AvailableHour {
  final String hour;
  final int persClassId;
  final String direction;
  final String hall;

  AvailableHour({
    required this.hour,
    this.persClassId = 0,
    this.direction = '',
    this.hall = '',
  });

  factory AvailableHour.fromJson(Map<String, dynamic> json) {
    return AvailableHour(
      hour: json['hour'] as String? ?? '',
      persClassId: json['persClassId'] as int? ?? 0,
      direction: json['direction'] as String? ?? '',
      hall: json['hall'] as String? ?? '',
    );
  }
}
