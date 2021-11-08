import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class Broadcast extends StatefulWidget {
  final Map<String, bool> groups;

  Broadcast({Key key, this.groups}) : super(key: key);

  @override
  _BroadcastState createState() => _BroadcastState(groups);
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
  final customAlertController = TextEditingController();

  getUserDetails() async {
    User user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
    _email = user.email;
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolName = await UserHelper.getSchoolName();
    _user = FirebaseFirestore.instance.doc('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user ;
      _userId = user.id;
      setState(() {
        name =
        "${_userSnapshot['firstName']} ${_userSnapshot['lastName']}";
        phone = _userSnapshot['phone'];
        isLoaded = true;
      });
      print(name);
    });
  }

  _sendMessage(context) {
    var text = customAlertController.text;
    if(text.length < 10) return;
    _sendBroadcast(text, context);
  }

  _sendBroadcast(alertBody, context) {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Are you sure you want to send this message?')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localize('This cannot be undone'))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(localize('No')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(localize('Yes')),
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
    CollectionReference collection  = FirebaseFirestore.instance.collection('$_schoolId/broadcasts');
    final DocumentReference document = collection.doc();
    final Map<String, double> location = await UserHelper.getLocation();

    document.set(<String, dynamic>{
      'body': alertBody,
      'groups' : groups,
      'createdById': _userId,
      'createdBy' : name,
      'createdAt' : DateTime.now().millisecondsSinceEpoch,
      'reportedByPhone' : phone,
      'location' : location
    });
    print("Added Message");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Sent')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(localize('Your message has been sent'))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(localize('Okay')),
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

    List<Widget> widgets = List();

    widgets.add(Text(localize("Message to broadcast:"),
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold
      ),
    ));

    widgets.add(SizedBox(height: 12.0));
    
    widgets.add(TextField(
      maxLines: 6,
      controller: customAlertController,
      onChanged: (String text) {
        setState(() {
          numCharacters = customAlertController.text.length;
        });
      },
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: localize('Message')),
    ));
    widgets.add(SizedBox(height: 12.0));
    widgets.add(Text("$numCharacters characters (minimum 10)",
      style: TextStyle(
          fontSize: 12.0
      ),
    ));
    widgets.add(SizedBox(height: 12.0));

    widgets.add(Container(
      alignment: Alignment.centerRight,
      child: MaterialButton(
        color: Theme.of(context).accentColor,
        child: Text(localize("Send")),
        onPressed: numCharacters >= 10 ?() {_sendMessage(context);} : null,
      ),
    ));


    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text(localize('Broadcast'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: widgets
          ),
        ));
  }
}