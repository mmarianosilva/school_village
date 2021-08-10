import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/intrado_response.dart';
import 'package:school_village/model/intrado_wrapper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:uuid/uuid.dart';

import '../../model/intrado_wrapper.dart';

class Alert extends StatefulWidget {
  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  EventAction _eventAction = EventAction.None;
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
  BuildContext _scaffold;

  Future<EventAction> getConversationType() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(
                localize('What type of interaction would you like with +911')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(localize('This cannot be undone'))],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                child: Text(localize('Chat'),
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _eventAction = EventAction.TextMsg;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: Colors.red,
                child: Text(localize('Voice'),
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  _eventAction = EventAction.PSAPLink;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: Colors.black45,
                child: Text(localize('Cancel'),
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _eventAction = EventAction.None;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    return _eventAction;
  }

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
    _email = user.email;
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolName = await UserHelper.getSchoolName();
    //getIntradoChats();
    FirebaseFirestore.instance.doc(_schoolId).get().then((school) {
      _isTrainingMode = school.data()['isTraining'];
    });
    _role = await UserHelper.getSelectedSchoolRole();
    _user = FirebaseFirestore.instance.doc('users/${user.uid}');
    _user.get().then((user) {
      _userSnapshot = user;
      _userId = user.id;
      setState(() {
        name =
            "${_userSnapshot.data()['firstName']} ${_userSnapshot.data()['lastName']}";
        phone = "${_userSnapshot.data()['phone']}";
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
            title: Text(localize('Send Alert')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: customAlertController,
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: localize('What is the emergency?')),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(localize('Cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(localize('Send')),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendAlert("other", "Alert!",
                      "${customAlertController.text} at $_schoolName");
                  customAlertController.text = "";
                },
              )
            ],
          );
        });
  }

