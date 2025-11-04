class Abonement {
  final int id; // ← добавлено
  final String name;
  final int price;
  final bool isPrivate;

  Abonement({
    required this.id,
    required this.name,
    required this.price,
    required this.isPrivate,
  });

  factory Abonement.fromJson(Map<String, dynamic> json) {
    return Abonement(
      id: json['id'], // ← получаем id
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toCartItem() {
    return {
      'id': id, // ← добавлено
      'title': name,
      'price': '$price ₽',
      'description': isPrivate ? 'Индивидуальное занятие' : 'Групповые занятия',
    };
  }
}
