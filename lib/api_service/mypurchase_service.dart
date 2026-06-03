import 'dart:convert';

import 'package:groove_app/api_DTOs/mypurchase_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;

Future<List<PurchaseDto>> fetchPurchases(int userId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Purchase/user/$userId'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => PurchaseDto.fromJson(json as Map<String, dynamic>)).toList();
  }
  throw Exception('Не удалось загрузить покупки');
}

Future<String> cancelPurchase(int purchaseId) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/Purchase/$purchaseId/cancel'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message']?.toString() ?? 'Покупка отменена';
    } catch (_) {
      return 'Покупка отменена';
    }
  }

  try {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message']?.toString() ?? 'Не удалось отменить покупку');
  } catch (_) {
    throw Exception('Не удалось отменить покупку');
  }
}
