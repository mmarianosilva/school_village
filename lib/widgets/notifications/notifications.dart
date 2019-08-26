import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/widgets/incident_management/incident_management.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../notification/notification.dart';
import '../../model/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => new _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String _schoolId = '';
  String _role = '';
  String name = '';
  DocumentReference _school;
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<SchoolAlert>  _alerts = [];

  getUserDetails(MainModel model) async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _school = Firestore.instance.document(_schoolId);
    _role = await UserHelper.getSelectedSchoolRole();
    List<SchoolAlert>  notifications = [];
    Query ref = Firestore.instance.collection("/$_schoolId/notifications")
        .orderBy('endedAt', descending: true)
        .where('endedAt', isLessThanOrEqualTo: Timestamp.now())
        .limit(20);
    ref.getDocuments().then((querySnapshot) {
      querySnapshot.documents.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      notifications.addAll(querySnapshot.documents.map((document) => SchoolAlert.fromMap(document)));
      setState(() {
        isLoaded = true;
        _alerts = notifications;
      });
    });
  }

  Widget _buildList() {

    return new ListView.builder(
      itemCount: _alerts.length,
      itemBuilder: (_, int index) {
        final SchoolAlert alert = _alerts[index];
        return new Card(
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new ListTile(
                  title: new Text(alert.title, style: new TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: new Text("${alert.timestamp}"),
                  trailing: new FlatButton(
                    child: const Text('VIEW'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => IncidentManagement(alert: alert, role: _role, resolved: true),
                        ),
                      );
                    },
                  ),
                ),

              ]
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<MainModel>(
        builder: (context, child, model) {
          if (!isLoaded) {
            getUserDetails(model);
          }
          print("/$_schoolId/notifications");
          return new Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: new BaseAppBar(
                title: new Text('Alert Log',
                    textAlign: TextAlign.center,
                    style: new TextStyle(color: Colors.black, letterSpacing: 1.29)),
                backgroundColor: Colors.grey.shade200,
                elevation: 0.0,
                leading: new BackButton(color: Colors.grey.shade800),
              ),
              body: !isLoaded ?  new Text("Loading..") :
              _buildList()
          );

        }
    );
  }
}