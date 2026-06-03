class ReportPeriodPointDto {
  final String label;
  final DateTime? periodStart;
  final double amount;
  final int count;

  ReportPeriodPointDto({
    required this.label,
    this.periodStart,
    this.amount = 0,
    this.count = 0,
  });

  factory ReportPeriodPointDto.fromJson(Map<String, dynamic> json) =>
      ReportPeriodPointDto(
        label: json['label'] as String? ?? '',
        periodStart: json['periodStart'] != null
            ? DateTime.tryParse(json['periodStart'].toString())
            : null,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        count: json['count'] as int? ?? 0,
      );
}

class ReportNamedCountDto {
  final String name;
  final int? id;
  final int count;
  final double amount;

  ReportNamedCountDto({
    required this.name,
    this.id,
    this.count = 0,
    this.amount = 0,
  });

  factory ReportNamedCountDto.fromJson(Map<String, dynamic> json) =>
      ReportNamedCountDto(
        name: json['name'] as String? ?? '',
        id: json['id'] as int?,
        count: json['count'] as int? ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
      );
}

class ReportTransactionDto {
  final String type;
  final int id;
  final DateTime date;
  final double amount;
  final String clientName;
  final String description;
  final String status;

  ReportTransactionDto({
    required this.type,
    required this.id,
    required this.date,
    required this.amount,
    required this.clientName,
    required this.description,
    required this.status,
  });

