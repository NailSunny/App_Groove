import 'dart:typed_data';
import 'dart:io';
import 'package:groove_app/config/api_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

Future<Uint8List?> pickImagePlatform(Function(String photoUrl) onPhotoUploaded) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final file = File(pickedFile.path);
  final bytes = await file.readAsBytes();

  // Отправляем фото на сервер
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/upload-photo');
  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    onPhotoUploaded(responseBody);
  } else {
    throw Exception('Ошибка загрузки: ${response.statusCode}');
  }

  return bytes;
}
