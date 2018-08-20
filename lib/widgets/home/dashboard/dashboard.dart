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
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  bool hasSchool = false;
  bool isLoaded = false;
  String ref = "";
  bool isOwner = false;
  String role = "";
  Location _location = Location();

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
      MaterialPageRoute(builder: (context) => Alert()),
    );
  }

  openHotline() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Hotline()),
    );
  }

  openHotLineList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HotLineList()),
    );
  }

  openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notifications()),
    );
  }

  openMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Messages(role: role,)),
    );
  }

  openTalk() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TalkAround()),
    );
  }

  sendBroadcast() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Messages(role: role,)),
    );
  }

  _buildSettingsOption() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        GestureDetector(
          onTap: openSettings,
          child:  Row(
            children: <Widget>[
              //                                Image.asset('assets/images/logo.png', width: 48.0),
              Container(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Icon(Icons.settings, size: 36.0, color: Colors.grey.shade900),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Settings",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16.0),
                  )),
              Icon(Icons.chevron_right)
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
    return FutureBuilder(future: model.getAlertGroups(ref.split("/")[1]), builder: (context, alertGroups) {
      if(alertGroups.connectionState != ConnectionState.done || alertGroups.data.length == 0 ){
        return SizedBox();
      }
      return Column(
        children: <Widget>[
          const SizedBox(height: 14.0),

          GestureDetector(
            onTap: openNotifications,
            child:  Row(
              children: <Widget>[
                Container(
                  width: 48.0,
                  height: 48.0,
                  child: Center(
                    child: Icon(Icons.notifications, size: 36.0, color: Colors.red.shade800),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                    child: Text(
                      "Notifications",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16.0),
                    )),
                Icon(Icons.chevron_right)
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          )
        ],
      );
    });
  }

  _buildMessagesOption(model) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        GestureDetector(
          onTap: openMessages,
          child:  Row(
            children: <Widget>[
              //                                Image.asset('assets/images/logo.png', width: 48.0),
              Container(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Icon(Icons.message, size: 36.0, color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Messages",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16.0),
                  )),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
        const SizedBox(height: 14.0),
        Container(
          height: 0.5,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
        ),
      ],
    );
  }

  _buildDocumentOption(snapshot, index) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        GestureDetector(
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
          child: Row(
            children: <Widget>[
              FutureBuilder(
                  future: FileHelper.getFileFromStorage(url: snapshot.data.data["documents"][index - 2]
                  ["icon"], context: context),
                  builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                    if(snapshot.data == null) {
                      return Image.asset('assets/images/logo.png', width: 48.0);
                    }
                    return Image.file(snapshot.data, width: 48.0);
                  }),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    snapshot.data.data["documents"][index - 2]
                    ["title"],
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16.0),
                  )),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
        const SizedBox(height: 14.0),
        Container(
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
    List<Widget> widgets = List();
    List<String> securityRoles = ["school_admin", "school_security"];
    print("Owner $isOwner Role $role");
    if(securityRoles.contains(role)) {
      widgets.add(
          GestureDetector(
            child: Image.asset('assets/images/security_btn.png', width: 48.0),
            onTap: openTalk,
          )
      );
    }
    if(role == "school_admin") {
      widgets.add(SizedBox(width: 20.0));
      widgets.add(
          GestureDetector(
            child: Image.asset(
                'assets/images/broadcast_btn.png', width: 48.0),
            onTap: sendBroadcast,
          )
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widgets,
    );
  }

  _buildHotlineButton() {
    return GestureDetector(child:
      Column(
        children: <Widget>[
          Text("Anonymous Safety Hotline", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          Image.asset('assets/images/hotline_header.png',
              width: 160.0, height: 160.0,),
          Text("Safety is Everybody's Business!\nYou can make a difference", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Constants.hotLineBlue),)
        ],
      ),
      onTap: openHotline,
    );
  }

  _buildHotlineMessages() {
    if(role != 'school_admin') {
      return SizedBox();
    }
    return Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        GestureDetector(
          onTap: openHotLineList,
          child:  Row(
            children: <Widget>[
              //                                Image.asset('assets/images/logo.png', width: 48.0),
              Container(
                width: 48.0,
                height: 48.0,
                child: Center(
                  child: Icon(Icons.record_voice_over, size: 36.0, color: Colors.green.shade700),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Anonymous Hotline",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16.0),
                  )),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
        const SizedBox(height: 14.0),
        Container(
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
    return GestureDetector(child:
    Image.asset('assets/images/alert.png',
        width: 120.0, height: 120.0),
      onTap: sendAlert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
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
          return Material(
              child: Text("Please Select A School from Settings Tab")
          );
        }

        return FutureBuilder(
            future: Firestore.instance.document(ref).get(),
            builder:
                (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                  else

                    return ListView.builder(
                        padding: EdgeInsets.all(8.0),
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
