import 'package:groove_app/helper/jwt_helper.dart';

Future<Map<String, String>> adminAuthHeaders() async {
  final token = await getToken();
  return {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}
