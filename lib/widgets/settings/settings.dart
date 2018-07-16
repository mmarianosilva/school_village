import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../../util/constants.dart';
import '../../model/main_model.dart';
import '../../util/token_helper.dart';
import 'package:scoped_model/scoped_model.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  String name = '';
  String _userId;

  getUserDetails(MainModel model) async {
    FirebaseUser user = await UserHelper.getUser();
    print("ID: " + user.uid);
    DocumentSnapshot userSnapshot = await model.getUser();
    setState(() {
      _userSnapshot = userSnapshot;
      name =
      "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}";
      isLoaded = true;
      _userId = user.uid;
    });
  }
  
  _logout(context, MainModel model) async{
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Logging out'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new CircularProgressIndicator(),
                    new Text("Logging out")
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
    String token = model.getToken();
    print(token);
    print(_userId);
    await TokenHelper.deleteToken(token, _userId);
    await UserHelper.logout(token);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (!isLoaded) {
          getUserDetails(model);
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
                      _logout(context, model);
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
    );
  }
}
