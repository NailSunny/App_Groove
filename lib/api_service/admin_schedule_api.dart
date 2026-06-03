import 'dart:convert';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchAdminGroupClasses(DateTime date) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group').replace(
    queryParameters: {'date': date.toIso8601String()},
  );
  final response = await http.get(uri, headers: headers);
  if (response.statusCode != 200) throw Exception(response.body);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> fetchAdminPersonalClasses(DateTime date) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/personal').replace(
    queryParameters: {'date': date.toIso8601String()},
  );
  final response = await http.get(uri, headers: headers);
  if (response.statusCode != 200) throw Exception(response.body);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> fetchGroupRegistrations(int groupClassId) async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group/$groupClassId/registrations'),
    headers: headers,
  );
  if (response.statusCode != 200) throw Exception(response.body);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<void> markGroupAttendance(int registryId, String attendance) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/group/registrations/$registryId/attendance'),
    headers: headers,
    body: jsonEncode({'attendance': attendance}),
  );
  if (response.statusCode != 200) throw Exception(response.body);
}

Future<void> markPersonalAttendance(int persClassId, String attendance) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/schedule/personal/$persClassId/attendance'),
    headers: headers,
    body: jsonEncode({'attendance': attendance}),
  );
  if (response.statusCode != 200) throw Exception(response.body);
}
