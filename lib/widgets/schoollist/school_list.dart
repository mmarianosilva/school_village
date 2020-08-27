import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class SchoolList extends StatefulWidget {
  @override
  _SchoolListState createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
        title: Text(localize("Select School"),
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        leading: BackButton(color: Colors.grey.shade800),
        backgroundColor: Colors.grey.shade200,
      ),
      body: FutureBuilder(
          future: UserHelper.getSchools(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text(localize('Loading...'));
              case ConnectionState.waiting:
                return Text(localize('Loading...'));
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(22.0),
//                    itemExtent: 20.0,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .doc(snapshot.data[index]['ref'])
                            .get(),
                        // a Future<String> or null
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> schoolSnapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Text(localize('Loading...'));
                            case ConnectionState.waiting:
                              return Text(localize('Loading...'));
                            case ConnectionState.active:
                              return Text(localize('Loading...'));
                            default:
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              else {
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
                                                : schoolSnapshot.data.data()["name"]),
                                            onPressed: () {
                                              selectSchool(
                                                  schoolName:
                                                  schoolSnapshot.data.data()["name"],
                                                  schoolId: snapshot.data.data()[index]['ref'],
                                                  role: snapshot.data.data()[index]['role']);
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
                else {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
            }
          }),
    );
  }
}
