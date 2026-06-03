class PurchaseItemDto {
  final String abonementName;
  final int quantity;
  final int unitPrice;
  final int total;

  PurchaseItemDto({
    required this.abonementName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory PurchaseItemDto.fromJson(Map<String, dynamic> json) {
    return PurchaseItemDto(
      abonementName: json['abonementName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unitPrice'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class PurchaseDto {
  final int idPurchase;
  final DateTime datePurchase;
  final int? discount;
  final List<PurchaseItemDto> items;
  final int totalBeforeDiscount;
  final int totalAfterDiscount;
  final String status;
  final bool canCancel;

  PurchaseDto({
    required this.idPurchase,
    required this.datePurchase,
    required this.discount,
    required this.items,
    required this.totalBeforeDiscount,
    required this.totalAfterDiscount,
    this.status = 'Active',
    this.canCancel = false,
  });

  factory PurchaseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDto(
      idPurchase: json['id_purchase'] as int,
      datePurchase: DateTime.parse(json['date_purchase'].toString()),
      discount: json['discount'] as int?,
      items: (json['items'] as List)
          .map((item) => PurchaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalBeforeDiscount: json['totalBeforeDiscount'] as int? ?? 0,
      totalAfterDiscount: json['totalAfterDiscount'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }
}
