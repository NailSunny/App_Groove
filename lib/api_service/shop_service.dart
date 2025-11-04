import 'dart:convert';

import 'package:groove_app/api_DTOs/addcart_dto.dart';
import 'package:groove_app/api_DTOs/shop_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<Abonement>> fetchAbonements() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/abonement'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Abonement.fromJson(json)).toList();
  } else {
    throw Exception('Ошибка при загрузке абонементов');
  }
}

Future<bool> addToCart(AddToCartDto dto) async {
  print(
    "Отправка в корзину: userId=${dto.userId}, abonementId=${dto.abonementId}",
  );
  final url = Uri.parse('${ApiConfig.baseUrl}/api/cart/add');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print("Ошибка при добавлении в корзину: ${response.body}");
    return false;
  }
}

Future<bool> removeFromCart(AddToCartDto dto) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/cart/remove'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );

  return response.statusCode == 200;
}
