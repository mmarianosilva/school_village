import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class UploadFileUsecase {
  FirebaseStorage _storage = FirebaseStorage();

  Future<String> uploadFile(String path, File file) async {
    final StorageReference storagePath = _storage.ref().child('${path[0]}${path.substring(1)}');
    final StorageUploadTask uploadTask = storagePath.putFile(file);
    final StorageTaskSnapshot result = await uploadTask.onComplete;
    if (result.error == null) {
      final String url = await result.ref.getDownloadURL();
      return url;
    }
    return Future.error(PlatformException(code: '${result.error}'));
  }
}