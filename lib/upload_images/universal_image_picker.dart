import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'universal_image_picker_stub.dart'

  if (dart.library.html) 'universal_image_picker_web.dart'
  if (dart.library.io) 'universal_image_picker_mobile.dart';

Future<Uint8List?> pickImage(Function(String photoUrl) onPhotoUploaded) {
  return pickImagePlatform(onPhotoUploaded);
}
