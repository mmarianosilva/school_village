import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import '../../util/user_helper.dart';
import '../../model/school_ref.dart';

class SchoolList extends StatefulWidget {
  @override
  _SchoolListState createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _isLoading = true;
  BuildContext _context;

  selectSchool({schoolId: String, role: String, schoolName: String}) {
    print(schoolId);
    print("Setting school");
    UserHelper.setSelectedSchool(
        schoolId: schoolId, schoolName: schoolName, schoolRole: role);
    Navigator.pop(_context, true);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      key: _scaffoldKey,
      appBar: BaseAppBar(
        title: Text("Select School", style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.grey.shade800),
        backgroundColor: Colors.grey.shade200,
      ),
      body: FutureBuilder(
          future: UserHelper.getSchools(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print(snapshot.data);
            print(snapshot.connectionState);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Loading...');
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else {

                  return ListView.builder(
                    padding: EdgeInsets.all(22.0),
//                    itemExtent: 20.0,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: Firestore.instance
                            .document(snapshot.data[index]['ref'])
                            .get(),
                        // a Future<String> or null
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> schoolSnapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Text('Loading...');
                            case ConnectionState.waiting:
                              return Text('Loading...');
                            case ConnectionState.active:
                              return Text('Loading...');
                            default:
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              else {
                                var isOwner = false;
                                if(snapshot.data[index]['role'] == 'SiteAdmin' || snapshot.data[index]['role'] == 'Owner') {
                                  isOwner = true;
                                }

                                return Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 8.0
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: FlatButton(
                                            child: Text(schoolSnapshot.data == null
                                                ? ''
                                                : schoolSnapshot.data["name"]),
                                            onPressed: () {
                                              selectSchool(
                                                  schoolName:
                                                  schoolSnapshot.data["name"],
                                                  schoolId: snapshot.data[index]['ref'],
                                                  role: snapshot.data[index]['role']);
                                            }),
                                      ),
                                    ],
                                  ),
                                );
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
