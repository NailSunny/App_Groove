import 'dart:convert';

import 'package:groove_app/api_DTOs/mypurchase_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<PurchaseDto>> fetchPurchases(int userId) async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Purchase/user/$userId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => PurchaseDto.fromJson(json)).toList();
  } else {
    throw Exception('Не удалось загрузить покупки');
  }
}
