class CartItemDto {
  final String abonementName;
  final int price;

  CartItemDto({required this.abonementName, required this.price});

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      abonementName: json['abonementName'],
      price: json['price'],
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
    var itemsJson = json['items'] as List;
    List<CartItemDto> itemsList =
        itemsJson.map((i) => CartItemDto.fromJson(i)).toList();

    return CartDto(
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phone: json['phone'],
      items: itemsList,
      total: json['total'],
    );
  }
}
