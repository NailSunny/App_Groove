import 'dart:convert';

import 'package:groove_app/api_DTOs/myabonement_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/auth_token.dart';
import 'package:http/http.dart' as http;

Future<List<UserAbonementDto>> fetchUserAbonements(int userId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/UserAbonement/$userId'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => UserAbonementDto.fromJson(e)).toList();
  } else {
    throw Exception('Не удалось загрузить абонементы');
  }
}

Future<String> freezeMembership(int activeId) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/memberships/$activeId/freeze'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  final body = json.decode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200) {
    return body['message'] as String? ?? 'Абонемент заморожен';
  }
  throw Exception(body['message'] as String? ?? 'Не удалось заморозить');
}

Future<String> unfreezeMembership(int activeId) async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/memberships/$activeId/unfreeze'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  final body = json.decode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200) {
    return body['message'] as String? ?? 'Абонемент разморожен';
  }
  throw Exception(body['message'] as String? ?? 'Не удалось разморозить');
}
