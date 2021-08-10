import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

@immutable
class IntradoMessage {
  IntradoMessage({
    this.session,
    this.message,
    this.messageId,
  });

  final String session;
  final String message;
  final String messageId;

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element("textMessageRequest", nest: () {
      builder.element("session", nest: () {
        builder.text(session);
      });
      builder.element("message", nest: () {
        builder.text(message);
      });
      builder.element("messageId", nest: () {
        builder.text(messageId);
      });
    });
    return builder.build().toXmlString(pretty: true);
  }
}



