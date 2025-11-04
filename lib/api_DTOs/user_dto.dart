class UserDto {
  int id_user;
  String? name_user;
  String? familia_user;
  String? email;
  String? phone;
  String? photo;
  int balance;

  UserDto({
    required this.id_user,
    this.name_user,
    this.familia_user,
    this.email,
    this.phone,
    this.photo,
    required this.balance,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id_user: json['id_user'],
      name_user: json['name_user'],
      familia_user: json['familia_user'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'],
      balance: json['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "name_user": name_user,
      "familia_user": familia_user,
      "email": email,
      "phone": phone,
      "photo": photo,
    };
  }
}
