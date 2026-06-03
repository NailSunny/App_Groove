import 'dart:convert';
import 'package:groove_app/api_DTOs/news_banner_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;

Future<List<ClientNewsBannerDto>> fetchClientNewsBanners() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/client/news-banners'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Не удалось загрузить баннеры: ${response.statusCode}');
  }

  final list = jsonDecode(response.body) as List<dynamic>;
  return list
      .map((e) => ClientNewsBannerDto.fromJson(e as Map<String, dynamic>))
      .toList();
}
