import 'dart:convert';

import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<Map<String, dynamic>> fetchAdminWeekSchedule({
  required DateTime weekStart,
  String type = 'all',
}) async {
  final dateStr = DateFormat('yyyy-MM-dd').format(weekStart);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/admin/schedule/week?weekStart=$dateStr&type=$type',
  );
  final response = await http.get(uri, headers: await adminAuthHeaders());
  if (response.statusCode != 200) {
    throw Exception('Ошибка загрузки расписания: ${response.statusCode}');
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> validateAdminWeek(DateTime weekStart) async {
  final dateStr = DateFormat('yyyy-MM-dd').format(weekStart);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/admin/schedule/validate?weekStart=$dateStr',
  );
  final response = await http.post(uri, headers: await adminAuthHeaders());
  if (response.statusCode != 200) {
    throw Exception('Ошибка валидации');
  }
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> publishAdminWeek(DateTime weekStart) async {
  final dateStr = DateFormat('yyyy-MM-dd').format(weekStart);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/admin/schedule/publish?weekStart=$dateStr',
  );
  final response = await http.post(uri, headers: await adminAuthHeaders());
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200) {
    throw Exception(body['message'] as String? ?? 'Ошибка публикации');
  }
  return body;
}

DateTime adminSchedulingWeekStart([DateTime? from]) {
  final now = from ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dow = today.weekday;
  final offset = dow == 7 ? 6 : dow - 1;
  return today.subtract(Duration(days: offset)).add(const Duration(days: 7));
}

String _adminScheduleError(http.Response response) {
  if (response.body.isEmpty) return 'Ошибка ${response.statusCode}';
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is String) return decoded;
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
  } catch (_) {}
  return response.body;
}

Future<int> adminCreateGroupDraft(Map<String, dynamic> body) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group/draft');
  final response = await http.post(
    uri,
    headers: await adminAuthHeaders(),
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return data['id'] as int;
}

Future<void> adminUpdateGroupDraft(int id, Map<String, dynamic> body) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group/draft/$id');
  final response = await http.put(
    uri,
    headers: await adminAuthHeaders(),
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
}

Future<void> adminDeleteGroupDraft(int id) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group/draft/$id');
  final response = await http.delete(uri, headers: await adminAuthHeaders());
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
}

Future<int> adminCreatePersonalDraft(Map<String, dynamic> body) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/personal/draft');
  final response = await http.post(
    uri,
    headers: await adminAuthHeaders(),
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return data['id'] as int;
}

Future<void> adminUpdatePersonalDraft(int id, Map<String, dynamic> body) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/personal/draft/$id');
  final response = await http.put(
    uri,
    headers: await adminAuthHeaders(),
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
}

Future<void> adminDeletePersonalDraft(int id) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/personal/draft/$id');
  final response = await http.delete(uri, headers: await adminAuthHeaders());
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(_adminScheduleError(response));
  }
}
