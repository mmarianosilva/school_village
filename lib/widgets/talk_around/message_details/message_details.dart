import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' ;
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/util/localizations/localization.dart';

class MessageDetail extends StatelessWidget {
  final Map<String, dynamic> notification;

  final String _staticMapKey = "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI";

  MessageDetail({Key key, this.notification}) : super(key: key);

  _showCallOptions(context) {
    showContactDialog(context, notification['createdBy'], notification['reportedByPhone']);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List();

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
          GestureDetector(
            onTap: () {
              launch("https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${notification["location"]["latitude"]},${notification["location"]["longitude"]}");
            },
            child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?center=${notification["location"]["latitude"]},${notification["location"]["longitude"]}&zoom=18&markers=color:red%7Clabel:A%7C${notification["location"]["latitude"]},${notification["location"]["longitude"]}&size=${iwidth}x$iheight&maptype=hybrid&key=$_staticMapKey"),
          )

      );
    }
    widgets.add(
        Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              notification['createdBy'] != null ?
              Text("${localize('Broadcast message from', context)} ${notification['createdBy']}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)) :
              Text("${localize('Message from', context)} ${notification['author']}", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0,),
              Text(notification["body"]),
              SizedBox(height: 8.0,),
              notification['createdBy'] != null ?
              Text("${localize('Created by', context)} ${notification['createdBy']}") :
              Text("${localize('Created by', context)} ${notification['author']}"),
              SizedBox(height: 8.0,),
              notification['createdAt'] != null ?
              Text("${localize('Created at', context)} ${dateFormatting.messageDateFormatter.format(DateTime.fromMillisecondsSinceEpoch(notification['createdAt']))}") :
              Text("${localize('Created at', context)} ${dateFormatting.messageDateFormatter.format(notification['timestamp'].toDate())}"),
              SizedBox(height: 16.0,),
//              (notification['reportedByPhone'] != null ? new GestureDetector(
//                  onTap: () => _showCallOptions(context),
//                  child: new Text(localize("Contact", context), style: new TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor))
//              ) : new SizedBox()),

            ],
          ),
        )
    );
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text(localize('Message', context),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widgets
        ));
  }
}