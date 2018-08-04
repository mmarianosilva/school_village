import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHolder {
  final String date;
  final DocumentSnapshot message;

  MessageHolder(this.date, this.message);
}
