import 'dart:typed_data';

Future<Uint8List?> pickImagePlatform(Function(String photoUrl) onPhotoUploaded) async {
  throw UnsupportedError('Загрузка изображения не поддерживается на этой платформе.');
}
