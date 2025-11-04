// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:groove_app/config/api_config.dart';

Future<Uint8List?> pickImagePlatform(Function(String photoUrl) onPhotoUploaded) async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  final completer = Completer<Uint8List?>();

  uploadInput.onChange.listen((event) async {
    final file = uploadInput.files?.first;
    if (file == null) return completer.complete(null);

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((event) async {
      final bytes = reader.result as Uint8List;

      final formData = html.FormData();
      formData.appendBlob('file', file, file.name);

      final request = html.HttpRequest();
      request.open('POST', '${ApiConfig.baseUrl}/api/users/upload-photo');
      request.send(formData);

      request.onLoadEnd.listen((_) {
        if (request.status == 200) {
          final photoUrl = request.responseText!;
          onPhotoUploaded(photoUrl);
        }
        completer.complete(bytes);
      });
    });
  });

  return completer.future;
}
