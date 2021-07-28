import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class SchoolList extends StatefulWidget {
  @override
  _SchoolListState createState() => _SchoolListState();
}

class _SchoolListState extends State<SchoolList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext _context;
  final List<String> harbors = <String>[];
  final List<String> regions = <String>[];

  selectSchool({schoolId: String, role: String, schoolName: String}) {
    PdfHandler.deletePdfFiles();
    UserHelper.setSelectedSchool(
        schoolId: schoolId, schoolName: schoolName, schoolRole: role);
    Navigator.pop(_context, true);
  }

  @override
  void initState() {
    final regionData = UserHelper.getRegionData();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    TextEditingController controller = TextEditingController();
    Widget _widget(String searchText) {
      return RaisedButton(
        elevation: 2,
        color: Colors.green,
        child: Text(searchText),
        onPressed: () {
          setState(() {
            //text = searchText;
          });
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: BaseAppBar(
        title: Text(localize("Select Location"),
            style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
        leading: BackButton(color: Colors.grey.shade800),
        backgroundColor: Colors.grey.shade200,
        bottom: PreferredSize(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(7),
                child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: controller,
                      onFieldSubmitted: (covariant) {
                        setState(() {
                          text = covariant;
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          hintText: "Search 1100+ Products",
                          hintStyle: TextStyle(fontSize: 15)),
                    )),
              ),
              Container(
                height: 50,
                color: Colors.white.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _widget("Tea"),
                    _widget("water"),
                    _widget("Thums Up"),
                    _widget("H")
                  ],
                ),
              ),
              Container(
                height: 30,
                width: double.infinity,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 3),
                  child: Text(
                    "Seach for: $text",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            ],
          ),
          preferredSize: Size(3, 120),
        ),
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
                                            left: 8.0, right: 8.0, top: 8.0),
                                        alignment: Alignment.centerLeft,
                                        child: FlatButton(
                                            child: Text(
                                                schoolSnapshot.data == null
                                                    ? ''
                                                    : schoolSnapshot.data
                                                        .data()["name"]),
                                            onPressed: () {
                                              selectSchool(
                                                  schoolName: schoolSnapshot
                                                      .data
                                                      .data()["name"],
                                                  schoolId: snapshot.data[index]
                                                      ['ref'],
                                                  role: snapshot.data[index]
                                                      ['role']);
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
                } else {
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

  String text = "a";
}
