import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;
import 'package:groove_app/api_DTOs/user_dto.dart';

Future<UserDto?> fetchUserById(int id) async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/users/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return UserDto.fromJson(jsonDecode(response.body));
  } else {
    return null;
  }
}

Future<UserDto?> fetchMyProfile() async {
  final token = await getToken();
  if (token == null || token.isEmpty) return null;

  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return UserDto.fromJson(jsonDecode(response.body));
  } else {
    return null;
  }
}

Future<bool> updateMyProfile(UserDto user) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(
      user.toUpdateJson(),
    ), // метод toUpdateJson должен игнорировать id
  );
  return response.statusCode == 200;
}

Future<String?> uploadPhoto(File imageFile) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo');
  final request = http.MultipartRequest('POST', uri);
  final token = await getToken();
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr); // ✅ теперь data['url'] существует
    return data['url'];
  } else {
    print('Ошибка загрузки фото (multipart): ${response.statusCode}');
    return null;
  }
}

Future<String?> uploadPhotoBytes(Uint8List bytes) async {
  final token = await getToken();
  final base64Image = base64Encode(bytes);

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo-base64'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'base64Image': base64Image, 'fileExtension': 'jpg'}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['url'];
  }
  print('Ошибка загрузки фото (base64): ${response.statusCode}');
  return null;
}

Future<bool> topUpUserBalance(int amount) async {
  final token = await getToken();

  final url = Uri.parse('${ApiConfig.baseUrl}/api/balance/topup');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 🔥 обязательно
    },
    body: jsonEncode({'amount': amount}),
  );

  return response.statusCode == 200;
}
