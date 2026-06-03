import 'dart:convert';
import 'package:groove_app/api_DTOs/organization_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;

Future<ClientOrganizationDto> fetchClientOrganization() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/client/organization'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Не удалось загрузить контакты: ${response.statusCode}');
  }

  return ClientOrganizationDto.fromJson(
    jsonDecode(response.body) as Map<String, dynamic>,
  );
}
