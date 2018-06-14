import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/user_helper.dart';
import '../../model/school_ref.dart';

class SchoolList extends StatefulWidget {
  @override
  _SchoolListState createState() => new _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  bool _isLoading = true;
  BuildContext _context;

  selectSchool({schoolId: String, role: String, schoolName: String}) {
    print(schoolId);
    UserHelper.setSelectedSchool(
        schoolId: schoolId, schoolName: schoolName, schoolRole: role);
    Navigator.pop(_context);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Select School", style: new TextStyle(color: Colors.black)),
        leading: new BackButton(color: Colors.grey.shade800),
        backgroundColor: Colors.grey.shade200,
      ),
      body: new FutureBuilder(
          future: UserHelper.getSchools(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print(snapshot.data);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('Loading...');
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {

                  return new ListView.builder(
                    padding: new EdgeInsets.all(22.0),
                    itemExtent: 20.0,
                    itemBuilder: (BuildContext context, int index) {
                      return new FutureBuilder(
                        future: Firestore.instance
                            .document(snapshot.data[index]['ref'])
                            .get(),
                        // a Future<String> or null
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> schoolSnapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return new Text('Loading...');
                            case ConnectionState.waiting:
                              return new Text('Loading...');
                            case ConnectionState.active:
                              return new Text('Loading...');
                            default:
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              else {
                                var isOwner = false;
                                if(snapshot.data[index]['role'] == 'SiteAdmin' || snapshot.data[index]['role'] == 'Owner') {
                                  isOwner = true;
                                }

                                return new FlatButton(
                                    child: new Text(schoolSnapshot.data == null
                                        ? ''
                                        : schoolSnapshot.data["name"]),
                                    onPressed: () {
                                      selectSchool(
                                          schoolName:
                                          schoolSnapshot.data["name"],
                                          schoolId: snapshot.data[index]['ref'],
                                          role: snapshot.data[index]['role']);
                                    });
                              }
                          }
                        },
                      );
                    },
                    itemCount: snapshot.data.length,
                  );
                }
            }
          }),
    );
  }
}
