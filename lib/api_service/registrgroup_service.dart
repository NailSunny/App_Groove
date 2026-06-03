import 'dart:convert';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

class RegisterGroupClassRequest {
  final int userId;
  final int groupClassId;
  final bool? useTrial;

  RegisterGroupClassRequest({
    required this.userId,
    required this.groupClassId,
    this.useTrial,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'groupClassId': groupClassId,
        if (useTrial != null) 'useTrial': useTrial,
      };
}

Future<String> registerToGroupClass(
  int userId,
  int groupClassId, {
  bool? useTrial,
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/RegistryGroup/group-class');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
      RegisterGroupClassRequest(
        userId: userId,
        groupClassId: groupClassId,
        useTrial: useTrial,
      ).toJson(),
    ),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return decoded['message'] ?? 'Ошибка';
  } else {
    throw Exception('Ошибка при записи');
  }
}
