import 'package:groove_app/helper/user_role.dart';

class UserDto {
  int id_user;
  String? name_user;
  String? familia_user;
  String? patronymic;
  String? email;
  String? phone;
  String? photo;
  int balance;
  String? role;
  int? trainerId;

  UserDto({
    required this.id_user,
    this.name_user,
    this.familia_user,
    this.patronymic,
    this.email,
    this.phone,
    this.photo,
    required this.balance,
    this.role,
    this.trainerId,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role'] ?? json['Role'];
    final role = roleRaw is String ? normalizeRole(roleRaw) : null;
    final idUser = _readInt(json['id_user'] ?? json['id_User'] ?? json['Id_user']);
    final trainerId = _readIntNullable(json['trainerId'] ?? json['TrainerId']);
    return UserDto(
      id_user: idUser,
      name_user: json['name_user'] as String?,
      familia_user: json['familia_user'] as String?,
      patronymic: json['patronymic'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      balance: _readInt(json['balance'], defaultValue: 0),
      role: role,
      trainerId: trainerId ?? (role == 'Trainer' ? idUser : null),
    );
  }

  static int _readInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    return defaultValue;
  }

  static int? _readIntNullable(dynamic value) {
    if (value == null) return null;
    return _readInt(value);
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name_user': name_user,
      'familia_user': familia_user,
      'patronymic': patronymic,
      'email': email,
      "phone": phone,
      "photo": photo,
    };
  }
}
