class HallAdminDto {
  final int idHall;
  final String? numberHall;
  final bool isRentable;
  final String? parameters;

  HallAdminDto({
    required this.idHall,
    this.numberHall,
    required this.isRentable,
    this.parameters,
  });

  factory HallAdminDto.fromJson(Map<String, dynamic> json) {
    return HallAdminDto(
      idHall: json['id_hall'] as int,
      numberHall: json['number_hall'] as String?,
      isRentable: json['is_Rentable'] as bool? ?? false,
      parameters: json['parameters'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'number_hall': numberHall,
    'is_Rentable': isRentable,
    if (parameters != null) 'parameters': parameters,
  };
}
