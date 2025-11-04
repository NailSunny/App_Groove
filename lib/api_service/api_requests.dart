import 'package:groove_app/api_DTOs/login_dto.dart';
import 'package:groove_app/api_DTOs/register_dto.dart';
import 'package:groove_app/config/api_config.dart';import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> registerUser(RegisterDto user) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200) {
    return "Регистрация успешна";
  } else {
    final error = jsonDecode(response.body);
    return "Ошибка регистрации: ${error is String ? error : error.toString()}";
  }
}

Future<bool> checkEmailExists(String email) async {
  final response = await http.get(
    Uri.parse("${ApiConfig.baseUrl}/api/auth/email-exists?email=$email"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["exists"] as bool;
  } else {
    throw Exception("Ошибка проверки email: ${response.statusCode}");
  }
}

Future<String> loginUser(LoginDto user) async {
  final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/login");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200) {
    return response.body; // допустим, это токен или текст вроде LoggedIn_1
  } else if (response.statusCode == 401) {
    return "Неверный логин или пароль";
  } else {
    return "Ошибка сервера: ${response.statusCode}";
  }
}