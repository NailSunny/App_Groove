import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:groove_app/api_DTOs/organization_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;

Future<OrganizationDto> fetchAdminOrganization() async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/organization'),
    headers: headers,
  );
  await checkAdminHttpResponse(response);
  return OrganizationDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<OrganizationDto> updateAdminOrganization({
  String? address,
  String? phone,
  String? vkUrl,
  String? logoPath,
}) async {
  final request = http.MultipartRequest(
    'PUT',
    Uri.parse('${ApiConfig.baseUrl}/api/admin/organization'),
  );
  final headers = await adminAuthHeaders();
  request.headers.addAll(headers);
  if (address != null) request.fields['address'] = address;
  if (phone != null) request.fields['phone'] = phone;
  if (vkUrl != null) request.fields['vkUrl'] = vkUrl;
  if (logoPath != null) {
    request.files.add(await http.MultipartFile.fromPath('logo', logoPath));
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  await checkAdminHttpResponse(response);
  return OrganizationDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<OrganizationHallDto> uploadAdminHallPhoto({
  required int hallId,
  required String filePath,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/api/admin/halls/$hallId/photo'),
  );
  final headers = await adminAuthHeaders();
  request.headers.addAll(headers);
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  await checkAdminHttpResponse(response);
  return OrganizationHallDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteAdminHallPhoto(int hallId) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/halls/$hallId/photo'),
    headers: headers,
  );
  await checkAdminHttpResponse(response, 204);
}

Future<String?> pickOrganizationImagePath() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: false,
  );
  if (result == null || result.files.isEmpty) return null;
  return result.files.single.path;
}
