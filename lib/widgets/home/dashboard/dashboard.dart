import 'package:flutter/material.dart';
import '../../../util/pdf_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../util/user_helper.dart';
import '../../alert/alert.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../util/file_helper.dart';
import 'dart:io';


class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  bool hasSchool = false;
  bool isLoaded = false;
  String ref = "";

  _showPDF(context, url) {
    print(url);
    PdfHandler.showPdfFromUrl(context, url);
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _getSchoolId() async{
    var schoolId = await UserHelper.getSelectedSchoolID();
    setState(() {
      if(schoolId != null && schoolId != '') {
        ref = schoolId;
        hasSchool = true;
      }
      isLoaded = true;
    });
  }

  _updateSchool() async {
    if(!hasSchool) {
      var schoolId = await UserHelper.getSelectedSchoolID();
      setState(() {
        if(schoolId != null && schoolId != '') {
          ref = schoolId;
          hasSchool = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!isLoaded) {
      _getSchoolId();
    }

    if(!hasSchool && isLoaded) {
      _updateSchool();
    }
    var icons = [
      {'icon': new Icon(Icons.book), 'text': "Safety Instructions"}
    ];

    sendAlert() {
      print("Sending Alert");
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Alert()),
      );
    }

    if(!isLoaded || !hasSchool) {
      return new Material(
        child: new Text("Please Select A School from Settings Tab")
      );
    }

    return new FutureBuilder(
        future: Firestore.instance.document(ref).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              else

                return new ListView.builder(
                    padding: new EdgeInsets.all(8.0),
                    itemBuilder: (BuildContext context, int index) {
                      if(index == 0) {
                        return new GestureDetector(child:
                          new Image.asset('assets/images/alert.png',
                            width: 120.0, height: 120.0),
                          onTap: sendAlert,
                        );
                      }
                      return new Column(
                        children: <Widget>[
                          const SizedBox(height: 28.0),
                          new GestureDetector(
                            onTap: () {
                              if(snapshot.data.data["documents"][index - 1]["type"] == "pdf") {
                                _showPDF(
                                    context,
                                    snapshot.data.data["documents"][index - 1]
                                    ["location"]);
                              } else {
                                _launchURL(snapshot.data.data["documents"][index - 1]
                                ["location"]);
                              }
                            },
                            child: new Row(
                              children: <Widget>[
//                                new Image.asset('assets/images/logo.png', width: 48.0),
                                new FutureBuilder(
                                    future: FileHelper.getFileFromStorage(url: snapshot.data.data["documents"][index - 1]
                                    ["icon"], context: context),
                                    builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                                      if(snapshot.data == null) {
                                        return new Image.asset('assets/images/logo.png', width: 48.0);
                                      }
                                      return new Image.file(snapshot.data, width: 48.0);
                                    }),
                                new SizedBox(width: 12.0),
                                new Expanded(
                                    child: new Text(
                                  snapshot.data.data["documents"][index - 1]
                                      ["title"],
                                  textAlign: TextAlign.left,
                                  style: new TextStyle(fontSize: 16.0),
                                )),
                                new Icon(Icons.chevron_right)
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    itemCount: snapshot.data.data["documents"].length + 1);
          }
        });
  }
}
