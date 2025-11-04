class RegisterDto {
  final String nameuser;
  final String familiauser;
  final String email;
  final String phone;
  final String password;

  RegisterDto({
    required this.nameuser,
    required this.familiauser,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "name_user": nameuser,
        "familia_user": familiauser,
        "email": email,
        "phone": phone,
        "password": password,
      };
}
