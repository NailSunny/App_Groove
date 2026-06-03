class ClientAdminDto {
  final int id;
  final String? nameUser;
  final String? familiaUser;
  final String? patronymic;
  final DateTime? dateOfBirth;
  final String fullName;
  final String? email;
  final String? phone;
  final int balance;

  ClientAdminDto({
    required this.id,
    this.nameUser,
    this.familiaUser,
    this.patronymic,
    this.dateOfBirth,
    required this.fullName,
    this.email,
    this.phone,
    required this.balance,
  });

  factory ClientAdminDto.fromJson(Map<String, dynamic> json) {
    return ClientAdminDto(
      id: json['id'] as int,
      nameUser: json['name_user'] as String?,
      familiaUser: json['familia_user'] as String?,
      patronymic: json['patronymic'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      balance: json['balance'] as int? ?? 0,
    );
  }
}