  _sendAlert(alertType, alertTitle, alertBody) {
    if (_role == 'security' ||
        _role == 'admin' ||
        _role == 'staff' ||
        _role == 'superadmin' ||
        _role == 'school_security' ||
        _role == 'school_admin' ||
        _role == 'school_staff' ||
        _role == 'district') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title:
                  Text(localize('Are you sure you want to send this alert?')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text(localize('This cannot be undone'))],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  child: Text(localize('911 + Campus'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(localize(
                                'Are you sure you want to send a message to 911?')),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(localize('This cannot be undone'))
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  color: Colors.black45,
                                  child: Text(localize('Yes'),
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    //_isTrainingMode = false;
                                    if (_isTrainingMode) {
                                      Scaffold.of(_scaffold)
                                          .showSnackBar(SnackBar(
                                        content: Text(localize(
                                            "Training mode is set. During training mode, 911 alerts are disabled. Sending campus alert only.")),
                                      ));
                                      final incident = await _getIncidentUrl();
                                      _saveAlert(
                                          alertTitle,
                                          alertBody,
                                          alertType,
                                          context,
                                          incident[1],
                                          incident[0]);
                                    } else {
                                      final mEvent =
                                          await getConversationType();
                                      print("Returned Event is $mEvent");
                                      if (mEvent == EventAction.None){
                                        return;
                                      }
                                      //final String incidentUrl =
                                      //await _saveAlert(alertTitle,
                                      //alertBody, alertType, context);
                                      final location =
                                          await UserHelper.getLocation();
                                      final incident = await _getIncidentUrl();
                                      print(incident);
                                      await _saveAlert(
                                              alertTitle,
                                              alertBody,
                                              alertType,
                                              context,
                                              incident[1],
                                              incident[0])
                                          .then((value) async {
                                        if (location != null) {
                                          final incidentUrl =
                                              incident[2] + incident[0];
                                          final intradoPayload = IntradoWrapper(
                                            eventAction: _eventAction,
                                            eventDescription:
                                                IntradoEventDescription(
                                                    text: alertTitle),
                                            eventDetails: <IntradoEventDetails>[
                                              IntradoEventDetails(
                                                  key: 'incident_url',
                                                  value: incidentUrl)
                                            ],
                                            caCivicAddress:
                                                IntradoCaCivicAddress(
                                              country: "US",
                                              a1: "CO",
                                              a2: "BOULDER",
                                              a3: "LONGMONT",
                                              rd: "RD",
                                            ),
                                            geoLocation: IntradoGeoLocation(
                                                latitude: location["latitude"],
                                                longitude:
                                                    location["longitude"],
                                                altitude: location["altitude"],
                                                confidence: 80,
                                                uncertainty: 150.0),
                                            serviceProvider:
                                                IntradoServiceProvider(
                                                    name:
                                                        "Marina Village Safety",
                                                    contactUri:
                                                        "tel:+19492741709",
                                                    textChatEnabled: true),
                                            deviceOwner: IntradoDeviceOwner(
                                                name:
                                                    "${_userSnapshot.data()['firstName']} ${_userSnapshot.data()['lastName']}",
                                                tel:
                                                    "${_userSnapshot.data()['phone']}",
                                                environment: "Marina",
                                                mobility: "Fixed"),
                                            eventTime: DateTime.now(),
                                          );
                                          final token =
                                              (await (await FirebaseAuth
                                                          .instance
                                                          .currentUser())
                                                      .getIdToken())
                                                  .token;
                                          final response = await http.post(
                                            "https://us-central1-marinavillage-dev.cloudfunctions.net/api/intrado/${incident[0]}/create-event",
                                            body: intradoPayload.toXml(),
                                            encoding:
                                                Encoding.getByName("utf8"),
                                            headers: <String, String>{
                                              "Authorization": "Bearer $token",
                                            },
                                          );
                                          print(
                                              "Body Submitted is ${intradoPayload.toXml()} and token is $token");
                                          print(
                                              "Intrado response is ${response.body}");
                                          final jsonResponse =
                                              json.decode(response.body);
                                          IntradoResponse intradoResponse =
                                              new IntradoResponse.fromJson(
                                                  jsonResponse);
                                          if (intradoResponse.success == true &&
                                              _eventAction ==
                                                  EventAction.PSAPLink) {
                                            var storexml = xml.parse(
                                                intradoResponse.response);
                                            final phones = storexml
                                                .findAllElements('number');
                                            phones
                                                .map((node) => node.text)
                                                .forEach((element) {
                                              launch("tel://$element");
                                            });
                                          }
                                        }
                                      });
                                    }
                                  }),
                              FlatButton(
                                  color: Colors.black45,
                                  child: Text(localize('No'),
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          );
                        });
                  },
                ),
                FlatButton(
                  color: Colors.red,
                  child: Text(localize('Only Campus'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final incident = await _getIncidentUrl();
                    _saveAlert(alertTitle, alertBody, alertType, context,
                        incident[1], incident[0]);
                  },
                ),
                FlatButton(
                  color: Colors.black45,
                  child: Text(localize('Cancel'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title:
                  Text(localize('Are you sure you want to send this alert?')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text(localize('This cannot be undone'))],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.black45,
                  child: Text(localize('YES'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final incident = await _getIncidentUrl();
                    _saveAlert(alertTitle, alertBody, alertType, context,
                        incident[1], incident[0]);
                  },
                ),
                FlatButton(
                  color: Colors.black45,
                  child: Text(localize('NO'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  _getLocation() async {
    Map<String, double> location = await UserHelper.getLocation();
    return location;
  }

  Future<String> getBaseUrl() async {
    String baseurl = "";
    final packageInfo = await PackageInfo.fromPlatform();
    switch (packageInfo.packageName.trim()) {
      case 'com.oandmtech.marinavillage':
        baseurl = "https://marinavillage-web.web.app/i/";
        return baseurl;

      case 'com.oandmtech.marinavillage.dev':
        baseurl = "https://marinavillage-dev-web.web.app/i/";
        return baseurl;

      case 'com.oandmtech.schoolvillage':
        baseurl = "https://schoolvillage-web.firebaseapp.com/i/";
        return baseurl;

      case 'com.oandmtech.schoolvillage.dev':
        baseurl = "https://schoolvillage-dev-web.web.app/i/";
        return baseurl;

      default:
        baseurl = "";
        return baseurl;
    }
  }

  Future<DocumentSnapshot> getLastResolved(result) async {
    final DocumentSnapshot lastResolved = result.docs.firstWhere((doc) {
      return !doc.data().containsKey('endedAt');
    }, orElse: () {
      return null;
    });
    return lastResolved;
  }

  getIntradoChats() async {
    final result = await FirebaseFirestore.instance
        .collection("intrado_events")
        //.where("schoolId", isEqualTo: id)
        .get();
    if (result.docs.isEmpty) {
      print("No Intrado Events");
    } else {
      result.docs.forEach((element) {
        print("Intrado Event : $element");
      });
    }
  }

  Future<List<dynamic>> _getIncidentUrl() async {
    String randomToken = Uuid().v4();
    final baseurl = await getBaseUrl();
    String id = _schoolId.split("schools/")[1].trim();
    final result = await FirebaseFirestore.instance
        .collection("ongoing_incidents")
        .where("schoolId", isEqualTo: id)
        .get();
    if (result.docs.isEmpty) {
      return [randomToken, true, baseurl];
    } else {
      final lastResolved = await getLastResolved(result);
      if (lastResolved != null) {
        print("Last Resolved Data is ${lastResolved.data()}");
        String dashboardUrl = lastResolved.data()['dashboardUrl'];

        return [dashboardUrl.split(baseurl)[1], false, baseurl];
      } else {
        return [randomToken, true, baseurl];
      }
    }
  }

  Future<String> _saveAlert(
      alertTitle, alertBody, alertType, context, updateToken, token) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('$_schoolId/notifications');
    final DocumentReference document = collection.doc();

    final String room = UserHelper.getRoomNumber(_userSnapshot);

    if (updateToken) {
      document.set(<String, dynamic>{
        'title': alertTitle,
        'body': alertBody,
        'type': alertType,
        'createdById': _userId,
        'createdBy': '$name${room != null ? ', Room $room' : ''}',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'location': await _getLocation(),
        'reportedByPhone': phone,
        'token': token,
      });
    } else {
      document.set(<String, dynamic>{
        'title': alertTitle,
        'body': alertBody,
        'type': alertType,
        'createdById': _userId,
        'createdBy': '$name${room != null ? ', Room $room' : ''}',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'location': await _getLocation(),
        'reportedByPhone': phone,
        'token': token,
      });
    }
    print(
        "Schoold id = $_schoolId and notificationToken = ${token} and TOKENUPDATE is $updateToken");
    print("Added Alert");

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Alert Sent')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text('')],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(localize('Okay')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: BaseAppBar(
        title: Text(localize('Alert'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: Builder(builder: (BuildContext context) {
        _scaffold = context;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 32.0),
              Container(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    localize("TAP AN ICON BELOW TO SEND AN ALERT"),
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
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("armed", "Armed Assailant Alert!",
                                    "An Armed Assailant has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_armed.png',
                                    width: 72.0, height: 108.0),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("fight", "Fight Alert!",
                                    "A fight has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_fight.png',
                                    width: 72.0, height: 95.4),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("medical", "Medical Alert!",
                                    "A medical emergency has been reported at $_schoolName");
                              },
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
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("auto", "Auto Accident/Injury",
                                    "A car accident has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset(
                                    'assets/images/alert_auto_accident_injury.png',
                                    width: 72.0,
                                    height: 109.8),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("explosion", "Explosion Alert!",
                                    "An explosion has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_explosion.png',
                                    width: 72.0, height: 109.8),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("boat", "Boat Accident/Injury",
                                    "A boat accident has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset(
                                    'assets/images/alert_boat_accident_injury.png',
                                    width: 72.0,
                                    height: 109.8),
                              ])),
                        ))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("fire", "Fire Alert!",
                                    "A fire has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_fire.png',
                                    width: 72.0, height: 109.8),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendAlert("intruder", "Intruder Alert!",
                                    "An intruder has been reported at $_schoolName");
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_intruder.png',
                                    width: 72.0, height: 109.8),
                              ])),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                _sendCustomAlert(context);
                              },
                              child: Column(children: [
                                Image.asset('assets/images/alert_other.png',
                                    width: 72.0, height: 109.8),
                              ])),
                        ))
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
