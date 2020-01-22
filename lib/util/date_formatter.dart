import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final DateFormat headerDateFormatter = DateFormat('EEEE, MMMM dd, yyyy');
final DateFormat messageDateFormatter = DateFormat('hh:mm a on MM/dd/yyyy');
final DateFormat timeFormatter = DateFormat("hh:mm a");
final DateFormat dateFormatter = DateFormat("MMM dd, yyyy", "en_US");

String getHeaderDate(millis) {
  var time = DateTime.fromMillisecondsSinceEpoch(millis);
  return headerDateFormatter.format(time);
}

String getMessageDate(Timestamp millis) {
  var date = millis.toDate();
  return messageDateFormatter.format(date);
}