  factory ReportTransactionDto.fromJson(Map<String, dynamic> json) =>
      ReportTransactionDto(
        type: json['type'] as String? ?? '',
        id: json['id'] as int? ?? 0,
        date: DateTime.parse(json['date'].toString()),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        clientName: json['clientName'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
}

class FinanceReportDto {
  final double totalRevenue;
  final double abonementRevenue;
  final double rentalRevenue;
  final int soldAbonementsCount;
  final int trialAbonementsCount;
  final int paidAbonementsCount;
  final int rentalCount;
  final double rentalAverageCheck;
  final List<ReportPeriodPointDto> revenueTrend;
  final List<ReportPeriodPointDto> monthlyRevenue;
  final List<ReportPeriodPointDto> cumulativeRevenue;
  final List<ReportNamedCountDto> revenueShare;
  final List<ReportNamedCountDto> topAbonements;
  final List<ReportNamedCountDto> abonementsByDirection;
  final List<ReportTransactionDto> recentTransactions;

  FinanceReportDto({
    required this.totalRevenue,
    required this.abonementRevenue,
    required this.rentalRevenue,
    required this.soldAbonementsCount,
    required this.trialAbonementsCount,
    required this.paidAbonementsCount,
    required this.rentalCount,
    required this.rentalAverageCheck,
    required this.revenueTrend,
    required this.monthlyRevenue,
    required this.cumulativeRevenue,
    required this.revenueShare,
    required this.topAbonements,
    required this.abonementsByDirection,
    required this.recentTransactions,
  });

  factory FinanceReportDto.fromJson(Map<String, dynamic> json) => FinanceReportDto(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
        abonementRevenue: (json['abonementRevenue'] as num?)?.toDouble() ?? 0,
        rentalRevenue: (json['rentalRevenue'] as num?)?.toDouble() ?? 0,
        soldAbonementsCount: json['soldAbonementsCount'] as int? ?? 0,
        trialAbonementsCount: json['trialAbonementsCount'] as int? ?? 0,
        paidAbonementsCount: json['paidAbonementsCount'] as int? ?? 0,
        rentalCount: json['rentalCount'] as int? ?? 0,
        rentalAverageCheck: (json['rentalAverageCheck'] as num?)?.toDouble() ?? 0,
        revenueTrend: _points(json['revenueTrend']),
        monthlyRevenue: _points(json['monthlyRevenue']),
        cumulativeRevenue: _points(json['cumulativeRevenue']),
        revenueShare: _named(json['revenueShare']),
        topAbonements: _named(json['topAbonements']),
        abonementsByDirection: _named(json['abonementsByDirection']),
        recentTransactions: (json['recentTransactions'] as List? ?? [])
            .map((e) => ReportTransactionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TrainerReportRowDto {
  final int trainerId;
  final String trainerName;
  final int groupClassesCount;
  final int personalClassesCount;
  final int totalClassesCount;
  final int groupRegistrationsCount;
  final int uniqueClientsCount;
  final double classesPerWeek;

  TrainerReportRowDto({
    required this.trainerId,
    required this.trainerName,
    required this.groupClassesCount,
    required this.personalClassesCount,
    required this.totalClassesCount,
    required this.groupRegistrationsCount,
    required this.uniqueClientsCount,
    required this.classesPerWeek,
  });

  factory TrainerReportRowDto.fromJson(Map<String, dynamic> json) =>
      TrainerReportRowDto(
        trainerId: json['trainerId'] as int? ?? 0,
        trainerName: json['trainerName'] as String? ?? '',
        groupClassesCount: json['groupClassesCount'] as int? ?? 0,
        personalClassesCount: json['personalClassesCount'] as int? ?? 0,
        totalClassesCount: json['totalClassesCount'] as int? ?? 0,
        groupRegistrationsCount: json['groupRegistrationsCount'] as int? ?? 0,
        uniqueClientsCount: json['uniqueClientsCount'] as int? ?? 0,
        classesPerWeek: (json['classesPerWeek'] as num?)?.toDouble() ?? 0,
      );
}

class TrainerReportDto {
  final List<TrainerReportRowDto> trainers;
  final List<ReportPeriodPointDto> trainerWeeklyLoad;

  TrainerReportDto({required this.trainers, required this.trainerWeeklyLoad});

  factory TrainerReportDto.fromJson(Map<String, dynamic> json) => TrainerReportDto(
        trainers: (json['trainers'] as List? ?? [])
            .map((e) => TrainerReportRowDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        trainerWeeklyLoad: _points(json['trainerWeeklyLoad']),
      );
}

class AttendanceClientRowDto {
  final int userId;
  final String fullName;
  final int groupVisits;
  final int personalVisits;
  final int totalVisits;
  final DateTime? lastVisitDate;

  AttendanceClientRowDto({
    required this.userId,
    required this.fullName,
    required this.groupVisits,
    required this.personalVisits,
    required this.totalVisits,
    this.lastVisitDate,
  });

  factory AttendanceClientRowDto.fromJson(Map<String, dynamic> json) =>
      AttendanceClientRowDto(
        userId: json['userId'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        groupVisits: json['groupVisits'] as int? ?? 0,
        personalVisits: json['personalVisits'] as int? ?? 0,
        totalVisits: json['totalVisits'] as int? ?? 0,
        lastVisitDate: json['lastVisitDate'] != null
            ? DateTime.tryParse(json['lastVisitDate'].toString())
            : null,
      );
}

class ChurnRiskClientDto {
  final int userId;
  final String fullName;
  final DateTime? lastVisitDate;
  final int daysSinceLastVisit;

  ChurnRiskClientDto({
    required this.userId,
    required this.fullName,
    this.lastVisitDate,
    required this.daysSinceLastVisit,
  });

  factory ChurnRiskClientDto.fromJson(Map<String, dynamic> json) =>
      ChurnRiskClientDto(
        userId: json['userId'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        lastVisitDate: json['lastVisitDate'] != null
            ? DateTime.tryParse(json['lastVisitDate'].toString())
            : null,
        daysSinceLastVisit: json['daysSinceLastVisit'] as int? ?? 0,
      );
}

class AttendanceReportDto {
  final int totalGroupRegistrations;
  final int personalRegistrationsCount;
  final int uniqueClientsCount;
  final int cancellationsCount;
  final int absentVisitsCount;
  final int cancellationCount;
  final double averageFillRatePercent;
  final List<ReportPeriodPointDto> visitsByDayOfWeek;
  final List<ReportNamedCountDto> visitsByDirection;
  final List<ReportNamedCountDto> topPopularClasses;
  final List<ReportPeriodPointDto> monthlyAttendanceTrend;
  final List<AttendanceClientRowDto> clients;
  final List<ChurnRiskClientDto> churnRiskClients;

  AttendanceReportDto({
    required this.totalGroupRegistrations,
    required this.personalRegistrationsCount,
    required this.uniqueClientsCount,
    required this.cancellationsCount,
    required this.absentVisitsCount,
    required this.cancellationCount,
    required this.averageFillRatePercent,
    required this.visitsByDayOfWeek,
    required this.visitsByDirection,
    required this.topPopularClasses,
    required this.monthlyAttendanceTrend,
    required this.clients,
    required this.churnRiskClients,
  });

  factory AttendanceReportDto.fromJson(Map<String, dynamic> json) =>
      AttendanceReportDto(
        totalGroupRegistrations: json['totalGroupRegistrations'] as int? ?? 0,
        personalRegistrationsCount: json['personalRegistrationsCount'] as int? ??
            json['uniqueClientsCount'] as int? ??
            0,
        uniqueClientsCount: json['uniqueClientsCount'] as int? ?? 0,
        cancellationsCount: json['cancellationsCount'] as int? ?? 0,
        absentVisitsCount: json['absentVisitsCount'] as int? ?? 0,
        cancellationCount: json['cancellationCount'] as int? ?? 0,
        averageFillRatePercent:
            (json['averageFillRatePercent'] as num?)?.toDouble() ?? 0,
        visitsByDayOfWeek: _points(json['visitsByDayOfWeek']),
        visitsByDirection: _named(json['visitsByDirection']),
        topPopularClasses: _named(json['topPopularClasses']),
        monthlyAttendanceTrend: _points(json['monthlyAttendanceTrend']),
        clients: (json['clients'] as List? ?? [])
            .map((e) => AttendanceClientRowDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        churnRiskClients: (json['churnRiskClients'] as List? ?? [])
            .map((e) => ChurnRiskClientDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

List<ReportPeriodPointDto> _points(dynamic raw) => (raw as List? ?? [])
    .map((e) => ReportPeriodPointDto.fromJson(e as Map<String, dynamic>))
    .toList();

List<ReportNamedCountDto> _named(dynamic raw) => (raw as List? ?? [])
    .map((e) => ReportNamedCountDto.fromJson(e as Map<String, dynamic>))
    .toList();
