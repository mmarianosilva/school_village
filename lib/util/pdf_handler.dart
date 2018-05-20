import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class PdfHandler {
  static const platform = const MethodChannel('schoolvillage.app/pdf_view');
  static FirebaseStorage storage = new FirebaseStorage(storageBucket: 'gs://schoolvillage-1.appspot.com');

  static showPdfFromUrl(BuildContext context, String url) async {

    final FirebaseStorage storage = new FirebaseStorage();
    var bytes = utf8.encode(url); // data being hashed
    var digest = sha256.convert(bytes);
    final Directory systemTempDir = await getApplicationDocumentsDirectory();
    final path = "${systemTempDir.path}/$digest.pdf";
    print(path);

    final File tempFile = new File(path);

    if (!tempFile.existsSync()) {
      showLoading(context);
      final StorageReference ref = storage.ref().child(url);
      await tempFile.create();
      assert(await tempFile.readAsString() == "");
      final StorageFileDownloadTask task = ref.writeToFile(tempFile);
      final int byteCount = (await task.future).totalByteCount;
      print(byteCount);
      print("Done Downloading");
      hideLoading(context);
    }


    Future<Null> _showPdf() async {
      try {
        final int result = await platform.invokeMethod('viewPdf', path);
      } on PlatformException catch (e) {
      }
    }
    _showPdf();
  }

  static void showLoading(BuildContext context) {
    var alert = new AlertDialog(
      title: new Text("Downloading Document"),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new SizedBox(width: 12.0),
          new Expanded(child: new Text("Please wait.."))
        ],
      ),
    );
    showDialog(context: context, child: alert);
    // TODO Move to builder
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }
}