import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:school_village/util/user_helper.dart';

class FileHelper {
  static final Firestore firestore = Firestore.instance;
  static final FirebaseStorage storage = new FirebaseStorage();

  static Future<File> getFileFromStorage(
      {url: String, context: BuildContext}) async {
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

  static Future<void> downloadRequiredDocuments() async {
    final String schoolId = await UserHelper.getSelectedSchoolID();
    final String role = await UserHelper.getSelectedSchoolRole();
    final DocumentSnapshot school = await firestore.document(schoolId).get();
    final List<Map<String, dynamic>> documents = (school["documents"]
            .cast<Map<String, dynamic>>())
        .where((Map<String, dynamic> item) =>
            item["accessRoles"] == null || item["accessRoles"].contains(role))
        .toList();
    documents.forEach((Map<String, dynamic> document) {
      if (document["downloadOnLogin"] ?? false) {
        _downloadDocument(document);
      }
    });
  }

  static Future<void> _downloadDocument(Map<String, dynamic> document) async {
    if (document["type"] == "pdf") {
      final List<Map<String, dynamic>> connectedFiles =
      document["connectedFiles"] !=
          null
          ? document["connectedFiles"]
          .map<Map<String, dynamic>>(
              (untyped) => Map<String, dynamic>.from(untyped))
          .toList()
          : null;
      if (connectedFiles != null) {
        final String root = document["name"];
        await PdfHandler.preparePdfFromUrl(document["location"], document["name"], parent: root);
        final Iterable<Future> transfer = connectedFiles.map((file) =>
            PdfHandler.preparePdfFromUrl(file["url"], file["name"], parent: root));
        await Future.wait(transfer);
      } else {
        await PdfHandler.preparePdfFromUrl(document["location"], document["name"]);
      }
    } else if (document["type"] == "linked-pdf") {
      await PdfHandler.downloadLinkedPdf(document["location"]);
    }
  }
}
