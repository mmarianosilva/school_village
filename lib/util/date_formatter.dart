import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final headerDateFormatter = DateFormat('EEEE, MMMM dd, yyyy');
final messageDateFormatter = DateFormat('hh:mm a on MM/dd/yyyy');

String getHeaderDate(millis) {
  var time = DateTime.fromMillisecondsSinceEpoch(millis);
  return headerDateFormatter.format(time);
}

String getMessageDate(Timestamp millis) {
  var date = millis.toDate();
  return messageDateFormatter.format(date);
}
