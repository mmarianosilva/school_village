import 'package:flutter/material.dart';
import '../../../util/pdf_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../util/user_helper.dart';
import '../../alert/alert.dart';
import '../../select_group/select_group.dart';
import '../../talk_around/talk_around.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../util/file_helper.dart';
import 'dart:io';
import '../../settings/settings.dart';
import '../../notifications/notifications.dart';
import '../../messages/messages.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  bool hasSchool = false;
  bool isLoaded = false;
  String ref = "";
  bool isOwner = false;
  String role = "";

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
    var userIsOwner = await UserHelper.getIsOwner();
    if(userIsOwner == null) {
      userIsOwner = false;
    }
    var userRole = await UserHelper.getSelectedSchoolRole();
    setState(() {
      if(schoolId != null && schoolId != '') {
        ref = schoolId;
        isOwner = userIsOwner;
        role = userRole;
        hasSchool = true;
      }
      isLoaded = true;
    });
  }

  _updateSchool() async {
    if(!hasSchool) {
      var schoolId = await UserHelper.getSelectedSchoolID();
      var userIsOwner = await UserHelper.getIsOwner();
      var userRole = await UserHelper.getSelectedSchoolRole();
      if(userIsOwner == null) {
        userIsOwner = false;
      }
      setState(() {
        if(schoolId != null && schoolId != '') {
          ref = schoolId;
          isOwner = userIsOwner;
          role = userRole;
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

    openSettings() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Settings()),
      );
    }

    openNotifications() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Notifications()),
      );
    }

    openMessages() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Messages()),
      );
    }

    openTalk() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new TalkAround()),
      );
    }

    sendBroadcast() {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new SelectGroups()),
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
                      if(index == 1) {
                        List<Widget> widgets = new List();
                        List<String> securityRoles = ["school_admin", "school_security"];
                        print("Owner $isOwner Role $role");
                        if(isOwner || securityRoles.contains(role)) {
                          widgets.add(
                            new GestureDetector(
                              child: new Image.asset('assets/images/security_btn.png', width: 48.0),
                              onTap: openTalk,
                            )
                          );
                          widgets.add(new SizedBox(width: 20.0));
                        }

                        widgets.add(
                            new GestureDetector(
                              child: new Image.asset('assets/images/broadcast_btn.png', width: 48.0),
                              onTap: sendBroadcast,
                            )
                        );
                        return new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: widgets,
                        );
                      }
                      if(index == snapshot.data.data["documents"].length +2) {
                        return new Column(
                          children: <Widget>[
                            const SizedBox(height: 28.0),
                            new GestureDetector(
                              onTap: openMessages,
                              child:  new Row(
                                children: <Widget>[
    //                                new Image.asset('assets/images/logo.png', width: 48.0),
                                  new Container(
                                  width: 48.0,
                                  height: 48.0,
                                  child: new Center(
                                    child: new Icon(Icons.message, size: 36.0, color: Theme.of(context).accentColor),
                                  ),
                                ),
                                new SizedBox(width: 12.0),
                                new Expanded(
                                    child: new Text(
                                      "Messages",
                                      textAlign: TextAlign.left,
                                      style: new TextStyle(fontSize: 16.0),
                                    )),
                                new Icon(Icons.chevron_right)
                              ],
                            ),
                            )
                          ],
                        );
                      }
                      if(index == snapshot.data.data["documents"].length +3) {
                        return new Column(
                          children: <Widget>[
                            const SizedBox(height: 28.0),
                            new GestureDetector(
                              onTap: openNotifications,
                              child:  new Row(
                                children: <Widget>[
                                  //                                new Image.asset('assets/images/logo.png', width: 48.0),
                                  new Container(
                                    width: 48.0,
                                    height: 48.0,
                                    child: new Center(
                                      child: new Icon(Icons.notifications, size: 36.0, color: Colors.red.shade800),
                                    ),
                                  ),
                                  new SizedBox(width: 12.0),
                                  new Expanded(
                                      child: new Text(
                                        "Notifications",
                                        textAlign: TextAlign.left,
                                        style: new TextStyle(fontSize: 16.0),
                                      )),
                                  new Icon(Icons.chevron_right)
                                ],
                              ),
                            )
                          ],
                        );
                      }
                      if(index == snapshot.data.data["documents"].length +4) {
                        return new Column(
                          children: <Widget>[
                            const SizedBox(height: 28.0),
                            new GestureDetector(
                              onTap: openSettings,
                              child:  new Row(
                                children: <Widget>[
                                  //                                new Image.asset('assets/images/logo.png', width: 48.0),
                                  new Container(
                                    width: 48.0,
                                    height: 48.0,
                                    child: new Center(
                                      child: new Icon(Icons.settings, size: 36.0, color: Colors.grey.shade900),
                                    ),
                                  ),
                                  new SizedBox(width: 12.0),
                                  new Expanded(
                                      child: new Text(
                                        "Settings",
                                        textAlign: TextAlign.left,
                                        style: new TextStyle(fontSize: 16.0),
                                      )),
                                  new Icon(Icons.chevron_right)
                                ],
                              ),
                            )
                          ],
                        );
                      }
                      return new Column(
                        children: <Widget>[
                          const SizedBox(height: 28.0),
                          new GestureDetector(
                            onTap: () {
                              if(snapshot.data.data["documents"][index - 2]["type"] == "pdf") {
                                _showPDF(
                                    context,
                                    snapshot.data.data["documents"][index - 2]
                                    ["location"]);
                              } else {
                                _launchURL(snapshot.data.data["documents"][index - 2]
                                ["location"]);
                              }
                            },
                            child: new Row(
                              children: <Widget>[
//                                new Image.asset('assets/images/logo.png', width: 48.0),
                                new FutureBuilder(
                                    future: FileHelper.getFileFromStorage(url: snapshot.data.data["documents"][index - 2]
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
                                  snapshot.data.data["documents"][index - 2]
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
                    itemCount: snapshot.data.data["documents"].length + 5);
          }
        });
  }
}
