import 'dart:convert';
import 'package:groove_app/api_DTOs/admin/abonement_admin_dto.dart';
import 'package:groove_app/api_DTOs/hall_rental_dto.dart';
import 'package:groove_app/api_DTOs/admin/client_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/purchase_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_DTOs/schedulegroup_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;

class AdminApiException implements Exception {
  final String message;
  final int? statusCode;
  AdminApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

String _parseErrorBody(String rawBody, int statusCode) {
  if (rawBody.isEmpty) return 'Ошибка $statusCode';
  try {
    final decoded = jsonDecode(rawBody);
    if (decoded is String) return decoded;
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map) {
        final messages = <String>[];
        for (final entry in errors.entries) {
          if (entry.value is List) {
            for (final item in entry.value as List) {
              messages.add(_mapFieldError(entry.key.toString(), item.toString()));
            }
          }
        }
        if (messages.isNotEmpty) return messages.join('\n');
      }
      if (decoded['title'] != null && decoded['title'].toString().isNotEmpty) {
        return decoded['title'].toString();
      }
      if (decoded['message'] != null) {
        return decoded['message'].toString();
      }
    }
  } catch (_) {}
  return rawBody;
}

String _mapFieldError(String field, String message) {
  final ruField = switch (field.toLowerCase()) {
    'email' => 'Email',
    'password' => 'Пароль',
    'familiatrainer' => 'Фамилия',
    'nametrainer' => 'Имя',
    _ => field,
  };
  if (message.toLowerCase().contains('e-mail address')) {
    return '$ruField: укажите корректный адрес (например user@mail.ru)';
  }
  return '$ruField: $message';
}

Future<void> _checkResponse(http.Response response, [int expected = 200]) async {
  if (response.statusCode == expected ||
      (expected == 200 && response.statusCode == 204)) return;
  throw AdminApiException(
    _parseErrorBody(response.body, response.statusCode),
    response.statusCode,
  );
}

Future<void> checkAdminHttpResponse(http.Response response, [int expected = 200]) =>
    _checkResponse(response, expected);

// --- Clients ---

Future<List<ClientAdminDto>> fetchClients({String? search}) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/clients').replace(
    queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
  );
  final response = await http.get(uri, headers: headers);
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => ClientAdminDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<ClientAdminDto> createClient(Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/clients'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response, 201);
  return ClientAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<ClientAdminDto> updateClient(int id, Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/clients/$id'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response);
  return ClientAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteClient(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/clients/$id'),
    headers: headers,
  );
  await _checkResponse(response, 204);
}

// --- Abonements ---

Future<List<AbonementAdminDto>> fetchAbonementsAdmin() async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Abonement/admin'),
    headers: headers,
  );
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => AbonementAdminDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<AbonementAdminDto> createAbonement(Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/Abonement'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response, 201);
  return AbonementAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<AbonementAdminDto> updateAbonement(int id, Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/Abonement/$id'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response);
  return AbonementAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteAbonement(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/Abonement/$id'),
    headers: headers,
  );
  await _checkResponse(response, 204);
}

Future<List<TypeClassDto>> fetchTypeClasses() async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/types'));
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => TypeClassDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<TypeClassAdminDto>> fetchTypesAdmin() async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/types'),
    headers: headers,
  );
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list
      .map((e) => TypeClassAdminDto(
            idType: e['id'] as int,
            nameType: e['name'] as String?,
            discription: e['description'] as String?,
          ))
      .toList();
}

Future<TypeClassAdminDto> createType(Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/types'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response, 201);
  return TypeClassAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<TypeClassAdminDto> updateType(int id, Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/types/$id'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response);
  return TypeClassAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteType(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/types/$id'),
    headers: headers,
  );
  await _checkResponse(response, 204);
}

// --- Trainers ---

Future<List<TrainerAdminDto>> fetchTrainers({String? search}) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/Trainer').replace(
    queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
  );
  final response = await http.get(uri, headers: headers);
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => TrainerAdminDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<TrainerAdminDto> createTrainer(Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response, 201);
  return TrainerAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> updateTrainer(int id, Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer/$id'),
    headers: headers,
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) {
    throw AdminApiException(
      _parseErrorBody(response.body, response.statusCode),
      response.statusCode,
    );
  }
}

Future<void> deleteTrainer(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer/$id'),
    headers: headers,
  );
  await _checkResponse(response, 204);
}

// --- Halls ---

Future<List<HallAdminDto>> fetchHalls() async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/halls'),
    headers: headers,
  );
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => HallAdminDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<HallAdminDto> createHall(Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/halls'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response, 201);
  return HallAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<HallAdminDto> updateHall(int id, Map<String, dynamic> body) async {
  final headers = await adminAuthHeaders();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/halls/$id'),
    headers: headers,
    body: jsonEncode(body),
  );
  await _checkResponse(response);
  return HallAdminDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteHall(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/halls/$id'),
    headers: headers,
  );
  await _checkResponse(response, 204);
}

// --- Purchases ---

Future<List<PurchaseAdminDto>> fetchPurchasesAdmin({
  DateTime? from,
  DateTime? to,
  String? search,
}) async {
  final headers = await adminAuthHeaders();
  final params = <String, String>{};
  if (from != null) params['from'] = from.toIso8601String();
  if (to != null) params['to'] = to.toIso8601String();
  if (search != null && search.isNotEmpty) params['search'] = search;
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/purchases').replace(queryParameters: params.isEmpty ? null : params);
  final response = await http.get(uri, headers: headers);
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list.map((e) => PurchaseAdminDto.fromJson(e as Map<String, dynamic>)).toList();
}

Future<void> cancelPurchase(int purchaseId) async {
  final headers = await adminAuthHeaders();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/purchases/$purchaseId/cancel'),
    headers: headers,
  );
  await _checkResponse(response);
}

// --- Hall rentals ---

String _dateOnly(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Future<List<AdminHallRentalDto>> fetchAdminHallRentals({
  required DateTime date,
  int? hallId,
}) async {
  final headers = await adminAuthHeaders();
  final params = <String, String>{'date': _dateOnly(date)};
  if (hallId != null) params['hallId'] = hallId.toString();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/hall-rentals')
      .replace(queryParameters: params);
  final response = await http.get(uri, headers: headers);
  await _checkResponse(response);
  final list = jsonDecode(response.body) as List;
  return list
      .map((e) => AdminHallRentalDto.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<void> cancelAdminHallRental(int id, {bool refund = true}) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/hall-rentals/$id')
      .replace(queryParameters: {'refund': refund.toString()});
  final response = await http.delete(uri, headers: headers);
  await _checkResponse(response, 204);
}
