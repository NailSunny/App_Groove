class PurchaseAdminDto {
  final int idPurchase;
  final int idUser;
  final String clientFullName;
  final String abonementSummary;
  final DateTime datePurchase;
  final int summa;
  final int? discount;
  final String status;
  final bool canCancel;

  PurchaseAdminDto({
    required this.idPurchase,
    required this.idUser,
    required this.clientFullName,
    required this.abonementSummary,
    required this.datePurchase,
    required this.summa,
    this.discount,
    required this.status,
    this.canCancel = false,
  });

  factory PurchaseAdminDto.fromJson(Map<String, dynamic> json) {
    return PurchaseAdminDto(
      idPurchase: json['id_purchase'] as int,
      idUser: json['id_user'] as int,
      clientFullName: json['clientFullName'] as String? ?? '',
      abonementSummary: json['abonementSummary'] as String? ?? '',
      datePurchase: DateTime.parse(json['date_purchase'].toString()),
      summa: json['summa'] as int,
      discount: json['discount'] as int?,
      status: json['status'] as String? ?? 'Active',
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'Active';
}
