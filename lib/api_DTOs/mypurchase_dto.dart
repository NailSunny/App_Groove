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
      abonementName: json['abonementName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      total: json['total'],
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

  PurchaseDto({
    required this.idPurchase,
    required this.datePurchase,
    required this.discount,
    required this.items,
    required this.totalBeforeDiscount,
    required this.totalAfterDiscount,
  });

  factory PurchaseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDto(
      idPurchase: json['id_purchase'],
      datePurchase: DateTime.parse(json['date_purchase']),
      discount: json['discount'],
      items: (json['items'] as List)
          .map((item) => PurchaseItemDto.fromJson(item))
          .toList(),
      totalBeforeDiscount: json['totalBeforeDiscount'],
      totalAfterDiscount: json['totalAfterDiscount'],
    );
  }
}
