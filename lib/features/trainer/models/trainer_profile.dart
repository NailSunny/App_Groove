class TrainerProfile {
  final int idTrainer;
  String name;
  String surname;
  String? patronymic;
  DateTime? dateOfBirth;
  String? phone;
  String? email;
  String? photo;
  String? information;

  TrainerProfile({
    required this.idTrainer,
    required this.name,
    required this.surname,
    this.patronymic,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.photo,
    this.information,
  });

  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    return TrainerProfile(
      idTrainer: (json['id_trainer'] ?? json['id_user']) as int,
      name: json['name_trainer'] as String? ?? '',
      surname: json['familia_trainer'] as String? ?? '',
      patronymic: json['patronymic'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      photo: json['photo'] as String?,
      information: json['information'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name_trainer': name,
      'familia_trainer': surname,
      'patronymic': patronymic,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phone': phone,
      'information': information,
      if (photo != null) 'photo': photo,
    };
  }
}
