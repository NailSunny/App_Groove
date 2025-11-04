class RegisterPersClassRequest {
  final int userId;
  final int trainerId;
  final DateTime startDateTime;

  RegisterPersClassRequest({
    required this.userId,
    required this.trainerId,
    required this.startDateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "trainerId": trainerId,
      "startDateTime": startDateTime.toIso8601String(),
    };
  }
}
