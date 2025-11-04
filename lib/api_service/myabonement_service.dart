import 'dart:convert';

import 'package:groove_app/api_DTOs/myabonement_dto.dart';
import 'package:groove_app/config/api_config.dart';
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
