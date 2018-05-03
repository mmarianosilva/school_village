import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfHandler {
  static const platform = const MethodChannel('schoolvillage.app/pdf_view');

  static showPdfFromUrl(BuildContext context, String url) {

    Future<Null> _showPdf() async {
      try {
        final int result = await platform.invokeMethod('viewPdf', "assets/pdf/safety.pdf");
      } on PlatformException catch (e) {
      }
    }
    _showPdf();
  }
}