class RegistryRecord {
  final int id;
  final String classType;
  final DateTime start;
  final DateTime end;
  final int duration;
  final String hall;
  final String abonementName;
  final String status;

  RegistryRecord({
    required this.id,
    required this.classType,
    required this.start,
    required this.end,
    required this.duration,
    required this.hall,
    required this.abonementName,
    required this.status,
  });

  factory RegistryRecord.fromJson(Map<String, dynamic> json) {
    return RegistryRecord(
      id: json['idRegistry'],
      classType: json['classType'],
      start: DateTime.parse(json['startDateTime']),
      end: DateTime.parse(json['endDateTime']),
      duration: json['duration'],
      hall: json['hallNumber'],
      abonementName: json['abonementName'],
      status: json['status'],
    );
  }
}
