import 'dart:convert';

import 'package:groove_app/api_DTOs/hall_rental_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;

Future<Map<String, String>> _clientHeaders() async {
  final token = await getToken();
  return {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

String _dateQuery(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Future<List<AvailableSlotDto>> fetchAvailableRentalSlots(DateTime date, {int? hallId}) async {
  final params = {'date': _dateQuery(date)};
  if (hallId != null) params['hallId'] = hallId.toString();

  final uri = Uri.parse('${ApiConfig.baseUrl}/api/hall-rentals/available-slots')
      .replace(queryParameters: params);

  final response = await http.get(uri, headers: await _clientHeaders());

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => AvailableSlotDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  final msg = _errorMessage(response.body, response.statusCode);
  throw Exception(msg);
}

Future<CreateHallRentalResultDto> createHallRental(CreateHallRentalDto dto) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/hall-rentals'),
    headers: await _clientHeaders(),
    body: jsonEncode(dto.toJson()),
  );

  if (response.statusCode == 200) {
    return CreateHallRentalResultDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  throw Exception(_errorMessage(response.body, response.statusCode));
}

Future<List<MyHallRentalDto>> fetchMyHallRentals() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/hall-rentals/my'),
    headers: await _clientHeaders(),
  );

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => MyHallRentalDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  throw Exception(_errorMessage(response.body, response.statusCode));
}

Future<void> cancelMyHallRental(int id) async {
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/hall-rentals/$id'),
    headers: await _clientHeaders(),
  );

  if (response.statusCode == 204 || response.statusCode == 200) return;

  throw Exception(_errorMessage(response.body, response.statusCode));
}

String _errorMessage(String body, int statusCode) {
  if (body.isEmpty) return 'Ошибка $statusCode';
  try {
    final decoded = jsonDecode(body);
    if (decoded is String) return decoded;
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
  } catch (_) {}
  return body;
}
