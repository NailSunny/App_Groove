import 'dart:convert';

import 'package:groove_app/api_DTOs/cart_dto.dart';
import 'package:groove_app/api_DTOs/confirm_purchase_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<CartDto?> getCart(int userId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/cart/$userId'),
  );

  if (response.statusCode == 200) {
    return CartDto.fromJson(jsonDecode(response.body));
  } else {
    print('Ошибка загрузки корзины: ${response.statusCode}');
    return null;
  }
}

Future<bool> confirmPurchase(ConfirmPurchaseDto dto) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/ConfirmPurchase/confirm'); // Заменить адрес
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Ошибка при подтверждении покупки: ${response.body}');
    return false;
  }
}
