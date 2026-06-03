class TrainerDto {
  final int id;
  final String name;
  final String surname;
  final String photo;
  final String information;
  final List<String> directionNames;

  TrainerDto({
    required this.id,
    required this.name,
    required this.surname,
    required this.photo,
    required this.information,
    this.directionNames = const [],
  });

  factory TrainerDto.fromJson(Map<String, dynamic> json) {
    final directionsRaw = json['directionNames'] as List<dynamic>?;
    return TrainerDto(
      id: (json['id_trainer'] ?? json['id_user'] ?? json['id']) as int,
      name: (json['name_trainer'] ?? json['name'] ?? '').toString(),
      surname: (json['familia_trainer'] ?? json['surname'] ?? '').toString(),
      photo: (json['photo'] ?? json['Photo'] ?? '').toString(),
      information: (json['information'] ?? json['Information'] ?? '').toString(),
      directionNames: directionsRaw
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}
