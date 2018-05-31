import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../notification/notification.dart';

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

  getUserDetails() async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolName = await UserHelper.getSchoolName();
    _school = Firestore.instance.document(_schoolId);
    _school.get().then((school) {
      setState(() {
        _schoolSnapshot = school;
        isLoaded = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    print("/$_schoolId/notifications");
    return new Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: new AppBar(
        title: new Text('Notifications',
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade400,
        elevation: 0.0,
        leading: new BackButton(color: Colors.grey.shade800),
      ),
      body: !isLoaded ?  new Text("Loading..") :  new StreamBuilder(
        stream: Firestore.instance.collection("/$_schoolId/notifications").orderBy("createdAt", descending: true).limit(20).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          final int messageCount = snapshot.data.documents.length;
          return new ListView.builder(
            itemCount: messageCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = snapshot.data.documents[index];
              return new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new ListTile(
                      title: new Text(document['title'], style: new TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: new Text("Reported at ${new DateTime.fromMillisecondsSinceEpoch(document['createdAt'])}"),
                    ),
                    new ButtonTheme.bar( // make buttons use the appropriate styles for cards
                      child: new ButtonBar(
                        children: <Widget>[
                          new FlatButton(
                            child: const Text('VIEW'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new NotificationDetail(notification: document),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ]
                ),
              );
//              return new ListTile(
//                title: new Text(document['title'] ?? '<No message retrieved>'),
//                subtitle: new Text('Message ${index + 1} of $messageCount'),
//              );
            },
          );
        }
      ),
    );
  }
}
