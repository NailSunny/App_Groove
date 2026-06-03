class RegisterDto {
  final String nameuser;
  final String familiauser;
  final String? patronymic;
  final String email;
  final String phone;
  final String password;
  final DateTime dateOfBirth;

  RegisterDto({
    required this.nameuser,
    required this.familiauser,
    this.patronymic,
    required this.email,
    required this.phone,
    required this.password,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'name_user': nameuser,
        'familia_user': familiauser,
        if (patronymic != null && patronymic!.trim().isNotEmpty)
          'patronymic': patronymic!.trim(),
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'email': email,
        'phone': phone,
        'password': password,
      };
}
