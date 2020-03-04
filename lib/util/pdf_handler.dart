import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:school_village/util/localizations/localization.dart';

class PdfHandler {
  static const platform = const MethodChannel('schoolvillage.app/pdf_view');
  static FirebaseStorage storage = new FirebaseStorage();
  static bool _canceled;

  static showPdfFile(BuildContext context, String url, String name, {List<Map<String, dynamic>> connectedFiles}) async {
    String root;
    _canceled = false;
    if (connectedFiles != null) {
      root = name;
    }
    showLoading(context);
    final String pdfFilePath = await preparePdfFromUrl(context, url, name, parent: root);
    if (connectedFiles != null && connectedFiles.isNotEmpty) {
      final Iterable<Future> transfer = connectedFiles.map((file) =>
          preparePdfFromUrl(context, file["url"], file["name"], parent: root));
      await Future.wait(transfer);
    }
    if (!_canceled) {
      hideLoading(context);
      final Config config = Config();
      config.multiTabEnabled = true;
      PdftronFlutter.openDocument(pdfFilePath, config: config);
    }
  }

  static Future<String> preparePdfFromUrl(BuildContext context, String url, String name, {String parent}) async {
    final FirebaseStorage storage = new FirebaseStorage();
    final Directory systemTempDir = await getApplicationDocumentsDirectory();
    String path;
    if (!name.endsWith(".pdf")) {
      name = "$name.pdf";
    }
    if (parent != null) {
      path = "${systemTempDir.path}/$parent/$name";
    } else {
      path = "${systemTempDir.path}/$name";
    }
    print(path);

    final File tempFile = new File(path);

    if (!tempFile.existsSync()) {
      final StorageReference ref = storage.ref().child(url);
      await tempFile.create(recursive: true);
      assert(await tempFile.readAsString() == "");
      final StorageFileDownloadTask task = ref.writeToFile(tempFile);
      final int byteCount = (await task.future).totalByteCount;
      print(byteCount);
      print("Done Downloading");
    }
    return path;
  }

  static void showLoading(BuildContext context) {
    var alert = AlertDialog(
      title: Text(LocalizationHelper.of(context).localized("Downloading Document")),
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 12.0),
          Expanded(child: Text(LocalizationHelper.of(context).localized("Please wait..")))
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(LocalizationHelper.of(context).localized('Cancel').toUpperCase()),
          onPressed: () {
            _canceled = true;
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(context: context, barrierDismissible: false, builder: (context) => alert,);
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }
}
