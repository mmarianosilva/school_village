import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/widgets/notification/notification.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../holine_list/hotline_list.dart';
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
import 'package:flutter/services.dart' show MethodChannel, rootBundle;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class Choice {
  Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

List<Choice> choices = <Choice>[
//  Choice(title: 'Notifications', icon: Icons.notifications),
  Choice(title: 'Settings', icon: Icons.settings)
];

class _HomeState extends State<Home> {
  static const platform = const MethodChannel('schoolvillage.app/audio');

  int index = 0;
  String title = "School Village";
  bool isLoaded = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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
    final localAssetFile = (await copyLocalAsset(localDir, bundleDir, assetName)).path;
    _localAssetFile = localAssetFile;
    print(_localAssetFile);
  }

  Future<File> copyLocalAsset(Directory localDir, String bundleDir, String assetName) async {
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
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(token);
    });
  }

  _onNotification(Map<String, dynamic> message) {
    print('onNotification');
    platform.invokeMethod('playBackgroundAudio');
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
        return AlertDialog(
          title: Text(message['title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'])],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View All'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotLineList(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _goToSecurityChat(String conversationId) async {
    if (['school_admin', 'school_security'].contains((await UserHelper.getSelectedSchoolRole()))) {
      Navigator.push(
        context,
        MaterialPageRoute(
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
        return AlertDialog(
          title: Text(message['title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'])],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View All'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Messages(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close'),
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
    DocumentSnapshot notification;
    Firestore.instance.document("/schools/$schoolId/notifications/$notificationId").get().then((document) {
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
                    builder: (context) => NotificationDetail(notification: notification),
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
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if (schools.length == 1) {
      print("Only 1 School");
      var school = await Firestore.instance.document(schools[0]['ref']).get();
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

  var _navigatedToSchoolList = false;

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
      if (!_navigatedToSchoolList) {
        _navigatedToSchoolList = true;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SchoolList()),
        );
      }
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
    return ScopedModelDescendant<MainModel>(
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

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: BaseAppBar(
            title: Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
            leading: Container(
              padding: EdgeInsets.all(8.0),
              child: Image.asset('assets/images/logo.png'),
            ),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            actions: <Widget>[
              PopupMenuButton<Choice>(
                onSelected: _select,
                icon: Icon(Icons.more_vert, color: Colors.grey.shade800),
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(choice.icon, color: Colors.grey.shade800),
                          SizedBox(width: 8.0),
                          Text(choice.title)
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: Dashboard(),
        );
      },
    );
  }
}
