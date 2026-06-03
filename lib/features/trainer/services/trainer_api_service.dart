import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/features/trainer/models/trainer_group_lesson.dart';
import 'package:groove_app/features/trainer/models/trainer_personal_lesson.dart';
import 'package:groove_app/features/trainer/models/trainer_profile.dart';
import 'package:groove_app/helper/jwt_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map<String, String> _authHeaders(String token) => {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

Future<List<TrainerGroupLesson>> getTrainerGroupSchedule({
  required DateTime date,
  required int trainerId,
}) async {
  final token = await getToken();
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/trainer/$trainerId/group?date=$dateStr',
  );
  final response = await http.get(uri, headers: _authHeaders(token ?? ''));

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => TrainerGroupLesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception('Ошибка загрузки группового расписания: ${response.statusCode}');
}

Future<List<TrainerPersonalLesson>> getTrainerPersonalSchedule({
  required DateTime date,
  required int trainerId,
}) async {
  final token = await getToken();
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/api/schedule/trainer/$trainerId/personal?date=$dateStr',
  );
  final response = await http.get(uri, headers: _authHeaders(token ?? ''));

  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => TrainerPersonalLesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception(
    'Ошибка загрузки персонального расписания: ${response.statusCode}',
  );
}

Future<TrainerProfile?> getTrainerProfile() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer/me'),
    headers: _authHeaders(token ?? ''),
  );

  if (response.statusCode == 200) {
    return TrainerProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
  return null;
}

Future<bool> updateTrainerProfile(TrainerProfile profile) async {
  final token = await getToken();
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer/me'),
    headers: _authHeaders(token ?? ''),
    body: jsonEncode(profile.toUpdateJson()),
  );
  return response.statusCode == 200;
}

Future<String?> uploadTrainerPhoto(File imageFile) async {
  final token = await getToken();
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo'),
  );
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr) as Map<String, dynamic>;
    return data['url'] as String?;
  }
  return null;
}

Future<String?> uploadTrainerPhotoBytes(Uint8List bytes) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo-base64'),
    headers: _authHeaders(token ?? ''),
    body: jsonEncode({
      'base64Image': base64Encode(bytes),
      'fileExtension': 'jpg',
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['url'] as String?;
  }
  return null;
}
