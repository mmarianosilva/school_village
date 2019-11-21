import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/widgets/incident_report/incident_list.dart';
import 'package:school_village/widgets/notification/notification.dart';
import 'package:school_village/widgets/talk_around/message_details/message_details.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_home.dart';
import 'package:school_village/widgets/talk_around/talk_around_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../holine_list/hotline_list.dart';
import '../../util/user_helper.dart';
import '../schoollist/school_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/token_helper.dart';
import '../../model/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:audioplayers/audioplayers.dart';
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
  String _messageAlertAssetFile;

  Future playAlarm() async {
    if (!Platform.isIOS) {
      await copyLocalAssets();
      await audioPlugin.play(_localAssetFile, isLocal: true);
    } else {
      platform.invokeMethod('playBackgroundAudio');
    }
  }

  Future<SchoolAlert> _checkIfAlertIsInProgress() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    CollectionReference alerts = Firestore.instance.collection("${schoolId}/notifications");
    return await alerts.orderBy("createdAt", descending: true).getDocuments().then((result) {
      if (result.documents.isEmpty) {
        return null;
      }
      final DocumentSnapshot lastResolved = result.documents.firstWhere((doc) => doc["endedAt"] != null, orElse: () => null);
      final Timestamp lastResolvedTimestamp = lastResolved != null ? lastResolved["endedAt"] : Timestamp.fromMillisecondsSinceEpoch(0);
      result.documents.removeWhere((doc) => doc["endedAt"] != null || doc["createdAt"] < lastResolvedTimestamp.millisecondsSinceEpoch);
      final latestAlert = result.documents.isNotEmpty ? SchoolAlert.fromMap(result.documents.last) : null;
      return latestAlert;
    });
  }

  stopSound() {
    if (Platform.isIOS) {
      platform.invokeMethod('stopBackgroundAudio');
    } else {
      audioPlugin.stop();
    }
  }

  Future playMessageAlert() async {
    await copyLocalAssets();
    await audioPlugin.play(_messageAlertAssetFile, isLocal: true);
  }

  copyLocalAssets() async {
    final bundleDir = 'assets/audio';
    final assetName = 'alarm.wav';
    final assetName2 = 'message.wav';
    final localDir = await getTemporaryDirectory();
    _localAssetFile =
        (await copyLocalAsset(localDir, bundleDir, assetName)).path;

    _messageAlertAssetFile =
        (await copyLocalAsset(localDir, bundleDir, assetName2)).path;
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
        return _onNotification(message, true);
      },
      onLaunch: (Map<String, dynamic> message) {
        return _onNotification(message);
      },
      onResume: (Map<String, dynamic> message) {
        return _onNotification(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(token);
    });
  }

  _onNotification(Map<String, dynamic> data, [bool appInForeground = false]) async {
    Map<String, dynamic> message;

    if (data["data"] != null) {
      message = new Map<String, dynamic>.from(data["data"]);
    } else {
      message = data;
    }

    debugPrint('Incoming notification payload: ');
    debugPrint(message.toString());

    if (message["type"] == "broadcast") {
      bool alarm = message.toString().contains("sound: alarm.wav");
      if (alarm) {
        playAlarm();
      } else {
        playMessageAlert();
      }
      return _showBroadcastDialog(message);
    } else if (message["type"] == "hotline") {
      String role = await UserHelper.getSelectedSchoolRole();
      if (role == 'school_student' || role == 'school_family') {
        return true;
      }
      playMessageAlert();
      return _showHotLineMessageDialog(message);
    } else if (message["type"] == "incident") {
      playMessageAlert();
      return _shoIncidentReportDialog(message);
    } else if (message["type"] == "alert") {
      String path = "schools/${message["schoolId"]}/notifications/${message["notificationId"]}";
      DocumentSnapshot alert = await Firestore.instance.document(path).get();
      if (Timestamp.now().millisecondsSinceEpoch - alert["createdAt"] > 7200000) {
        return true;
      }
      SchoolAlert latestAlert = await _checkIfAlertIsInProgress();
      if (latestAlert != null && latestAlert.id != message["notificationId"]) {
        playMessageAlert();
      } else {
        playAlarm();
      }
      return _showItemDialog(message);
    } else if (message["type"] == "talkaround") {
      playMessageAlert();
      if (!appInForeground) {
        final String escapedSchoolId = message["schoolId"];
        return Firestore
            .instance
            .document(
            "schools/$escapedSchoolId/messages/${message["conversationId"]}")
            .get()
            .then((data) async {
          Stream<TalkAroundUser> membersStream = Stream.fromIterable(
              data["members"]).asyncMap((userId) async {
            final DocumentSnapshot snapshot = await userId.get();
            return TalkAroundUser.fromMapAndGroup(snapshot,
                snapshot.data["associatedSchools"][escapedSchoolId] != null
                    ? snapshot
                    .data["associatedSchools"][escapedSchoolId]["role"]
                    : "");
          });
          final List<TalkAroundUser> members = await membersStream.toList();
          final TalkAroundChannel channel = TalkAroundChannel.fromMapAndUsers(
              data, members);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TalkAroundHome()),
                  (route) => route.settings.name == '/home');
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => TalkAroundMessaging(channel: channel,)));
        });
      }
    }
    return _showItemDialog(message);
  }

  _shoIncidentReportDialog(message) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message['title'] ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'] ?? '')],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View All'),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentList(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showHotLineMessageDialog(message) {
    print(message);
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message['title'] ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'] ?? '')],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View All'),
              onPressed: () {
                stopSound();
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
                stopSound();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showBroadcastDialog(Map<String, dynamic> message) async {
    final DocumentSnapshot messageSnapshot = await Firestore.instance.document("schools/${message['schoolId']}/broadcasts/${message['broadcastId']}").get();
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message['title'] ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body'] ?? '')],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View Details'),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageDetail(notification: messageSnapshot.data,),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showItemDialog(Map<String, dynamic> message) async {
    if (message['type'] == "talkaround") {
      return showDialog<Null>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(message['title'] ?? ""),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[Text(message['body']) ?? ''],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      stopSound();
                      Navigator.of(context).pop();
                    },
                  )
                ],
            );
          }
      );
    }
    var notificationId = message['notificationId'];
    var schoolId = message['schoolId'];
    DocumentSnapshot notification;
    notification = await Firestore.instance
        .document("/schools/$schoolId/notifications/$notificationId")
        .get();
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message['title'] ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message['body']) ?? ''],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('View Details'),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationDetail(notification: SchoolAlert.fromMap(notification)),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('Close Alert'),
              onPressed: () {
                stopSound();
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
    stopSound();
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
            title: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
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
