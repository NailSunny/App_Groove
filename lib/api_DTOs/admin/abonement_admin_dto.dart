class AbonementAdminDto {
  final int idAbonement;
  final String? nameAbonement;
  final int? idType;
  final bool isPrivate;
  final String? duration;
  final int price;
  final String? photo;
  final int kolClasses;
  final bool isTrial;

  AbonementAdminDto({
    required this.idAbonement,
    this.nameAbonement,
    this.idType,
    required this.isPrivate,
    this.duration,
    required this.price,
    this.photo,
    required this.kolClasses,
    this.isTrial = false,
  });

  factory AbonementAdminDto.fromJson(Map<String, dynamic> json) {
    return AbonementAdminDto(
      idAbonement: json['id_abonement'] as int,
      nameAbonement: json['name_abonement'] as String?,
      idType: json['id_type'] as int?,
      isPrivate: json['is_private'] as bool? ?? false,
      duration: json['duration'] as String?,
      price: json['price'] as int,
      photo: json['photo'] as String?,
      kolClasses: json['kol_classes'] as int? ?? 0,
      isTrial: json['is_trial'] as bool? ?? json['isTrial'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name_abonement': nameAbonement,
        'id_type': idType,
        'is_private': isPrivate,
        'duration': duration,
        'price': price,
        'photo': photo,
        'kol_classes': kolClasses,
      };
}
