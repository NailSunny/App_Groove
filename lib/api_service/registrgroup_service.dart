import 'dart:convert';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

class RegisterGroupClassRequest {
  final int userId;
  final int groupClassId;

  RegisterGroupClassRequest({required this.userId, required this.groupClassId});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'groupClassId': groupClassId,
      };
}

Future<String> registerToGroupClass(int userId, int groupClassId) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/RegistryGroup/group-class');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(RegisterGroupClassRequest(userId: userId, groupClassId: groupClassId)),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return decoded['message'] ?? 'Ошибка';
  } else {
    throw Exception('Ошибка при записи');
  }
}
