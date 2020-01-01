import 'dart:io';

import 'package:image_picker/image_picker.dart';

class SelectImageUsecase {
  Future<File> selectImage() async {
    return ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<File> selectVideo() async {
    return ImagePicker.pickVideo(source: ImageSource.gallery);
  }

  Future<File> takeImage() async {
    return ImagePicker.pickImage(source: ImageSource.camera);
  }

  Future<File> takeVideo() async {
    return ImagePicker.pickVideo(source: ImageSource.camera);
  }
}