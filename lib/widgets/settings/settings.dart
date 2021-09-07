import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/widgets/schoollist/school_list.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/token_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  String name = '';
  String _userId;
  String _version;
  String _build;

  getUserDetails(MainModel model) async {
    User user = await UserHelper.getUser();
    print("ID: ${user != null ? user.uid : ""}");
    DocumentSnapshot userSnapshot = await model.getUser();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
      _build = buildNumber;
      _version = version;
      _userSnapshot = userSnapshot;
      name = _userSnapshot != null
          ? "${_userSnapshot['firstName']} ${_userSnapshot['lastName']}"
          : "An error occurred while loading user data";
      isLoaded = true;
      _userId = user != null ? user.uid : "";
    });
  }

  _logout(context, MainModel model) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localize('Logging out')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(localize("Logging out"))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
    String token =
        (await SharedPreferences.getInstance()).getString("fcmToken");
    await PdfHandler.deletePdfFiles();
    await TokenHelper.deleteToken(token, _userId);
    await UserHelper.logout(token);
    model.setUser(null);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  navigateToSchoolList(BuildContext context) async {
    print('navigateToSchoolList');
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SchoolList()),
    );
    if (result ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      if (!isLoaded) {
        getUserDetails(model);
      }
      return Scaffold(
        appBar: BaseAppBar(
          title: Text(localize('Settings'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        backgroundColor: Colors.grey.shade100,
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            const SizedBox(height: 24.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                ),
                Text(name,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.location_on, size: 32.0),
                  label: Text(localize('Change Location'),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _auth.signOut().then((nothing) {
                      navigateToSchoolList(context);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.exit_to_app, size: 32.0),
                  label: Text(localize('Logout'),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _logout(context, model);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    child: Text('Version: $_version Build: $_build',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold)),
                    onLongPress: () async {
                      final token = await FirebaseMessaging().getToken();
                      if (token != null) {
                        await Clipboard.setData(ClipboardData(text: token));
                        final snackBar = SnackBar(
                          content: Text('Copied to clipboard:\n${token.substring(0, 10)}...'),
                          duration: const Duration(seconds: 3),
                        );
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      } else {
                        final snackBar = SnackBar(
                          content: Text('Unable to retrieve FCM token.'),
                          duration: const Duration(seconds: 3),
                        );
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
