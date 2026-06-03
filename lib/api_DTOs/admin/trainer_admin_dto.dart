class TrainerAdminDto {
  final int idTrainer;
  final String? nameTrainer;
  final String? familiaTrainer;
  final String? patronymic;
  final DateTime? dateOfBirth;
  final String fullName;
  final String? photo;
  final String? information;
  final List<int> typeClassIds;
  final String? email;
  final String? phone;

  TrainerAdminDto({
    required this.idTrainer,
    this.nameTrainer,
    this.familiaTrainer,
    this.patronymic,
    this.dateOfBirth,
    required this.fullName,
    this.photo,
    this.information,
    this.typeClassIds = const [],
    this.email,
    this.phone,
  });

  factory TrainerAdminDto.fromJson(Map<String, dynamic> json) {
    return TrainerAdminDto(
      idTrainer: (json['id_trainer'] ?? json['id_user']) as int,
      nameTrainer: json['name_trainer'] as String?,
      familiaTrainer: json['familia_trainer'] as String?,
      patronymic: json['patronymic'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      fullName: json['fullName'] as String? ?? '',
      photo: json['photo'] as String?,
      information: json['information'] as String?,
      typeClassIds: (json['typeClassIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name_trainer': nameTrainer,
    'familia_trainer': familiaTrainer,
    'patronymic': patronymic,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'information': information,
    'photo': photo,
  };
}
