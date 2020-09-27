import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/util/user_helper.dart';

class PdfHandler {
  static const platform = const MethodChannel('schoolvillage.app/pdf_view');
  static FirebaseStorage storage = FirebaseStorage.instance;
  static bool _canceled;

  static showPdfFile(BuildContext context, String url, String name, {List<Map<String, dynamic>> connectedFiles}) async {
    String root;
    _canceled = false;
    if (connectedFiles != null) {
      root = name;
    }
    showLoading(context);
    final String pdfFilePath = await preparePdfFromUrl(url, name, parent: root);
    if (connectedFiles != null && connectedFiles.isNotEmpty) {
      final Iterable<Future> transfer = connectedFiles.map((file) =>
          preparePdfFromUrl(file["url"], file["name"], parent: root));
      await Future.wait(transfer);
    }
    if (!_canceled) {
      hideLoading(context);
      final Config config = Config();
      config.multiTabEnabled = true;
      PdftronFlutter.openDocument(pdfFilePath, config: config);
    }
  }

  static Future<String> preparePdfFromUrl(String url, String name, {String parent}) async {
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

    final File tempFile = File(path);

    if (!tempFile.existsSync()) {
      final Reference ref = storage.ref().child(url);
      await tempFile.create(recursive: true);
      assert(await tempFile.readAsString() == "");
      final DownloadTask task = ref.writeToFile(tempFile);
      final int byteCount = (await task).totalBytes;
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

  static Future<void> showLinkedPdf(BuildContext context, String documentId) async {
    showLoading(context);
    String localPdfPath = '';
    try {
      localPdfPath = await downloadLinkedPdf(documentId);
    }
    finally {
      hideLoading(context);
      if (localPdfPath.isNotEmpty) {
        final Config config = Config();
        config.multiTabEnabled = true;
        PdftronFlutter.openDocument(localPdfPath, config: config);
      }
    }
  }

  static Future<String> downloadLinkedPdf(String documentId) async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    DocumentSnapshot pdfDocument = await FirebaseFirestore.instance.doc(
        "$schoolId/linked-pdfs/$documentId").get();
    if (pdfDocument != null) {
      final String storagePath = '${schoolId[0].toUpperCase()}${schoolId.substring(1)}/Documents/${pdfDocument.data()["name"]}';
      final Reference pdfDirectory = FirebaseStorage.instance.ref()
          .child(storagePath);
      final Directory systemTempDir = await getApplicationDocumentsDirectory();
      final String rootPath = '${systemTempDir.path}/${pdfDocument.data()["name"]}';
      final ListResult list = await pdfDirectory.listAll();
      await list.items.forEach((fileRef) async {
        final String path = '$rootPath/${fileRef.name}';
        final File destination = await File(path).create(recursive: true);
        DownloadTask pdfDownloadTask = fileRef.writeToFile(destination);
        await pdfDownloadTask;
      });
      return '$rootPath/${pdfDocument.data()["root"].split('/').last}';
    }
    return null;
  }
}
