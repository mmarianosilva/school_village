import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class UploadFileUsecase {
  FirebaseStorage _storage = FirebaseStorage();

  static void _handleUpload(StorageUploadTask task, {Function(String) onComplete}) async {
    final StorageTaskSnapshot result = await task.onComplete;
    if (result.error == null && onComplete != null) {
      final String url = await result.ref.getDownloadURL();
      onComplete(url);
    } else {
      debugPrint('_handleUpload error');
      debugPrint('${result.error}');
    }
  }

  void uploadFile(String path, File file, {Function(String) onComplete}) {
    final StorageReference storagePath = _storage.ref().child('${path[0]}${path.substring(1)}');
    final StorageUploadTask uploadTask = storagePath.putFile(file);
    _handleUpload(uploadTask, onComplete: onComplete);
  }
}