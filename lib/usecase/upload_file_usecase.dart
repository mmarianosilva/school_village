import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class UploadFileUsecase {
  FirebaseStorage _storage = FirebaseStorage.instance;

  static void _handleUpload(UploadTask task, {Function(String) onComplete}) async {
    final TaskSnapshot result = await task;
    if (result.state == TaskState.success && onComplete != null) {
      final String url = await result.ref.getDownloadURL();
      onComplete(url);
    } else if (result.state == TaskState.error) {
      debugPrint('_handleUpload error');
    }
  }

  void uploadFile(String path, File file, {Function(String) onComplete}) {
    final Reference storagePath = _storage.ref().child('${path[0]}${path.substring(1)}');
    final UploadTask uploadTask = storagePath.putFile(file);
    _handleUpload(uploadTask, onComplete: onComplete);
  }
}