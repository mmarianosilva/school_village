import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification/notification.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.timestamp, this.self, this.location, this.message});

  final String text;
  final String name;
  final int timestamp;
  final bool self;
  final dynamic location;
  final DocumentSnapshot message;

  @override
  Widget build(BuildContext context) {
    return _getMessageView(context);
  }

  var dateFormatter = DateFormat('hh:mm a on MMM');

  _getFormattedDate() {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var suffix;
    var j = date.day % 10, k = date.day % 100;
    if (j == 1 && k != 11) {
      suffix = "st";
    } else if (j == 2 && k != 12) {
      suffix = "nd";
    } else if (j == 3 && k != 13) {
      suffix = "rd";
    }else{
      suffix = 'th';
    }
    return dateFormatter.format(date) + ' ${date.day}$suffix';
  }

  _getMessageView(context) {
    Widget locationWidget = SizedBox(width: 0.0, height: 0.0);
    if (location != null) {
      locationWidget = GestureDetector(
        child: Text(
          "Map",
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          launch(
              "https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${location["latitude"]},${location["longitude"]}");
        },
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: [
                        Text(name, style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
                        Container(
                          child: locationWidget,
                          margin: const EdgeInsets.only(left: 40.0),
                        )
                      ]),
                      Container(
                        child: Text(_getFormattedDate(), style: TextStyle(fontSize: 11.0)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(text),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
                onTap: () => goToDetails(context),
              )
            ],
          )),
          SizedBox(width: 32.0)
        ],
      ),
    );
  }

  goToDetails(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetail(notification: message, title: 'Message Details'),
      ),
    );
  }
}
