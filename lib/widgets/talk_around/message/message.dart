import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification/notification.dart';
import '../../../util/firebase_image_thumbnail.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.initial, this.timestamp, this.self, this.location, this.message, this.imageUrl});
  final String text;
  final String name;
  final String imageUrl;
  final String initial;
  final int timestamp;
  final bool self;
  final dynamic location;
  final DocumentSnapshot message;

  @override
  Widget build(BuildContext context) {
    return _getMessageView(context);
  }

  final dateFormatter = DateFormat('hh:mm a on MMM');

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
    } else {
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

  _getImage() {
    if(imageUrl == null || imageUrl.trim() == '') {
      return SizedBox();
    }
//    return Text("Image");
    return FireBaseImageThumbnail(reference: imageUrl, width: 160.0, height: 160.0);
  }

  _getMyMessageView(context) {
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(timestamp);

    Widget locationWidget = new SizedBox(width: 0.0, height: 0.0);
    if(location != null) {
      locationWidget = new GestureDetector(
        child: new Text("Map", textAlign: TextAlign.right),
        onTap: () {
          launch("https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${location["latitude"]},${location["longitude"]}");
        },
      );
    }
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.centerRight,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
        new SizedBox(width: 32.0),
          new Flexible(child: new Column(
            children: <Widget>[
              locationWidget,
              new GestureDetector(
                child: new Container(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _getImage(),
                      new Text(name, style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(text,textAlign: TextAlign.end,),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text("${time.month}/${time.day} ${time.hour}:${time.minute}", style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                  decoration: new BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: new EdgeInsets.all(8.0),
                ),
                onTap: () {
                  goToDetails(context);
                },
              )
            ],
          )
          ),
          new Container(
            margin: const EdgeInsets.only(left: 16.0),
            child: new CircleAvatar(child: new Text(initial), backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}
