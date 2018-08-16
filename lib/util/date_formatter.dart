import 'package:intl/intl.dart';

final headerDateFormatter = DateFormat('EEEE, MMMM dd, yyyy');
final messageDateFormatter = DateFormat('hh:mm a on MMM');

String getHeaderDate(millis) {
  var time = DateTime.fromMillisecondsSinceEpoch(millis);
  return headerDateFormatter.format(time);
}

String getMessageDate(millis) {
  var date = DateTime.fromMillisecondsSinceEpoch(millis);
  var suffix;
  var j = date.day % 10, k = date.day % 100;
  if (j == 1 && k != 11) {
    suffix = "st";
  } else if (j == 2 && k != 12) {
    suffix = "nd";
  } else if (j == 3 && k != 13) {
    suffix = "rd";
  } else {
    suffix = 'th';
  }
  return messageDateFormatter.format(date) + ' ${date.day}$suffix';
}
