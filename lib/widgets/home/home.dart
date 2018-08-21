import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/widgets/notification/notification.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../holine_list/hotline_list.dart';
import '../notifications/notifications.dart';
import '../../util/user_helper.dart';
import '../schoollist/school_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../messages/messages.dart';
import '../../util/token_helper.dart';
import '../talk_around/talk_around.dart';
import '../../model/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

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
//  const Choice(title: 'Notifications', icon: Icons.notifications),
  const Choice(title: 'Settings', icon: Icons.settings)
];

class _HomeState extends State<Home> {
  int index = 0;
  String title = "School Village";
  bool isLoaded = false;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String _schoolId;
  String _token;
  AudioPlayer audioPlugin;
  String _localAssetFile;

  Future playAlarm() async {
    await copyLocalAssets();
    await audioPlugin.play(_localAssetFile, isLocal: true);
  }

  copyLocalAssets() async {
    final bundleDir = 'assets/audio';
    final assetName = 'alarm.wav';
    final localDir = await getApplicationDocumentsDirectory();
    final localAssetFile =
        (await copyLocalAsset(localDir, bundleDir, assetName)).path;
    _localAssetFile = localAssetFile;
    print(_localAssetFile);
  }

  Future<File> copyLocalAsset(
      Directory localDir, String bundleDir, String assetName) async {
    final localAssetFile = File('${localDir.path}/$assetName');
    if (!(await localAssetFile.exists())) {
      final data = await rootBundle.load('$bundleDir/$assetName');
      final bytes = data.buffer.asUint8List();
      await localAssetFile.writeAsBytes(bytes, flush: true);
    }
    return localAssetFile;
  }

  @override
  void initState() {
    super.initState();
    audioPlugin = AudioPlayer();
    TokenHelper.saveToken();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        _onNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        _onNotification(message);
      },
      onResume: (Map<String, dynamic> message) {
        _onNotification(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(token);
    });
  }

  _onNotification(Map<String, dynamic> message) {
    message.forEach((key, value){
      print('key = $key | value = $value');
    });
    playAlarm();

    if (message["type"] == "broadcast") {
      return _showBroadcastDialog(message);
    } else if (message["type"] == "security") {
      return _goToSecurityChat(message['conversationId']);
    } else if (message["type"] == "hotline") {
      return _showHotLineMessageDialog(message);
    }
    _showItemDialog(message);
  }

  _showHotLineMessageDialog(message) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(message['title']),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[new Text(message['body'])],
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
                    builder: (context) => new HotLineList(),
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

  _goToSecurityChat(String conversationId) async{
    if (['school_admin', 'school_security']
        .contains((await UserHelper.getSelectedSchoolRole()))) {
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => TalkAround(conversationId: conversationId),
        ),
      );
    }
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
              children: <Widget>[new Text(message['body'])],
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

  _showItemDialog(Map<String, dynamic> message) async {
    playAlarm();
    var notificationId = message['notificationId'];
    var schoolId = message['schoolId'];
    debugPrint(message['notificationId']);
    DocumentSnapshot notification;
    Firestore.instance
        .document("/schools/$schoolId/notifications/$notificationId")
        .get()
        .then((document) {
      notification = document;
    });
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message['title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'])],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View Details'),
              onPressed: () {
                audioPlugin.stop();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        new NotificationDetail(notification: notification),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close Alert'),
              onPressed: () {
                audioPlugin.stop();
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

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if (schools.length == 1) {
      print("Only 1 School");
      var school = await Firestore.instance.document(schools[0]['ref']).get();
      print(school.data["name"]);
      await UserHelper.setSelectedSchool(
          schoolId: schools[0]['ref'],
          schoolName: school.data["name"],
          schoolRole: schools[0]['role']);
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
    if (schoolId == null || schoolId == '') return;
    if (schoolId != _schoolId) {
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
//    UserHelper.updateTopicSubscription();
    String schoolId = await UserHelper.getSelectedSchoolID();
    if (schoolId == null || schoolId == '') {
      if ((await checkIfOnlyOneSchool())) {
        return;
      }
      print("Redirecting to Schools");

      setState(() {
        isLoaded = true;
      });
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new SchoolList()),
      );
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
    if (choice.title == "Settings") {
      openSettings();
    }
  }



  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        model.setToken(_token);
        print("Building Home $isLoaded");
        if (!isLoaded) {
          model.refreshUserIfNull();
          print("Updating school");
          updateSchool();
        } else {
          checkNewSchool();
        }

        return new Scaffold(
          backgroundColor: Colors.white,
          appBar: new BaseAppBar(
            title: new Text(title,
                textAlign: TextAlign.center,
                style: new TextStyle(color: Colors.black)),
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
      },
    );
  }
}
