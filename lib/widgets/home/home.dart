import 'package:flutter/material.dart';
import './dashboard/dashboard.dart';
import '../settings/settings.dart';
import '../../util/user_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {

  int index = 0;
  String title = "School Village";

  openSettings() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Settings()),
    );
  }

  updateSchool() async {
    title = await UserHelper.getSchoolName();
  }

  @override
  Widget build(BuildContext context) {

    updateSchool();

    return new Scaffold(
      backgroundColor: Colors.grey.shade200,
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