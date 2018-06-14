import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../notification/notification.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => new _MessagesState();
}

class _MessagesState extends State<Messages> {
  FirebaseUser _userId;
  String name = '';
  String _schoolId = '';
  bool isLoaded = false;
  DocumentReference _userRef;
  DocumentSnapshot _userSnapshot;
  List<String> _groups = new List<String>();

  getUserDetails() async {
    _userId = await UserHelper.getUser();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = Firestore.instance.document("users/${_userId.uid}");
    _userRef.get().then((user) {
      var keys = user.data["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = new List<String>();
      for(int i = 0; i < keys.length; i ++) {
        if(user.data["associatedSchools"][schoolId]["groups"][keys.elementAt(i)] == true){
          groups.add(keys.elementAt(i));
        }
      }
      setState(() {
        _schoolId = schoolId;
        _userSnapshot = user;
        _groups = groups;
        isLoaded = true;
      });
    });
  }

  bool belongsToGroup(messageGroup) {
    for(int i=0; i < messageGroup.length; i++) {
      for(int j=0; j < _groups.length; j++) {
        if(_groups.elementAt(j) == messageGroup.elementAt(i)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    print(_groups);
    print("/$_schoolId/broadcast");
    return new Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: new AppBar(
        title: new Text('Messages',
            textAlign: TextAlign.center,
            style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: new BackButton(color: Colors.grey.shade800),
      ),
      body: !isLoaded ?  new Text("Loading..") :  new StreamBuilder(
          stream: Firestore.instance.collection("schools/$_schoolId/broadcasts").orderBy("createdAt", descending: true).limit(100).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final int messageCount = snapshot.data.documents.length;
            return new ListView.builder(
              itemCount: messageCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document = snapshot.data.documents[index];
                if(!belongsToGroup(document['groups'].keys)) {
                  return SizedBox(width: 0.0, height: 0.0);
                }
                return new Container(child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 8.0
                        ),
                        alignment: Alignment.centerLeft,
                        child: new Text(document['createdBy'] + "", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      ),
                      new Container(
                        padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 2.0
                        ),
                        alignment: Alignment.centerLeft,
                        child: new Text(document['body'] + ""),
                      ),
                      new Container(
                        padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 2.0,
                            bottom: 8.0
                        ),
                        alignment: Alignment.centerLeft,
                        child: new Text("${new DateTime.fromMillisecondsSinceEpoch(document['createdAt'])}", style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
                      ),
                    ]
                  ),
                  decoration: new BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  margin: new EdgeInsets.all(8.0),
                );

              },
            );
          }
      ),
    );
  }
}
