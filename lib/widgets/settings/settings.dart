import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../../util/constants.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String name = '';
  DocumentReference _user;
  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
    _email = user.email;
    _user = Firestore.instance.document('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user;
      setState(() {
        name =
        "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}";
        isLoaded = true;
      });
      print(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }

    return new Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: new AppBar(
        title: new Text('Settings',
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: new BackButton(color: Colors.grey.shade800),
      ),
      body: new Column(
        children: <Widget>[
          const SizedBox(height: 24.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                padding: EdgeInsets.all(8.0),
              ),
              new Text(name,
                  style: new TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 24.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton.icon(
                icon: const Icon(Icons.school, size: 32.0),
                label: new Text('Change School',
                    style: new TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  _auth.signOut().then((nothing) {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SchoolList()),
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton.icon(
                icon: const Icon(Icons.exit_to_app, size: 32.0),
                label: new Text('Logout',
                    style: new TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  UserHelper.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton(
                child: new Text('Version ${Constants.version}',
                    style: new TextStyle(
                        fontSize: 8.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
