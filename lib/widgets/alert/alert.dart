import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';

class Alert extends StatefulWidget {
  @override
  _AlertState createState() => new _AlertState();
}

class _AlertState extends State<Alert> {
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
      backgroundColor: Colors.grey.shade200,
      appBar: new AppBar(
        title: new Text('Alert',
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade400,
        elevation: 0.0,
        leading: new BackButton(color: Colors.grey.shade800),
      ),
      body: new Column(
        children: <Widget>[
          new SizedBox(height: 32.0),
          new Text("TAP AN ICON BELOW TO SEND AN ALERT",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  color: Colors.red,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold)),
          new SizedBox(height: 32.0),
          new Card(
            margin: EdgeInsets.all(8.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                      flex: 1,
                        child: new Container(
                      margin: EdgeInsets.all(8.0),
                      child: new GestureDetector(
                          child: new Column(children: [
                            new Image.asset('assets/images/alert_armed.png',
                                width: 48.0, height: 48.0),
                            new Text("Armed Assailant", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                          ])),
                    )),
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_fight.png',
                                    width: 48.0, height: 48.0),
                                new Text("Fight", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        )),
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_medical.png',
                                    width: 48.0, height: 48.0),
                                new Text("Medical Emergency", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        ))
                  ],
                ),
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_fire.png',
                                    width: 48.0, height: 48.0),
                                new Text("Fiew", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        )),
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_intruder.png',
                                    width: 48.0, height: 48.0),
                                new Text("Intruder", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        )),
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_other.png',
                                    width: 48.0, height: 48.0),
                                new Text("Other Emergency", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        ))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
