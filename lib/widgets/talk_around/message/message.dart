import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' ;
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
    if(!self) return _getMessageView(context);
    else return _getMyMessageView(context);
  }

  _getMessageView(context){
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
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(initial), backgroundColor: Colors.redAccent),
          ),
          new Flexible(child: new Column(
            children: <Widget>[
              locationWidget,
              new GestureDetector(
                child: new Container(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(name, style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(text),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text("${time.month}/${time.day} ${time.hour}:${time.minute}", style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                  decoration: new BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: new EdgeInsets.all(8.0),
                ),
                onTap: () {
                  goToDetails(context);
                },
              )
            ],
          )),
          new SizedBox(width: 32.0)
        ],
      ),
    );
  }

  goToDetails(context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new NotificationDetail(notification: message, title: 'Message Details'),
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