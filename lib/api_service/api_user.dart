import 'dart:convert';
import 'dart:io';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:groove_app/api_DTOs/user_dto.dart';



Future<UserDto?> fetchUserById(int id) async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/users/$id'));

  if (response.statusCode == 200) {
    return UserDto.fromJson(jsonDecode(response.body));
  } else {
    return null;
  }
}

Future<bool> updateUserProfile(int id, UserDto user) async {
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toUpdateJson()),
  );

  return response.statusCode == 200;
}

Future<String?> uploadPhoto(File imageFile) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo');
  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);
    return data['url']; // URL к изображению
  } else {
    print('Ошибка загрузки фото: ${response.statusCode}');
    return null;
  }
}

Future<bool> topUpUserBalance(int userId, int amount) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/balance/topup');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'amount': amount,
    }),
  );

  return response.statusCode == 200;
}
