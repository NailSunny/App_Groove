class ArendaListDto {
  final int idArenda;
  final DateTime dateArenda;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final String hallNumber;
  final int sum;

  ArendaListDto({
    required this.idArenda,
    required this.dateArenda,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.hallNumber,
    required this.sum,
  });

  factory ArendaListDto.fromJson(Map<String, dynamic> json) {
    return ArendaListDto(
      idArenda: json['idArenda'],
      dateArenda: DateTime.parse(json['dateArenda']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationHours: json['durationHours'],
      hallNumber: json['hallNumber'],
      sum: json['sum'],
    );
  }
}
