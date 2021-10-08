import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/widgets/home/dashboard/dashboard_scope_observer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/widgets/incident_report/incident_list.dart';
import 'package:school_village/widgets/notification/notification.dart';
import 'package:school_village/widgets/talk_around/message_details/message_details.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_home.dart';
import 'package:school_village/widgets/talk_around/talk_around_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';
import 'package:school_village/widgets/home/dashboard/dashboard.dart';
import 'package:school_village/widgets/settings/settings.dart' as settings;
import 'package:school_village/widgets/holine_list/hotline_list.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/schoollist/school_list.dart';
import 'package:school_village/util/token_helper.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
Future<File> copyLocalAsset(Directory localDir, String bundleDir,
    String assetName) async {
  final localAssetFile = File('${localDir.path}/$assetName');
  if (!(await localAssetFile.exists())) {
    final data = await rootBundle.load('$bundleDir/$assetName');
    final bytes = data.buffer.asUint8List();
    await localAssetFile.writeAsBytes(bytes, flush: true);
  }
  return localAssetFile;
}
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
  print("payload is ${message.notification.android.sound} and ${message.data['sound']}");
  if (!Platform.isIOS) {
    final audioPlugin = AudioPlayer();
    final bundleDir = 'assets/audio';
    final assetName = 'alarm.wav';
    final assetName2 = 'message.wav';
    final localDir = await getTemporaryDirectory();


    final _messageAlertAssetFile =
        (await copyLocalAsset(localDir, bundleDir, assetName2)).path;
    await audioPlugin.play(_messageAlertAssetFile, isLocal: true);
  }


  print("sound played");

  return null;

}
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

