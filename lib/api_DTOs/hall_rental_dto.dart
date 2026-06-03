class AvailableSlotDto {
  final String startTime;

  AvailableSlotDto({required this.startTime});

  factory AvailableSlotDto.fromJson(Map<String, dynamic> json) {
    final raw = json['startTime'] as String? ?? '';
    return AvailableSlotDto(startTime: raw.length >= 5 ? raw.substring(0, 5) : raw);
  }
}

class CreateHallRentalDto {
  final DateTime date;
  final List<String> startTimes;
  final int? hallId;

  CreateHallRentalDto({
    required this.date,
    required this.startTimes,
    this.hallId,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'startTimes': startTimes.map((t) => '$t:00').toList(),
        if (hallId != null) 'hallId': hallId,
      };
}

class CreateHallRentalResultDto {
  final int totalPrice;
  final int rentalCount;

  CreateHallRentalResultDto({
    required this.totalPrice,
    required this.rentalCount,
  });

  factory CreateHallRentalResultDto.fromJson(Map<String, dynamic> json) {
    final rentals = json['rentals'] as List<dynamic>? ?? [];
    return CreateHallRentalResultDto(
      totalPrice: json['totalPrice'] as int? ?? 0,
      rentalCount: rentals.length,
    );
  }
}

class HallRentalDto {
  final int id;
  final int totalPrice;
  final String status;

  HallRentalDto({
    required this.id,
    required this.totalPrice,
    required this.status,
  });

  factory HallRentalDto.fromJson(Map<String, dynamic> json) {
    return HallRentalDto(
      id: json['id'] as int,
      totalPrice: json['totalPrice'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

class MyHallRentalDto {
  final int id;
  final DateTime dateArenda;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final String? hallNumber;
  final int sum;
  final String status;
  final bool canCancel;

  MyHallRentalDto({
    required this.id,
    required this.dateArenda,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    this.hallNumber,
    required this.sum,
    required this.status,
    required this.canCancel,
  });

  factory MyHallRentalDto.fromJson(Map<String, dynamic> json) {
    return MyHallRentalDto(
      id: json['id'] as int,
      dateArenda: DateTime.parse(json['dateArenda'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationHours: json['durationHours'] as int? ?? 1,
      hallNumber: json['hallNumber'] as String?,
      sum: json['sum'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'Active' && !isPast;
  bool get isCancelled => status == 'Cancelled';
  bool get isCompleted => status == 'Completed' || (status == 'Active' && isPast);

  bool get isPast => endTime.isBefore(DateTime.now());

  String get displayStatusLabel {
    if (isCancelled) return 'Отменена';
    if (isCompleted) return 'Завершена';
    return 'Активна';
  }
}

class AdminHallRentalDto {
  final int id;
  final int hallId;
  final String? hallNumber;
  final DateTime date;
  final String startTime;
  final int durationHours;
  final int totalPrice;
  final String status;
  final String clientName;
  final String? clientPhone;
  final bool canCancel;

  AdminHallRentalDto({
    required this.id,
    required this.hallId,
    this.hallNumber,
    required this.date,
    required this.startTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.clientName,
    this.clientPhone,
    this.canCancel = false,
  });

  factory AdminHallRentalDto.fromJson(Map<String, dynamic> json) {
    final startRaw = json['startTime'] as String? ?? '';
    return AdminHallRentalDto(
      id: json['id'] as int,
      hallId: json['hallId'] as int,
      hallNumber: json['hallNumber'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw,
      durationHours: json['durationHours'] as int? ?? 1,
      totalPrice: json['totalPrice'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientPhone: json['clientPhone'] as String?,
      canCancel: json['canCancel'] as bool? ?? false,
    );
  }
}
