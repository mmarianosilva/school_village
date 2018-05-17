import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../schoollist/school_list.dart';
import '../../../util/user_helper.dart';

class Settings extends StatefulWidget {

  @override
  _SettingsState createState() => new _SettingsState();

}

class _SettingsState extends State<Settings> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  DocumentReference _user;
  DocumentSnapshot _userSnapshot;

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    _email = user.email;
    _user = Firestore.instance.document('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user;
    });
  }

  @override
  Widget build(BuildContext context) {

    getUserDetails();

    return new Material(
      child: new Column(
        children: <Widget>[
          const SizedBox(height: 12.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton(
                child: new Text(_userSnapshot == null ? '' : "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}", style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                )),
                onPressed: null,
              ),

            ],
          ),
          const SizedBox(height: 12.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton.icon(
                icon: const Icon(Icons.school, size: 32.0),
                label: new Text('Change School', style: new TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                )),
                onPressed: () {
                  _auth.signOut().then((nothing){
                    Navigator.push(
                      context,
                      new MaterialPageRoute(builder: (context) => new SchoolList()),
                    );
//                    Navigator.of(context).pushNamedAndRemoveUntil(
//                        '/schools', (Route<dynamic> route) => false);
                  });
                },
              ),

            ],
          ),
          const SizedBox(height: 12.0),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new FlatButton.icon(
                icon: const Icon(Icons.exit_to_app, size: 32.0),
                label: new Text('Logout', style: new TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                )),
                onPressed: () {
                  UserHelper.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
//                  _auth.signOut().then((nothing){
//                    Navigator.of(context).pushNamedAndRemoveUntil(
//                        '/login', (Route<dynamic> route) => false);
//                  });
                },
              ),

            ],
          )
        ],
      ),
    );
  }
}