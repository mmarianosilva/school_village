import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
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
  String _schoolName = '';
  String name = '';
  DocumentReference _school;
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<DocumentSnapshot>  _alerts = [];

  getUserDetails(MainModel model) async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _school = Firestore.instance.document(_schoolId);
    var  alerts = await model.getAlertGroups(_schoolId.split("/")[1]);
    List<DocumentSnapshot>  notifications = [];
    for(final alert in alerts){
      Query ref = Firestore.instance.collection("/$_schoolId/notifications").where('type', isEqualTo: alert).orderBy("createdAt", descending: true).limit(20);
      ref.snapshots().listen((querySnapshot) {
        notifications.addAll(querySnapshot.documents);
        setState(() {
          isLoaded = true;
          _alerts = notifications;
        });
      });
    }
    setState(() {
      isLoaded = true;
      _alerts = notifications;
    });
  }

  Widget _buildList() {
    _alerts.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    return new ListView.builder(
      itemCount: _alerts.length,
      itemBuilder: (_, int index) {
        final DocumentSnapshot document = _alerts[index];
        return new Card(
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new ListTile(
                  title: new Text(document['title'], style: new TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: new Text("${new DateTime.fromMillisecondsSinceEpoch(document['createdAt'])}"),
                  trailing: new FlatButton(
                    child: const Text('VIEW'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => new NotificationDetail(notification: document, title: 'Notification'),
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
          appBar: new AppBar(
            title: new Text('Notifications',
                textAlign: TextAlign.center,
                style: new TextStyle(color: Colors.black)),
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