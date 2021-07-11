import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:school_village/util/user_helper.dart';

class FileHelper {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static Future<File> getFileFromStorage(
      {url: String, context: BuildContext}) async {
    var bytes = utf8.encode(url);
    var digest = sha256.convert(bytes);
    Directory systemTempDir = await getApplicationDocumentsDirectory();
    String path = "${systemTempDir.path}/$digest";
    final File file = new File(path);
    if (file.existsSync() && file.lengthSync() != 0) {
      return file;
    } else {
      final Reference ref = storage.ref().child(url);
      await file.create();
      assert(await file.readAsString() == "");
      final DownloadTask task = ref.writeToFile(file);
      final int byteCount = (await task).totalBytes;
      print(byteCount);
      print("Done Downloading");
    }
    return file;
  }

  static Future<void> downloadRequiredDocuments() async {
    final String schoolId = await UserHelper.getSelectedSchoolID();
    final String role = await UserHelper.getSelectedSchoolRole();
    if (schoolId == null || role == null) {
      return;
    }
    final DocumentSnapshot school = await firestore.doc(schoolId).get();
    if (school.data()["documents"] == null) {
      return;
    }
    final List<Map<String, dynamic>> documents = (school.data()["documents"]
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
        final String root = document["name"] ?? document["title"];
        await PdfHandler.preparePdfFromUrl(document["location"], document["name"] ?? document["title"], parent: root);
        final Iterable<Future> transfer = connectedFiles.map((file) =>
            PdfHandler.preparePdfFromUrl(file["url"], file["name"] ?? file["title"], parent: root));
        await Future.wait(transfer);
      } else {
        await PdfHandler.preparePdfFromUrl(document["location"], document["name"] ?? document["title"]);
      }
    } else if (document["type"] == "linked-pdf") {
      await PdfHandler.downloadLinkedPdf(document["location"], null);
    }
  }

  static Stream<TaskSnapshot> downloadStorageDocument(Map<String, dynamic> document) {
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
        final String root = document["name"] ?? document["title"];

      } else {
        final filename = (document["name"] ?? document["title"]).endsWith(".pdf") ? document["name"] ?? document["title"] : "${document["name"] ?? document["title"]}.pdf";
        return FirebaseStorage.instance.ref(document["location"]).writeToFile(filename).snapshotEvents;
      }
    } else if (document["type"] == "linked-pdf") {

    }
    return Stream.empty();
  }
}
