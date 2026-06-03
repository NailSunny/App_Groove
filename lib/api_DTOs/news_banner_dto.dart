class NewsBannerDto {
  final int id;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsBannerDto({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsBannerDto.fromJson(Map<String, dynamic> json) {
    return NewsBannerDto(
      id: json['id'] as int,
      imageUrl: (json['imageUrl'] ?? json['ImageUrl']) as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

class ClientNewsBannerDto {
  final int id;
  final String imageUrl;
  final int displayOrder;

  ClientNewsBannerDto({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory ClientNewsBannerDto.fromJson(Map<String, dynamic> json) {
    return ClientNewsBannerDto(
      id: json['id'] as int,
      imageUrl: (json['imageUrl'] ?? json['ImageUrl']) as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}
