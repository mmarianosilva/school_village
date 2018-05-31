import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDetail extends StatelessWidget {
  final DocumentSnapshot notification;

  String _staticMapKey = "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI";

  NotificationDetail({Key key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List();

    if(notification["location"] != null) {
      widgets.add(
          new Image.network(
              "https://maps.googleapis.com/maps/api/staticmap?center=${notification["location"]["latitude"]},${notification["location"]["longitude"]}&zoom=18&size=640x400&key=$_staticMapKey")
      );
    }
    widgets.add(
        new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(notification["title"], style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              new SizedBox(height: 8.0,),
              new Text(notification["body"]),
              new SizedBox(height: 8.0,),
              new Text("Reported by ${notification['createdBy']}"),
              new SizedBox(height: 8.0,),
              new Text("Reported at ${new DateTime.fromMillisecondsSinceEpoch(notification['createdAt'])}")
            ],
          ),
        )
    );
    return new Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: new AppBar(
        title: new Text('Notification',
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black)),
    backgroundColor: Colors.grey.shade400,
    elevation: 0.0,
    leading: new BackButton(color: Colors.grey.shade800),
    ),
    body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widgets
    ));
  }
}