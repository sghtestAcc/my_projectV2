import 'dart:developer';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImage({ImageSource? source}) async {
  final picker = ImagePicker();
  String? path;

  try {
    final pickedFile = await picker.pickImage(source: source!);

    if (pickedFile != null) {
      path = pickedFile.path;
    }
  } catch (e) {
    log(e.toString());
  }

  return path;
}
