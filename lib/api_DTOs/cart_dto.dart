class CartItemDto {
  final int abonementId;
  final String abonementName;
  final int price;
  final int quantity;
  final int lineTotal;

  CartItemDto({
    required this.abonementId,
    required this.abonementName,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    final price = json['price'] as int? ?? 0;
    final quantity = json['quantity'] as int? ?? 1;
    return CartItemDto(
      abonementId: json['abonementId'] as int,
      abonementName: json['abonementName'] as String? ?? '',
      price: price,
      quantity: quantity,
      lineTotal: json['lineTotal'] as int? ?? (price * quantity),
    );
  }
}

class CartDto {
  final String name;
  final String surname;
  final String email;
  final String phone;
  final List<CartItemDto> items;
  final int total;

  CartDto({
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.items,
    required this.total,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final itemsList =
        itemsJson.map((i) => CartItemDto.fromJson(i as Map<String, dynamic>)).toList();

    return CartDto(
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      items: itemsList,
      total: json['total'] as int? ?? 0,
    );
  }
}
