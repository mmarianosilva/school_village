import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import '../../util/user_helper.dart';

class Alert extends StatefulWidget {
  @override
  _AlertState createState() => _AlertState();
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
  String _role = '';
  String name = '';
  String phone = '';
  DocumentReference _user;
  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  bool _isTrainingMode = true;
  final customAlertController = TextEditingController();

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
    _email = user.email;
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolName = await UserHelper.getSchoolName();
    Firestore.instance.document(_schoolId).get().then((school) {
      _isTrainingMode = school['isTraining'];
    });
    _role = await UserHelper.getSelectedSchoolRole();
    _user = Firestore.instance.document('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user;
      _userId = user.documentID;
      setState(() {
        name =
        "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}";
        phone = "${_userSnapshot.data['phone']}";
        isLoaded = true;
      });
      print(name);
    });
  }

  _sendCustomAlert(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Send Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: customAlertController,
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'What is the emergency?'),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Send'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendAlert("other", "Alert!", "${customAlertController.text} at $_schoolName");
                  customAlertController.text = "";
                },
              )
            ],
          );
        }
    );
  }


  _sendAlert(alertType, alertTitle, alertBody) {
    if (_role == 'school_security' || _role == 'school_admin') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: Text('Are you sure you want to send this alert?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('This cannot be undone')
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  child: Text('911 + Campus', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Are you sure you want to send a message to 911?'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('This cannot be undone')
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  color: Colors.black45,
                                  child: Text('Yes', style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    if (_isTrainingMode) {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Training mode is set. During training mode, 911 alerts are disabled. Sending campus alert only."),
                                          )
                                      );
                                    } else {
                                      // TODO implement 911 alert
                                    }
                                    _saveAlert(alertTitle, alertBody, alertType, context);
                                  }
                              ),
                              FlatButton(
                                  color: Colors.black45,
                                  child: Text('No', style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
                FlatButton(
                  color: Colors.red,
                  child: Text('Only Campus', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveAlert(alertTitle, alertBody, alertType, context);
                  },
                ),
                FlatButton(
                  color: Colors.black45,
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text('Are you sure you want to send this alert?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('This cannot be undone')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.black45,
                child: Text('YES', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveAlert(alertTitle, alertBody, alertType, context);
                },
              ),
              FlatButton(
                color: Colors.black45,
                child: Text('NO', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }
  }

  _getLocation() async {
    Map<String, double> location = await UserHelper.getLocation();
    return location;
  }


  _saveAlert(alertTitle, alertBody, alertType, context) async{
    CollectionReference collection  = Firestore.instance.collection('$_schoolId/notifications');
    final DocumentReference document = collection.document();


    document.setData(<String, dynamic>{
      'title': alertTitle,
      'body': '$alertBody by ${UserHelper.getDisplayName(_userSnapshot)}',
      'type': alertType,
      'createdById': _userId,
      'createdBy' : name,
      'createdAt' : DateTime.now().millisecondsSinceEpoch,
      'location' : await _getLocation(),
      'reportedByPhone' : phone,
    });
    print("Added Alert");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert Sent'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('')
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: BaseAppBar(
          title: Text('Alert',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
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
          ]
      ),
      body: Builder(
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 32.0),
                  Container(
                      padding: EdgeInsets.all(12.0),
                      child: Text("TAP AN ICON BELOW TO SEND AN ALERT",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      )),
                  SizedBox(height: 32.0),
                  Image.asset('assets/images/alert_hand_icon.png',
                      width: 48.0, height: 48.0),
                  SizedBox(height: 16.0),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.all(12.0),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),

                                  child: GestureDetector(
                                      onTap: () {_sendAlert("armed", "Armed Assailant Alert!", "An Armed Assailant has been reported at $_schoolName");},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_armed.png',
                                            width: 72.0, height: 108.0),
                                      ])),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {_sendAlert("fight", "Fight Alert!", "A fight has been reported at $_schoolName");},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_fight.png',
                                            width: 72.0, height: 95.4),
                                      ])),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {_sendAlert("medical", "Medical Alert!", "A medical emergency has been reported at $_schoolName");},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_medical.png',
                                            width: 72.0, height: 109.8),
                                      ])),
                                ))
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {_sendAlert("fire", "Fire Alert!", "A fire has been reported at $_schoolName");},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_fire.png',
                                            width: 72.0, height: 109.8),
                                      ])),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {_sendAlert("intruder", "Intruder Alert!", "An intruder has been reported at $_schoolName");},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_intruder.png',
                                            width: 72.0, height: 109.8),
                                      ])),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {_sendCustomAlert(context);},
                                      child: Column(children: [
                                        Image.asset('assets/images/alert_other.png',
                                            width: 72.0, height: 109.8),
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
      ),
    );
  }
}
