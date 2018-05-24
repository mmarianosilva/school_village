import 'package:flutter/material.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../../util/user_helper.dart';
import '../schoollist/school_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

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

  updateSchool() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    if(schoolId == null || schoolId == '') {
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

  @override
  Widget build(BuildContext context) {

    if(!isLoaded) {
      updateSchool();
    }

      return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          leading: new Image.asset('assets/images/logo.png'),
          backgroundColor: Colors.grey.shade400,
          elevation: 0.0,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.settings, color: Colors.grey.shade800),
              tooltip: 'Settings',
              onPressed: openSettings,
            )
          ],
        ),
        body: new Dashboard(),
      );
  }
}