class _HomeState extends State<Home>
    with WidgetsBindingObserver, DashboardScopeObserver {
  static const platform = const MethodChannel('schoolvillage.app/audio');

  int index = 0;
  String title = "MarinaVillage";
  bool isLoaded = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _schoolId;
  String _token;
  AudioPlayer audioPlugin;
  String _localAssetFile;
  String _messageAlertAssetFile;
  Future playAlarm() async {
    if (((await SharedPreferences.getInstance()).getInt(
        Constants.lastAmberAlertTimestampKey) ?? 0) > DateTime
        .now()
        .millisecondsSinceEpoch - 3600000) {
      return playMessageAlert();
    }
    if (!Platform.isIOS) {
      await copyLocalAssets();
      await audioPlugin.play(_localAssetFile, isLocal: true);
    } else {
      platform.invokeMethod('playBackgroundAudio');
    }
    (await SharedPreferences.getInstance()).setInt(
        Constants.lastAmberAlertTimestampKey, DateTime
        .now()
        .millisecondsSinceEpoch);
  }

  Future<SchoolAlert> _checkIfAlertIsInProgress() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    CollectionReference alerts =
    FirebaseFirestore.instance.collection("${schoolId}/notifications");
    return await alerts
        .orderBy("createdAt", descending: true)
        .get()
        .then((result) {
      if (result.docs.isEmpty) {
        return null;
      }
      final DocumentSnapshot lastResolved = result.docs
          .firstWhere((doc) => doc["endedAt"] != null, orElse: () => null);
      final Timestamp lastResolvedTimestamp = lastResolved != null
          ? lastResolved["endedAt"]
          : Timestamp.fromMillisecondsSinceEpoch(0);
      result.docs.removeWhere((doc) =>
      doc["endedAt"] != null ||
          doc["createdAt"] < lastResolvedTimestamp.millisecondsSinceEpoch);
      final latestAlert = result.docs.isNotEmpty
          ? SchoolAlert.fromMap(
          result.docs.last.id, result.docs.last.reference.path,
          result.docs.last.data())
          : null;
      return latestAlert;
    });
  }

  @override
  void onDidPopScope() {
    checkNewSchool();
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

  Future<File> copyLocalAsset(Directory localDir, String bundleDir,
      String assetName) async {
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('on Message : ${message.toString()}');
        return _onNotification(message.data, true);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Got a message whilst in the onMessageOpenedApp!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        debugPrint('on Message : ${message.toString()}');
        return _onNotification(message.data, true);
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    Future<NotificationSettings> settings = _firebaseMessaging
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(token);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      stopSound();
    }
  }

  _onNotification(Map<String, dynamic> data,
      [bool appInForeground = false]) async {
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
      if (role == 'vendor' || role == 'boater' || role == 'maintenance') {
        return true;
      }
      playMessageAlert();
      return _showHotLineMessageDialog(message);
    } else if (message["type"] == "incident") {
      playMessageAlert();
      return _shoIncidentReportDialog(message);
    } else if (message["type"] == "alert") {
      String path =
          "schools/${message["schoolId"]}/notifications/${message["notificationId"]}";
      DocumentSnapshot alert = await FirebaseFirestore.instance.doc(path).get();
      if (Timestamp
          .now()
          .millisecondsSinceEpoch - alert["createdAt"] >
          7200000) {
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
        _openTalkAroundChannel(message);
      }
    }
    return _showItemDialog(message);
  }

  _openTalkAroundChannel(Map<String, dynamic> incomingMessageData) {
    final String escapedSchoolId = incomingMessageData["schoolId"];
    debugPrint(escapedSchoolId);
    debugPrint(incomingMessageData["conversationId"]);
    return FirebaseFirestore.instance
        .doc(
        "schools/$escapedSchoolId/messages/${incomingMessageData["conversationId"]}")
        .get()
        .then((data) async {
      debugPrint('Retrieved channelInformation information');
      debugPrint(data.data.toString());
      TalkAroundChannel channel;
      if (data["direct"] ?? false) {
        Stream<TalkAroundUser> membersStream =
        Stream.fromIterable(data.data()["members"]).asyncMap((userId) async {
          final DocumentSnapshot snapshot = await userId.get();
          return TalkAroundUser.fromMapAndGroup(
              snapshot,
              snapshot["associatedSchools"][escapedSchoolId] != null
                  ? snapshot["associatedSchools"][escapedSchoolId]["role"]
                  : "");
        });
        final List<TalkAroundUser> members = await membersStream.toList();
        channel = TalkAroundChannel.fromMapAndUsers(data, members);
      } else {
        channel = TalkAroundChannel.fromMapAndUsers(data, null);
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TalkAroundHome()),
              (route) => route.settings.name == '/home');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TalkAroundMessaging(
                    channel: channel,
                  )));
    });
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
              child: Text(localize('View Log')),
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
              child: Text(localize('Close')),
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
              child: Text(localize('View Log')),
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
              child: Text(localize('Close')),
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
    final DocumentSnapshot messageSnapshot = await FirebaseFirestore.instance
        .doc(
        "schools/${message['schoolId']}/broadcasts/${message['broadcastId']}")
        .get();
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
              child: Text(localize('View Details')),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MessageDetail(
                          notification: messageSnapshot.data(),
                        ),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text(localize('Close')),
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
                  child: Text(localize('Open')),
                  onPressed: () {
                    stopSound();
                    _openTalkAroundChannel(message);
                  },
                ),
                FlatButton(
                  child: Text(localize('Close')),
                  onPressed: () {
                    stopSound();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    var notificationId = message['notificationId'];
    var schoolId = message['schoolId'];
    DocumentSnapshot notification;
    notification = await FirebaseFirestore.instance
        .doc("/schools/$schoolId/notifications/$notificationId")
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
              child: Text(localize('View Details')),
              onPressed: () {
                stopSound();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationDetail(
                            notification: SchoolAlert.fromMap(
                                notification.id, notification.reference.path,
                                notification.data())),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text(localize('Close Alert')),
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
      MaterialPageRoute(builder: (context) => settings.Settings()),
    );
  }

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if (schools != null && schools.length < 2 && schools.isNotEmpty) {
      print("Only 1 School");
      var school = await FirebaseFirestore.instance.doc(schools[0]['ref'])
          .get();
      print(school.data()["name"]);
      await UserHelper.setSelectedSchool(
          schoolId: schools[0]['ref'],
          schoolName: school.data()["name"],
          schoolRole: schools[0]['role']);
      setState(() {
        title = school.data()["name"];
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
    String schoolId = await UserHelper.getSelectedSchoolID();
    if (schoolId == null || schoolId == '') {
      if ((await checkIfOnlyOneSchool())) {
        return;
      }
      print("Redirecting to Schools $_navigatedToSchoolList");

      if (!_navigatedToSchoolList) {
        _navigatedToSchoolList = true;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SchoolList()),
        );
        setState(() {
          isLoaded = true;
        });
      }
      return;
    }
    String schoolName = await UserHelper.getSchoolName();
    print("schoolName is $schoolName");
    setState(() {
      title = schoolName;
      isLoaded = true;
      _schoolId = schoolId;
    });
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
        if (!isLoaded) {
          model.refreshUserIfNull();
          print("Updating school");
          updateSchool();
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
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
          body: Dashboard(this),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}