import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickImageAsBase64() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (image == null) return null;
    return base64Encode(await image.readAsBytes());
  }

  Future<List<String>> pickMultipleImagesAsBase64() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 82,
      maxWidth: 1800,
    );
    return Future.wait(
      images.map((image) async => base64Encode(await image.readAsBytes())),
    );
  }
}
