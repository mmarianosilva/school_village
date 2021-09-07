import 'dart:io';

import 'package:image_picker/image_picker.dart';

class SelectImageUsecase {
  Future<PickedFile> selectImage() async {
    return ImagePicker.platform.pickImage(source: ImageSource.gallery);
  }

  Future<PickedFile> selectVideo() async {
    return ImagePicker.platform.pickVideo(source: ImageSource.gallery);
  }

  Future<PickedFile> takeImage() async {
    return ImagePicker.platform.pickImage(source: ImageSource.camera);
  }

  Future<PickedFile> takeVideo() async {
    return ImagePicker.platform.pickVideo(source: ImageSource.camera);
  }
}