import 'dart:convert';

import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map<String, String> _headers(String? token) => {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

Future<Map<String, dynamic>> fetchTrainerGroupSlotsWeek({
  required int trainerId,
  required DateTime weekStart,
}) async {
  final token = await getToken();
  final dateStr = DateFormat('yyyy-MM-dd').format(weekStart);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/trainer/$trainerId/group-slots?weekStart=$dateStr',
  );
  final response = await http.get(uri, headers: _headers(token));
  if (response.statusCode != 200) {
    throw Exception('Ошибка загрузки слотов: ${response.statusCode}');
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> fetchTrainerPersonalSlotsDay({
  required int trainerId,
  required DateTime day,
}) async {
  final token = await getToken();
  final dayStr = DateFormat('yyyy-MM-dd').format(day);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/trainer/$trainerId/personal-slots?weekStart=$dayStr&day=$dayStr',
  );
  final response = await http.get(uri, headers: _headers(token));
  if (response.statusCode != 200) {
    throw Exception('Ошибка загрузки персональных слотов: ${response.statusCode}');
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> fetchTrainerDirections(int trainerId) async {
  final token = await getToken();
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/trainer/$trainerId/directions',
  );
  final response = await http.get(uri, headers: _headers(token));
  if (response.statusCode != 200) return [];
  final list = jsonDecode(response.body) as List<dynamic>;
  return list.cast<Map<String, dynamic>>();
}

Future<void> createGroupDraft({
  required int trainerId,
  required DateTime date,
  required String startTime,
  required int directionId,
  int? hallId,
}) async {
  final token = await getToken();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/schedule/group/draft');
  final response = await http.post(
    uri,
    headers: _headers(token),
    body: jsonEncode({
      'trainerId': trainerId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'directionId': directionId,
      if (hallId != null) 'hallId': hallId,
    }),
  );
  if (response.statusCode != 200) {
    final err = response.body;
    throw Exception(err.isNotEmpty ? err : 'Не удалось создать занятие');
  }
}

Future<void> deleteGroupDraft({required int id, required int trainerId}) async {
  final token = await getToken();
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/group/draft/$id?trainerId=$trainerId',
  );
  final response = await http.delete(uri, headers: _headers(token));
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(response.body);
  }
}

Future<void> createPersonalDraft({
  required int trainerId,
  required DateTime date,
  required String startTime,
  int? hallId,
}) async {
  final token = await getToken();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/schedule/personal/draft');
  final response = await http.post(
    uri,
    headers: _headers(token),
    body: jsonEncode({
      'trainerId': trainerId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      if (hallId != null) 'hallId': hallId,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

Future<void> deletePersonalDraft({required int id, required int trainerId}) async {
  final token = await getToken();
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/personal/draft/$id?trainerId=$trainerId',
  );
  final response = await http.delete(uri, headers: _headers(token));
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(response.body);
  }
}

/// Понедельник недели заполнения (следующая от текущей).
DateTime schedulingWeekStart([DateTime? from]) {
  final now = from ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dow = today.weekday;
  final offset = dow == 7 ? 6 : dow - 1;
  final thisMonday = today.subtract(Duration(days: offset));
  return thisMonday.add(const Duration(days: 7));
}
