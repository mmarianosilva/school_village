import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';

class Alert extends StatefulWidget {
  @override
  _AlertState createState() => new _AlertState();
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Test Notifications', icon: Icons.notifications)
];

class _AlertState extends State<Alert> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _schoolId = '';
  String _schoolName = '';
  String _userId = '';
  String _email = '';
  String name = '';
  String phone = '';
  DocumentReference _user;
  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  Location _location = new Location();
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

  _sendCustomAlert(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Send Alert'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  TextField(
                    controller: customAlertController,
                    decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'What is the emergency?'),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Send'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendAlert("other", "Alert!", "${customAlertController.text} at $_schoolName", context);
                  customAlertController.text = "";
                },
              )
            ],
          );
        }
    );
  }


  _sendAlert(alertType, alertTitle, alertBody, context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Are you sure you want to send this alert?'),
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
                _saveAlert(alertTitle, alertBody, alertType, context);
              },
            )
          ],
        );
      }
    );
  }

  _getLocation() async {
    Map<String, double> location;
    String error;
    try {
      location = await _location.getLocation;
      error = null;
    } catch (e) {
//      if (e.code == 'PERMISSION_DENIED') {
//        error = 'Permission denied';
//      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
//        error = 'Permission denied - please ask the user to enable it from the app settings';
//      }

      location = null;
    }
    return location;
  }

  _saveAlert(alertTitle, alertBody, alertType, context) async{
    CollectionReference collection  = Firestore.instance.collection('$_schoolId/notifications');
    final DocumentReference document = collection.document();


    document.setData(<String, dynamic>{
      'title': alertTitle,
      'body': alertBody,
      'type': alertType,
      'createdById': _userId,
      'createdBy' : name,
      'createdAt' : new DateTime.now().millisecondsSinceEpoch,
      'location' : await _getLocation(),
      'reportedByPhone' : phone,
    });
    print("Added Alert");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Alert Sent'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('')
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  _select(Choice choice) {
    _saveAlert("Test Notification", "Test Notification for $_schoolName", "test", context);
  }


  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }

    return new Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: new AppBar(
        title: new Text('Alert',
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: new BackButton(color: Colors.grey.shade800),
        actions: <Widget>[
          new PopupMenuButton<Choice>(
            onSelected: _select,
            icon: new Icon(Icons.more_vert, color: Colors.grey.shade800),
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return new PopupMenuItem<Choice>(
                  value: choice,
                  child: new Row(
                    children: <Widget>[
                      new Icon(choice.icon, color: Colors.grey.shade800),
                      new SizedBox(width: 8.0),
                      new Text(choice.title)
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ]
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
          new Image.asset('assets/images/alert_hand_icon.png',
              width: 48.0, height: 48.0),
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
                          onTap: () {
                            _sendAlert("armed", "Armed Assailant Alert!", "An Armed Assailant has been reported at $_schoolName", context);
                            },
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
                              onTap: () {_sendAlert("fight", "Fight Alert!", "A fight has been reported at $_schoolName", context);},
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
                              onTap: () {_sendAlert("medical", "Medical Alert!", "A medical emrgency has been reported at $_schoolName", context);},
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
                              onTap: () {_sendAlert("fire", "Fire Alert!", "A fire has been reported at $_schoolName", context);},
                              child: new Column(children: [
                                new Image.asset('assets/images/alert_fire.png',
                                    width: 48.0, height: 48.0),
                                new Text("Fire", textAlign: TextAlign.center, style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                              ])),
                        )),
                    new Expanded(
                        flex: 1,
                        child: new Container(
                          margin: EdgeInsets.all(8.0),
                          child: new GestureDetector(
                              onTap: () {_sendAlert("intruder", "Intruder Alert!", "An intruder has been reported at $_schoolName", context);},
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
                              onTap: () {_sendCustomAlert(context);},
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
