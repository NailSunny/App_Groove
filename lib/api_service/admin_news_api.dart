import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:groove_app/api_DTOs/news_banner_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;

Future<List<NewsBannerDto>> fetchAdminNewsBanners() async {
  final headers = await adminAuthHeaders();
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/news-banners'),
    headers: headers,
  );
  await checkAdminHttpResponse(response);
  final list = jsonDecode(response.body) as List<dynamic>;
  return list
      .map((e) => NewsBannerDto.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<NewsBannerDto> createAdminNewsBanner({
  required String filePath,
  required int displayOrder,
  required bool isActive,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/api/admin/news-banners'),
  );
  final headers = await adminAuthHeaders();
  request.headers.addAll(headers);
  request.fields['displayOrder'] = displayOrder.toString();
  request.fields['isActive'] = isActive.toString();
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  await checkAdminHttpResponse(response, 201);
  return NewsBannerDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<NewsBannerDto> updateAdminNewsBanner({
  required int id,
  String? filePath,
  required int displayOrder,
  required bool isActive,
}) async {
  final request = http.MultipartRequest(
    'PUT',
    Uri.parse('${ApiConfig.baseUrl}/api/admin/news-banners/$id'),
  );
  final headers = await adminAuthHeaders();
  request.headers.addAll(headers);
  request.fields['displayOrder'] = displayOrder.toString();
  request.fields['isActive'] = isActive.toString();
  if (filePath != null) {
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  await checkAdminHttpResponse(response);
  return NewsBannerDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<void> deleteAdminNewsBanner(int id) async {
  final headers = await adminAuthHeaders();
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api/admin/news-banners/$id'),
    headers: headers,
  );
  await checkAdminHttpResponse(response, 204);
}

Future<String?> pickBannerImagePath() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    withData: false,
  );
  if (result == null || result.files.isEmpty) return null;
  return result.files.single.path;
}
