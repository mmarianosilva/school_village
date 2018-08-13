import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static FirebaseStorage storage = new FirebaseStorage();

  static Future<File> getFileFromStorage({url: String, context: BuildContext}) async {
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    Directory systemTempDir = await getApplicationDocumentsDirectory();
    String path = "${systemTempDir.path}/$digest";
    final File file = new File(path);
    if (!file.existsSync()) {
      final StorageReference ref = storage.ref().child(url);
      await file.create();
      assert(await file.readAsString() == "");
      final StorageFileDownloadTask task = ref.writeToFile(file);
      final int byteCount = (await task.future).totalByteCount;
      print(byteCount);
      print("Done Downloading");
    }
    return file;
  }
}