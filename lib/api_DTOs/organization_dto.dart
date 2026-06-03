class OrganizationHallDto {
  final int idHall;
  final String? numberHall;
  final String? photoUrl;
  final String? parameters;

  OrganizationHallDto({
    required this.idHall,
    this.numberHall,
    this.photoUrl,
    this.parameters,
  });

  factory OrganizationHallDto.fromJson(Map<String, dynamic> json) {
    return OrganizationHallDto(
      idHall: (json['id_hall'] ?? json['idHall']) as int,
      numberHall: (json['number_hall'] ?? json['numberHall']) as String?,
      photoUrl: (json['photoUrl'] ?? json['PhotoUrl']) as String?,
      parameters: (json['parameters'] ?? json['Parameters']) as String?,
    );
  }
}

class OrganizationDto {
  final int id;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? vkUrl;
  final DateTime? updatedAt;
  final List<OrganizationHallDto> halls;

  OrganizationDto({
    required this.id,
    this.logoUrl,
    this.address,
    this.phone,
    this.vkUrl,
    this.updatedAt,
    required this.halls,
  });

  factory OrganizationDto.fromJson(Map<String, dynamic> json) {
    final hallsJson = json['halls'] as List<dynamic>? ?? [];
    return OrganizationDto(
      id: json['id'] as int? ?? 1,
      logoUrl: (json['logoUrl'] ?? json['LogoUrl']) as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      vkUrl: json['vkUrl'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      halls: hallsJson
          .map((e) => OrganizationHallDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClientOrganizationDto {
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? vkUrl;
  final List<OrganizationHallDto> halls;

  ClientOrganizationDto({
    this.logoUrl,
    this.address,
    this.phone,
    this.vkUrl,
    required this.halls,
  });

  factory ClientOrganizationDto.fromJson(Map<String, dynamic> json) {
    final hallsJson = json['halls'] as List<dynamic>? ?? [];
    return ClientOrganizationDto(
      logoUrl: (json['logoUrl'] ?? json['LogoUrl']) as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      vkUrl: json['vkUrl'] as String?,
      halls: hallsJson
          .map((e) => OrganizationHallDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
