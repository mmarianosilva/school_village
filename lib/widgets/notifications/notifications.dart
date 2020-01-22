import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_village/widgets/notification/notification.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/incident_management/incident_management.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/user_helper.dart';


class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String _schoolId = '';
  String _role = '';
  String name = '';
  DocumentReference _school;
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<SchoolAlert>  _alerts = [];
  final DateFormat timestampFormat = dateFormatting.messageDateFormatter;

  getUserDetails(MainModel model) async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _school = Firestore.instance.document(_schoolId);
    _role = await UserHelper.getSelectedSchoolRole();
    List<SchoolAlert>  notifications = [];
    Query ref = Firestore.instance.collection("/$_schoolId/notifications")
        .orderBy('createdAt', descending: true)
        .limit(25);
    ref.getDocuments().then((querySnapshot) {
      notifications.addAll(querySnapshot.documents.map((document) => SchoolAlert.fromMap(document)));
      setState(() {
        isLoaded = true;
        _alerts = notifications;
      });
    });
  }

  Widget _buildList() {

    return ListView.builder(
      itemCount: _alerts.length,
      itemBuilder: (_, int index) {
        final SchoolAlert alert = _alerts[index];
        return Card(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(alert.title, style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text("${timestampFormat.format(alert.timestamp)}"),
                  trailing: Builder(builder: (context) {
                    if (alert.resolved) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatButton(
                            child: const Text('ID', style: TextStyle(color: Colors.blueAccent),),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IncidentManagement(alert: alert,
                                          role: _role,
                                          resolved: alert.resolved),
                                ),
                              );
                            },
                          ),
                          FlatButton(
                            child: const Text('VIEW'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationDetail(notification: alert, title: 'Notification'),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return FlatButton(
                        child: const Text('VIEW'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationDetail(notification: alert, title: 'Notification'),
                            ),
                          );
                        },
                      );
                    }
                  }),
                ),
              ]
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (context, child, model) {
          if (!isLoaded) {
            getUserDetails(model);
          }
          print("/$_schoolId/notifications");
          return Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: BaseAppBar(
                title: Text('Alert Log',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
                backgroundColor: Colors.grey.shade200,
                elevation: 0.0,
                leading: BackButton(color: Colors.grey.shade800),
              ),
              body: !isLoaded ?  Text("Loading..") :
              _buildList()
          );

        }
    );
  }
}