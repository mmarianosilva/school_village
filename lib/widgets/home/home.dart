import 'package:flutter/material.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../notifications/notifications.dart';
import '../../util/user_helper.dart';
import '../schoollist/school_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.subscribeToTopic("eH0twSteQXFpNYRi9nzU-medical");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        _showItemDialog(message);
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        _showItemDialog(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
  }

  _showItemDialog(Map<String, dynamic> message) {
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
      var isOwner = false;
      if(schools[0]['role'] == 'SiteAdmin' || schools[0]['role'] == 'Owner') {
        isOwner = true;
      }
      UserHelper.subscribeToSchoolTopics(schools[0]['ref'], isOwner);
      return true;
    }
    return false;
  }

  updateSchool() async {
    print("updating schools");
    String schoolId = await UserHelper.getSelectedSchoolID();
    if(schoolId == null || schoolId == '') {
      if((await checkIfOnlyOneSchool())) {
        return;
      }
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

  @override
  Widget build(BuildContext context) {

    if(!isLoaded) {
      updateSchool();
    }

      return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          leading: new Container(
            padding: new EdgeInsets.all(8.0),
            child: new Image.asset('assets/images/logo.png'),
          ),
          backgroundColor: Colors.grey.shade400,
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