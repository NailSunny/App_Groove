class TrainerDto {
  final int id;
  final String name;
  final String surname;
  final String photo;
  final String information;

  TrainerDto({
    required this.id,
    required this.name,
    required this.surname,
    required this.photo,
    required this.information,
  });

  factory TrainerDto.fromJson(Map<String, dynamic> json) {
    return TrainerDto(
      id: json['id_trainer'],
      name: json['name_trainer'] ?? '',
      surname: json['familia_trainer'] ?? '',
      photo: json['photo'] ?? '',
      information: json['information'] ?? '',
    );
  }
}
