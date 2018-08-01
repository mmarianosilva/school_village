import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification/notification.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {this.text,
      this.name,
      this.initial,
      this.timestamp,
      this.self,
      this.location,
      this.message});

  final String text;
  final String name;
  final String initial;
  final int timestamp;
  final bool self;
  final dynamic location;
  final DocumentSnapshot message;

  @override
  Widget build(BuildContext context) {
    if (!self)
      return _getMessageView(context);
    else
      return _getMyMessageView(context);
  }

  _getMessageView(context) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Widget locationWidget = SizedBox(width: 0.0, height: 0.0);
    if (location != null) {
      locationWidget = GestureDetector(
        child: Text("Map", textAlign: TextAlign.right),
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
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
                child: Text(initial), backgroundColor: Colors.redAccent),
          ),
          Flexible(
              child: Column(
            children: <Widget>[
              locationWidget,
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name,
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(text),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                            "${time.month}/${time.day} ${time.hour}:${time
                                    .minute}",
                            style: TextStyle(
                                fontSize: 12.0, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
                onTap: () {
                  goToDetails(context);
                },
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
        builder: (context) =>
            NotificationDetail(notification: message, title: 'Message Details'),
      ),
    );
  }

  _getMyMessageView(context) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);

    Widget locationWidget = SizedBox(width: 0.0, height: 0.0);
    if (location != null) {
      locationWidget = GestureDetector(
        child: Text("Map", textAlign: TextAlign.right),
        onTap: () {
          launch(
              "https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${location["latitude"]},${location["longitude"]}");
        },
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.centerRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: 32.0),
          Flexible(
              child: Column(
            children: <Widget>[
              locationWidget,
              GestureDetector(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(name,
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold)),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          text,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                            "${time.month}/${time.day} ${time.hour}:${time
                                    .minute}",
                            style: TextStyle(
                                fontSize: 12.0, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                ),
                onTap: () {
                  goToDetails(context);
                },
              )
            ],
          )),
          Container(
            margin: const EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
                child: Text(initial), backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
