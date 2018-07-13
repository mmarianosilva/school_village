import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../notification/notification.dart';

class NotificationsList extends StatelessWidget {

  final String schoolId;
  final String alertType;

  NotificationsList({Key key, this.schoolId, this.alertType}) : super(key: key);

  _buildList(context, snapshot) {
    return new ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (_, int index) {
        final DocumentSnapshot document = snapshot.data.documents[index];
        return new Card(
          child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new ListTile(
                  title: new Text(document['createdBy'], style: new TextStyle(fontWeight: FontWeight.bold),),
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
    print(alertType + " " + schoolId);
    int loaded = 0;
    Widget list = Text('Loading...');
    return new StreamBuilder(
        stream: Firestore.instance.collection("schools/$schoolId/notifications").where('type', isEqualTo: alertType).orderBy("createdAt", descending: true).limit(100).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print(snapshot.connectionState);
          print (snapshot);
          if (!snapshot.hasData) return list;
          final int messageCount = snapshot.data.documents.length;
          print(messageCount);
          if(messageCount > loaded) {
            list = _buildList(context, snapshot);
          }
          return list;
        }
    );
  }
}
