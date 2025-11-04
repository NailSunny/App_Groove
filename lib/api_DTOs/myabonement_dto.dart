class UserAbonementDto {
  final int idPurchase;
  final String abonementName;
  final String status;
  final int ostatok;
  final DateTime dateActivation;
  final DateTime dateEnd;
  final int totalClasses;

  UserAbonementDto({
    required this.idPurchase,
    required this.abonementName,
    required this.status,
    required this.ostatok,
    required this.dateActivation,
    required this.dateEnd,
    required this.totalClasses,
  });

  factory UserAbonementDto.fromJson(Map<String, dynamic> json) {
    return UserAbonementDto(
      idPurchase: json['idPurchase'],
      abonementName: json['abonementName'],
      status: json['status'],
      ostatok: json['ostatok'],
      dateActivation: DateTime.parse(json['dateActivation']),
      dateEnd: DateTime.parse(json['dateEnd']),
      totalClasses: json['totalClasses']
    );
  }
}
