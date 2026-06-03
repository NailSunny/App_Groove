class UserAbonementDto {
  final int idActive;
  final int idPurchase;
  final String abonementName;
  final String status;
  final int ostatok;
  final DateTime dateActivation;
  final DateTime dateEnd;
  final int totalClasses;
  final bool isTrial;
  final bool canFreeze;
  final bool canUnfreeze;

  UserAbonementDto({
    required this.idActive,
    required this.idPurchase,
    required this.abonementName,
    required this.status,
    required this.ostatok,
    required this.dateActivation,
    required this.dateEnd,
    required this.totalClasses,
    required this.isTrial,
    required this.canFreeze,
    required this.canUnfreeze,
  });

  factory UserAbonementDto.fromJson(Map<String, dynamic> json) {
    return UserAbonementDto(
      idActive: json['idActive'] as int,
      idPurchase: json['idPurchase'] as int? ?? 0,
      abonementName: json['abonementName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      ostatok: json['ostatok'] as int? ?? 0,
      dateActivation: DateTime.parse(json['dateActivation'].toString()),
      dateEnd: DateTime.parse(json['dateEnd'].toString()),
      totalClasses: json['totalClasses'] as int? ?? 0,
      isTrial: json['isTrial'] as bool? ?? false,
      canFreeze: json['canFreeze'] as bool? ?? false,
      canUnfreeze: json['canUnfreeze'] as bool? ?? false,
    );
  }
}
