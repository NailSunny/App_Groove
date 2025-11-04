class AvailableHour {
  final String hour;

  AvailableHour({required this.hour});

  factory AvailableHour.fromJson(Map<String, dynamic> json) {
    return AvailableHour(hour: json['hour']);
  }
}
