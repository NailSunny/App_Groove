class AddToCartDto {
  final int userId;
  final int abonementId;

  AddToCartDto({required this.userId, required this.abonementId});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'abonementId': abonementId,
    };
  }
}
