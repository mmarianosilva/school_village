import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:url_launcher/url_launcher.dart' ;

class NotificationDetail extends StatelessWidget {
  final DocumentSnapshot notification;

  String _staticMapKey = "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI";
  String title = 'Notification';

  NotificationDetail({Key key, this.notification, this.title}) : super(key: key);

  _showCallOptions(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Contact Reporter'),
            content: new Text("Do you want to contact ${notification['reportedByPhone']} ?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('SMS'),
                onPressed: () {
                  Navigator.of(context).pop();
                  launch(Uri.encodeFull("sms:${notification['reportedByPhone']}"));
                },
              ),
              new FlatButton(
                child: new Text('Phone'),
                onPressed: () {
                  Navigator.of(context).pop();
                  launch(Uri.encodeFull("tel:${notification['reportedByPhone']}"));
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    print("Width: $width Height: $height");

    if(height < width) {
      height = height/3;
    } else {
      height = height/2;
    }

    int iwidth = width.ceil();
    int iheight = height.ceil();

    print("Width: $iwidth Height: $iheight");
//    print("https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${notification["location"]["latitude"]},${notification["location"]["longitude"]}&center=${notification["location"]["latitude"]},${notification["location"]["longitude"]}");

    if(notification["location"] != null) {
      widgets.add(
        new GestureDetector(
          onTap: () {
            launch("https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${notification["location"]["latitude"]},${notification["location"]["longitude"]}");
          },
          child: new Image.network(
              "https://maps.googleapis.com/maps/api/staticmap?center=${notification["location"]["latitude"]},${notification["location"]["longitude"]}&zoom=18&markers=color:red%7Clabel:A%7C${notification["location"]["latitude"]},${notification["location"]["longitude"]}&size=${iwidth}x$iheight&maptype=hybrid&key=$_staticMapKey"),
        )
          
      );
    }
    widgets.add(
        new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(notification["title"] == null ? 'Details' : notification["title"], style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              new SizedBox(height: 8.0,),
              new Text(notification["body"]),
              new SizedBox(height: 8.0,),
              new Text("Reported by ${notification['createdBy']}"),
              new SizedBox(height: 8.0,),
              new Text("Reported at ${new DateTime.fromMillisecondsSinceEpoch(notification['createdAt'])}"),
              new SizedBox(height: 16.0,),
              (notification['reportedByPhone'] != null && notification['reportedByPhone'].trim() !='' ? new GestureDetector(
                  onTap: () => _showCallOptions(context),
                  child: new Text("Contact", style: new TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor))
              ) : new SizedBox()),

            ],
          ),
        )
    );
    return new Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: new BaseAppBar(
        title: new Text('Details',
          textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black)),
    backgroundColor: Colors.grey.shade200,
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