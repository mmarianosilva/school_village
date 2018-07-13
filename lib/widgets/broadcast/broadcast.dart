import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';

class Broadcast extends StatefulWidget {
  final Map<String, bool> groups;

  Broadcast({Key key, this.groups}) : super(key: key);

  @override
  _BroadcastState createState() => new _BroadcastState(groups);
}

class _BroadcastState extends State<Broadcast> {
  final Map<String, bool> groups;

  _BroadcastState(this.groups);

  String _schoolId = '';
  String _schoolName = '';
  String _userId = '';
  String _email = '';
  String name = '';
  String phone = '';
  DocumentReference _user;
  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  int numCharacters = 0;
  final customAlertController = new TextEditingController();

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
    _email = user.email;
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolName = await UserHelper.getSchoolName();
    _user = Firestore.instance.document('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user;
      _userId = user.documentID;
      setState(() {
        name =
        "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}";
        phone = _userSnapshot.data['phone'];
        isLoaded = true;
      });
      print(name);
    });
  }

  _sendMessage(context) {
    var text = customAlertController.text;
    if(text.length < 20) return;
    _sendBroadcast(text, context);
  }

  _sendBroadcast(alertBody, context) {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Are you sure you want to send this message?'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('This cannot be undone')
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveBroadcast(alertBody, context);
                },
              )
            ],
          );
        }
    );
  }

  _saveBroadcast(alertBody, context) async{
    print('$_schoolId/broadcasts');
    CollectionReference collection  = Firestore.instance.collection('$_schoolId/broadcasts');
    final DocumentReference document = collection.document();


    document.setData(<String, dynamic>{
      'body': alertBody,
      'groups' : groups,
      'createdById': _userId,
      'createdBy' : name,
      'createdAt' : new DateTime.now().millisecondsSinceEpoch,
      'reportedByPhone' : phone,
    });
    print("Added Message");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Sent'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('Your message has been sent')
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!isLoaded) {
      getUserDetails();
    }

    List<Widget> widgets = new List();

    widgets.add(new Text("Message to broadcast:",
      style: new TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold
      ),
    ));

    widgets.add(new SizedBox(height: 12.0));
    
    widgets.add(new TextField(
      maxLines: 6,
      controller: customAlertController,
      onChanged: (String text) {
        setState(() {
          numCharacters = customAlertController.text.length;
        });
      },
      decoration: new InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Message'),
    ));
    widgets.add(new SizedBox(height: 12.0));
    widgets.add(new Text("$numCharacters characters (minimum 20)",
      style: new TextStyle(
          fontSize: 12.0
      ),
    ));
    widgets.add(new SizedBox(height: 12.0));

    widgets.add(new Container(
      alignment: Alignment.centerRight,
      child: new MaterialButton(
        color: Theme.of(context).accentColor,
        child: new Text("Send"),
        onPressed: numCharacters >= 20 ?() {_sendMessage(context);} : null,
      ),
    ));


    return new Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: new AppBar(
          title: new Text('Broadcast',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Container(
          padding: EdgeInsets.all(12.0),
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: widgets
          ),
        ));
  }
}