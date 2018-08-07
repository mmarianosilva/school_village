import 'package:flutter/material.dart';
import '../../../util/pdf_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../util/user_helper.dart';
import '../../alert/alert.dart';
import '../../hotline/hotline.dart';
import '../../select_group/select_group.dart';
import '../../talk_around/talk_around.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../util/file_helper.dart';
import '../../../util/analytics_helper.dart';
import 'dart:io';
import '../../settings/settings.dart';
import '../../notifications/notifications.dart';
import '../../messages/messages.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../model/main_model.dart';
import 'package:location/location.dart';
import '../../../util/constants.dart';
import '../../holine_list/hotline_list.dart';

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
  Location _location = new Location();

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

  checkNewSchool() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    if(schoolId != ref) {
      String schoolName = await UserHelper.getSchoolName();
      setState(() {
        isLoaded = false;
        ref = schoolId;
      });
    }
  }

  _getLocationPermission() {
    try {
      _location.getLocation.then((location) {}).catchError((error) {});
    } catch (e) {}
  }

  sendAlert() {
    print("Sending Alert");
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Alert()),
    );
  }

  openHotline() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Hotline()),
    );
  }

  openHotLineList() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new HotLineList()),
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

  _buildSettingsOption() {
    return new Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
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

  _buildNotificationsOption(model) {
    if(role == 'school_student') {
      return SizedBox();
    }
    return new FutureBuilder(future: model.getAlertGroups(ref.split("/")[1]), builder: (context, alertGroups) {
      if(alertGroups.connectionState != ConnectionState.done || alertGroups.data.length == 0 ){
        return SizedBox();
      }
      return new Column(
        children: <Widget>[
          const SizedBox(height: 14.0),

          new GestureDetector(
            onTap: openNotifications,
            child:  new Row(
              children: <Widget>[
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
          ),
          const SizedBox(height: 14.0),
          new Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          )
        ],
      );
    });
  }

  _buildMessagesOption(model) {
    if(role == 'school_student') {
      return SizedBox();
    }
    return new Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
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
        ),
        const SizedBox(height: 14.0),
        new Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
        ),
      ],
    );
  }

  _buildDocumentOption(snapshot, index) {
    return new Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
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
        ),
        const SizedBox(height: 14.0),
        new Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
        )
      ],
    );
  }

  _buildSecurityOptions() {
    if(role == 'school_student') {
      return SizedBox();
    }
    List<Widget> widgets = new List();
    List<String> securityRoles = ["school_admin", "school_security"];
    print("Owner $isOwner Role $role");
    if(securityRoles.contains(role)) {
      widgets.add(
          new GestureDetector(
            child: new Image.asset('assets/images/security_btn.png', width: 48.0),
            onTap: openTalk,
          )
      );
    }
    if(role == "school_admin") {
      widgets.add(new SizedBox(width: 20.0));
      widgets.add(
          new GestureDetector(
            child: new Image.asset(
                'assets/images/broadcast_btn.png', width: 48.0),
            onTap: sendBroadcast,
          )
      );
    }
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widgets,
    );
  }

  _buildHotlineButton() {
    return new GestureDetector(child:
      new Column(
        children: <Widget>[
          new Text("Anonymous Safety Hotline", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          new Image.asset('assets/images/hotline_header.png',
              width: 160.0, height: 160.0,),
          new Text("Safety is Everybody's Business!\nYou can make a difference", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Constants.hotLineBlue),)
        ],
      ),
      onTap: openHotline,
    );
  }

  _buildHotlineMessages() {
    if(role != 'school_admin') {
      return SizedBox();
    }
    return new Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        new GestureDetector(
          onTap: openHotLineList,
          child:  new Row(
            children: <Widget>[
              //                                new Image.asset('assets/images/logo.png', width: 48.0),
              new Container(
                width: 48.0,
                height: 48.0,
                child: new Center(
                  child: new Icon(Icons.record_voice_over, size: 36.0, color: Colors.green.shade700),
                ),
              ),
              new SizedBox(width: 12.0),
              new Expanded(
                  child: new Text(
                    "Anonymous Hotline",
                    textAlign: TextAlign.left,
                    style: new TextStyle(fontSize: 16.0),
                  )),
              new Icon(Icons.chevron_right)
            ],
          ),
        ),
        const SizedBox(height: 14.0),
        new Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
        ),
      ],
    );
  }


  _buildAlertButton() {
    if(role == 'school_student') {
      return _buildHotlineButton();
    }
    return new GestureDetector(child:
    new Image.asset('assets/images/alert.png',
        width: 120.0, height: 120.0),
      onTap: sendAlert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if(ref != null && ref != '') {
          model.getAlertGroups(this.ref.split("/").length > 1 ? this.ref.split("/")[1] : '').then((alerts) {
            print("User");
            print(alerts);
          });
        }

        print("Rendering Dashboard");
        if(!isLoaded) {
          _getSchoolId();
        } else {
          checkNewSchool();
          if(role != 'school_student') {
            _getLocationPermission();
          }
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
                            return _buildAlertButton();
                          }
                          if(index == 1) {
                            return _buildSecurityOptions();
                          }
                          if(index == snapshot.data.data["documents"].length +2) {
                            return _buildMessagesOption(model);
                          }
                          if(index == snapshot.data.data["documents"].length +3) {
                            return _buildNotificationsOption(model);
                          }
                          if(index == snapshot.data.data["documents"].length +4) {
                            return _buildHotlineMessages();
                          }
                          if(index == snapshot.data.data["documents"].length +5) {
                            return _buildSettingsOption();
                          }
                          return _buildDocumentOption(snapshot, index);
                        },
                        itemCount: snapshot.data.data["documents"].length + 6);
              }
            });
      },
    );
  }
}
