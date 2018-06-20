import 'package:flutter/material.dart';
import 'package:school_village/widgets/notification/notification.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../notifications/notifications.dart';
import '../../util/user_helper.dart';
import '../schoollist/school_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../messages/messages.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Notifications', icon: Icons.notifications),
  const Choice(title: 'Settings', icon: Icons.settings)
];


class _HomeState extends State<Home> {

  int index = 0;
  String title = "School Village";
  bool isLoaded = false;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  Location _location = new Location();
  String _schoolId;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        if(message["type"] == "broadcast") {
         return  _showBroadcastDialog(message);
        }
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        if(message["type"] == "broadcast") {
          return  _showBroadcastDialog(message);
        }
        _showItemDialog(message);
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        if(message["type"] == "broadcast") {
          return  _showBroadcastDialog(message);
        }
        _showItemDialog(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
  }

  _showBroadcastDialog(Map<String, dynamic> message) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(message['title']),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message['body'])
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('View All'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new Messages(),
                  ),
                );
              },
            ),
            new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showItemDialog(Map<String, dynamic> message) async{
    var notificationId = message['notificationId'];
    var schoolId = message['schoolId'];
    debugPrint(message['notificationId']);
    DocumentSnapshot notification;
    Firestore.instance.document("/schools/$schoolId/notifications/$notificationId").get().then((document) {
      notification = document;
    });
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(message['title']),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message['body'])
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('View Details'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new NotificationDetail(notification: notification),
                  ),
                );
              },
            ),
            new FlatButton(
              child: new Text('Close Alert'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  openSettings() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Settings()),
    );
  }

  openNotifications() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Notifications()),
    );
  }

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if(schools.length == 1) {
      print("Only 1 School");
      var school = await Firestore.instance
          .document(schools[0]['ref'])
          .get();
      print(school.data["name"]);
      await UserHelper.setSelectedSchool(
        schoolId: schools[0]['ref'], schoolName: school.data["name"], schoolRole: schools[0]['role']);
      setState(() {
        title = school.data["name"];
        isLoaded = true;
        _schoolId = schools[0]['ref'];
      });
      return true;
    }
    return false;
  }

  checkNewSchool() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    if(schoolId == null || schoolId == '') return;
    if(schoolId != _schoolId) {
      String schoolName = await UserHelper.getSchoolName();
      setState(() {
        title = schoolName;
        isLoaded = false;
        _schoolId = schoolId;
      });
    }
  }

  updateSchool() async {
    print("updating schools");
    UserHelper.updateTopicSubscription();
    String schoolId = await UserHelper.getSelectedSchoolID();
    if(schoolId == null || schoolId == '') {
      if((await checkIfOnlyOneSchool())) {
        return;
      }
      print("Redirecting to Schools");
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new SchoolList()),
      );
      setState(() {
        isLoaded = true;
      });
      return;
    }
    String schoolName = await UserHelper.getSchoolName();
    setState(() {
      title = schoolName;
      isLoaded = true;
      _schoolId = schoolId;
    });
    _firebaseMessaging.requestNotificationPermissions();
  }

  void _select(Choice choice) {
    if(choice.title == "Settings") {
      openSettings();
    }
    if(choice.title == "Notifications") {
      openNotifications();
    }
  }

  _getLocationPermission() {
    try {
      _location.getLocation.then((location) {}).catchError((error) {});
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building Home $isLoaded");
    if(!isLoaded) {
      print("Updating school");
      updateSchool();
      _getLocationPermission();
    } else {
      checkNewSchool();
    }

      return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          leading: new Container(
            padding: new EdgeInsets.all(8.0),
            child: new Image.asset('assets/images/logo.png'),
          ),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          actions: <Widget>[
            new PopupMenuButton<Choice>(
              onSelected: _select,
              icon: new Icon(Icons.more_vert, color: Colors.grey.shade800),
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return new PopupMenuItem<Choice>(
                    value: choice,
                    child: new Row(
                      children: <Widget>[
                        new Icon(choice.icon, color: Colors.grey.shade800),
                        new SizedBox(width: 8.0),
                        new Text(choice.title)
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: new Dashboard(),
      );
  }


}