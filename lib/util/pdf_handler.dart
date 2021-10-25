import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/util/user_helper.dart';

class PdfHandler {
  static const platform = const MethodChannel('schoolvillage.app/pdf_view');
  static FirebaseStorage storage = FirebaseStorage.instance;
  static bool _canceled;

  static showPdfFile(BuildContext context, String url, String name,
      {List<Map<String, dynamic>> connectedFiles}) async {
    String root;
    _canceled = false;
    if (connectedFiles != null) {
      root = name;
    }
    showLoading(context);
    final String pdfFilePath = await preparePdfFromUrl(url, name, parent: root);
    if (connectedFiles != null && connectedFiles.isNotEmpty) {
      final Iterable<Future> transfer = connectedFiles.map(
          (file) => preparePdfFromUrl(file["url"], file["name"], parent: root));
      await Future.wait(transfer);
    }
    if (!_canceled) {
      hideLoading(context);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(pdfFilePath.split('/').last),
          ),
          body: PDFView(filePath: pdfFilePath),
        ),
      ));
    }
  }

  static Future<String> preparePdfFromUrl(String url, String name,
      {String parent}) async {
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

  static void showLoading(BuildContext context, {Stream<int> downloadStream}) {
    var alert = AlertDialog(
      title: Text(
          LocalizationHelper.of(context).localized("Downloading Document")),
      content: Row(
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(width: 12.0),
          Expanded(
              child: downloadStream != null
                  ? StreamBuilder<int>(
                      stream: downloadStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text("${snapshot.data}% completed");
                        } else if (snapshot.hasError) {
                          return const Text(
                              "An error has been encountered. Please try again.");
                        }
                        return const SizedBox.shrink();
                      })
                  : Text(LocalizationHelper.of(context)
                      .localized("Please wait..")))
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
              LocalizationHelper.of(context).localized('Cancel').toUpperCase()),
          onPressed: () {
            _canceled = true;
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => alert,
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<void> showLinkedPdf(
    BuildContext context,
    String documentId,
  ) async {
    final downloadStream = StreamController<int>();
    showLoading(context, downloadStream: downloadStream.stream);
    String localPdfPath = '';
    try {
      localPdfPath = await downloadLinkedPdf(documentId, downloadStream);
    } finally {
      downloadStream.close();
      hideLoading(context);
      if (localPdfPath.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(localPdfPath.split('/').last),
            ),
            body: PDFView(filePath: localPdfPath),
          ),
        ));
      }
    }
  }

  static Future<String> downloadLinkedPdf(
      String documentId, StreamController<int> dialogStream) async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    DocumentSnapshot pdfDocument = await FirebaseFirestore.instance
        .doc("$schoolId/linked-pdfs/$documentId")
        .get();
    if (pdfDocument != null) {
      final String storagePath =
          '${schoolId[0].toUpperCase()}${schoolId.substring(1)}/Documents/${pdfDocument["name"]}';
      final Reference pdfDirectory =
          FirebaseStorage.instance.ref().child(storagePath);
      final Directory systemTempDir = await getApplicationDocumentsDirectory();
      final String rootPath =
          '${systemTempDir.path}/${pdfDocument["name"]}';
      final ListResult list = await pdfDirectory.listAll();
      await list.items.forEach((fileRef) async {
        final String path = '$rootPath/${fileRef.name}';
        final File destination = await File(path).create(recursive: true);
        final pdfDownloadTask = fileRef.writeToFile(destination);
        final taskSubscription = pdfDownloadTask.snapshotEvents.listen((event) {
          if (event.state == TaskState.running) {
            final progress =
                (event.bytesTransferred / event.totalBytes * 100).toInt();
            if (dialogStream != null && !dialogStream.isClosed) {
              dialogStream.add(progress);
            }
          }
        });
        await pdfDownloadTask;
        taskSubscription.cancel();
      });
      return '$rootPath/${pdfDocument["root"].split('/').last}';
    }
    return null;
  }
}
