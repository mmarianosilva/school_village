import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:url_launcher/url_launcher.dart' ;

class MessageDetail extends StatelessWidget {
  final Map<String, dynamic> notification;

  String _staticMapKey = "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI";

  MessageDetail({Key key, this.notification}) : super(key: key);

  _showCallOptions(context) {
    showContactDialog(context, notification['createdBy'], notification['reportedByPhone']);
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
              notification['createdBy'] != null ?
              new Text("Broadcast message from ${notification['createdBy']}", style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)) :
              new Text("Message from ${notification['author']}", style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              new SizedBox(height: 8.0,),
              new Text(notification["body"]),
              new SizedBox(height: 8.0,),
              notification['createdBy'] != null ?
              new Text("Created by ${notification['createdBy']}") :
              new Text("Created by ${notification['author']}"),
              new SizedBox(height: 8.0,),
              notification['createdAt'] != null ?
              new Text("Created at ${dateFormatting.messageDateFormatter.format(new DateTime.fromMillisecondsSinceEpoch(notification['createdAt']))}") :
              new Text("Created at ${dateFormatting.messageDateFormatter.format(notification['timestamp'].toDate())}"),
              new SizedBox(height: 16.0,),
              (notification['reportedByPhone'] != null ? new GestureDetector(
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
          title: new Text('Message',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black, letterSpacing: 1.29)),
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