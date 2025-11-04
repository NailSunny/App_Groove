class ConfirmPurchaseDto {
  final int userId;
  final int? discount;

  ConfirmPurchaseDto({required this.userId, this.discount});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'discount': discount ?? 0,
    };
  }
}
