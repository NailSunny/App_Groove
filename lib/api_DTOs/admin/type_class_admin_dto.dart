class TypeClassAdminDto {
  final int idType;
  final String? nameType;
  final String? discription;

  TypeClassAdminDto({
    required this.idType,
    this.nameType,
    this.discription,
  });

  factory TypeClassAdminDto.fromJson(Map<String, dynamic> json) {
    return TypeClassAdminDto(
      idType: json['id_type'] as int,
      nameType: json['name_type'] as String?,
      discription: json['discription'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name_type': nameType,
    'discription': discription,
  };
}
