import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/followup/followup.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetail extends StatelessWidget {
  final SchoolAlert notification;

  String _staticMapKey = "AIzaSyAbuIElF_ufTQ_NRdSz3z-0Wm21H6GQDQI";
  String title = 'Notification';

  NotificationDetail({Key key, this.notification, this.title})
      : super(key: key);

  _showCallOptions(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contact Reporter'),
            content: Text(
                "Do you want to contact ${notification.reportedByPhoneFormatted} ?"),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('SMS'),
                onPressed: () {
                  Navigator.of(context).pop();
                  launch(Uri.encodeFull("sms:${notification.reportedByPhone}"));
                },
              ),
              FlatButton(
                child: Text('Phone'),
                onPressed: () {
                  Navigator.of(context).pop();
                  launch(Uri.encodeFull("tel:${notification.reportedByPhone}"));
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    print("Width: $width Height: $height");

    if (height < width) {
      height = height / 3;
    } else {
      height = height / 2;
    }

    int iwidth = width.ceil();
    int iheight = height.ceil();

    if (notification != null && notification.location != null) {
      widgets.add(GestureDetector(
        onTap: () {
          launch(
              "https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${notification.location.latitude},${notification.location.longitude}");
        },
        child: Image.network(
            "https://maps.googleapis.com/maps/api/staticmap?center=${notification.location.latitude},${notification.location.longitude}&zoom=18&markers=color:red%7Clabel:A%7C${notification.location.latitude},${notification.location.longitude}&size=${iwidth}x$iheight&maptype=hybrid&key=$_staticMapKey"),
      ));
    }
    widgets.add(Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(notification.title == null ? 'Details' : notification.title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 8.0,
          ),
          Text(notification.body),
          SizedBox(
            height: 8.0,
          ),
          Text("Reported by ${notification.createdBy}"),
          SizedBox(
            height: 8.0,
          ),
          Text(
              "Reported at ${dateFormatting.messageDateFormatter.format(notification.timestamp)}"),
          SizedBox(
            height: 16.0,
          ),
          (notification.reportedByPhone != null &&
                  notification.reportedByPhone.trim() != ''
              ? GestureDetector(
                  onTap: () => _showCallOptions(context),
                  child: Text("Contact",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).accentColor)))
              : SizedBox()),
          FlatButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    Followup('Alert Log', notification.firestorePath),
              ),
            ),
            child: Text(
              'Follow-up',
              style: TextStyle(color: Colors.blueAccent),
            ),
          )
        ],
      ),
    ));
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text('Details',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widgets));
  }
}
