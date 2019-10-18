import 'package:flutter/material.dart';
import 'package:school_village/main.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/home/dashboard/header_buttons.dart';
import 'package:school_village/widgets/incident_management/incident_management.dart';
import 'package:school_village/widgets/incident_report/incident_list.dart';
import 'package:school_village/widgets/incident_report/incident_report.dart';
import 'package:school_village/widgets/messages/broadcast_messaging.dart';
import '../../../util/pdf_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../util/user_helper.dart';
import '../../alert/alert.dart';
import '../../hotline/hotline.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../util/file_helper.dart';
import 'dart:io';
import '../../notifications/notifications.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../model/main_model.dart';
import 'package:location/location.dart';
import '../../../util/constants.dart';
import '../../holine_list/hotline_list.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RouteAware {
  bool hasSchool = false;
  bool isLoaded = false;
  String ref = "";
  bool isOwner = false;
  String role = "";
  Location _location = Location();
  SchoolAlert alertInProgress = null;

  @override
  void initState() {
    super.initState();
    _checkIfAlertIsInProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homePageRouteObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    homePageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void didPopNext() {
    _checkIfAlertIsInProgress();
  }

  _checkIfAlertIsInProgress() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    CollectionReference alerts = Firestore.instance.collection("${schoolId}/notifications");
    alerts.orderBy("createdAt", descending: true).getDocuments().then((result) {
      if (result.documents.isEmpty) {
        this.setState(() {
          this.alertInProgress = null;
        });
        return;
      }
      final DocumentSnapshot lastResolved = result.documents.firstWhere((doc) => doc["endedAt"] != null, orElse: () => null);
      final Timestamp lastResolvedTimestamp = lastResolved != null ? lastResolved["endedAt"] : Timestamp.now();
      result.documents.removeWhere((doc) => doc["endedAt"] != null || doc["createdAt"] < lastResolvedTimestamp.millisecondsSinceEpoch);
      final latestAlert = result.documents.isNotEmpty ? result.documents.last : null;
      SchoolAlert alert = latestAlert != null ? SchoolAlert.fromMap(latestAlert) : null;
      if (this.alertInProgress != alert) {
        this.setState(() {
          this.alertInProgress = alert;
        });
      }
    });
  }

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

  _getSchoolId() async {
    var schoolId = await UserHelper.getSelectedSchoolID();
    var userIsOwner = await UserHelper.getIsOwner();
    if (userIsOwner == null) {
      userIsOwner = false;
    }
    var userRole = await UserHelper.getSelectedSchoolRole();
    setState(() {
      if (schoolId != null && schoolId != '') {
        ref = schoolId;
        isOwner = userIsOwner;
        role = userRole;
        hasSchool = true;
      }
      isLoaded = true;
    });
  }

  _updateSchool() async {
    if (!hasSchool) {
      var schoolId = await UserHelper.getSelectedSchoolID();
      var userIsOwner = await UserHelper.getIsOwner();
      var userRole = await UserHelper.getSelectedSchoolRole();
      if (userIsOwner == null) {
        userIsOwner = false;
      }
      setState(() {
        if (schoolId != null && schoolId != '') {
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
    if (schoolId != ref) {
      setState(() {
        isLoaded = false;
        ref = schoolId;
      });
    }
  }

  _getLocationPermission() {
    try {
      _location.getLocation().then((location) {}).catchError((error) {});
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
    _launchURL("https://schoolvillage.org/index_support_dashboard");
  }

  openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notifications()),
    );
  }

  openIncidentManagement() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IncidentManagement(alert: alertInProgress, role: role))
    );
  }

  _buildSettingsOption() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 14.0),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: openSettings,
          child: Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: Icon(Icons.info_outline,
                      size: 48.0, color: Color.fromRGBO(23, 58, 163, 1)),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Support",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
        )
      ],
    );
  }

  _buildNotificationsOption(model) {
    if (role == 'school_student') {
      return SizedBox();
    }
    return FutureBuilder(
        future: model.getAlertGroups(ref.split("/")[1]),
        builder: (context, alertGroups) {
          if (alertGroups.connectionState != ConnectionState.done ||
              alertGroups.data.length == 0) {
            return SizedBox();
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: openNotifications,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 14.0),
                Row(
                  children: <Widget>[
                    Container(
                      width: 56.0,
                      height: 56.0,
                      child: Center(
                        child: Image.asset('assets/images/alert.png'),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                        child: Text(
                          "Alert Log",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                        )),
                    Icon(Icons.chevron_right, color: Colors.grey)
                  ],
                ),
                const SizedBox(height: 14.0),
                Container(
                  height: 0.5,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey,
                )
              ],
            ),
          );
        });
  }

  _buildMessagesOption(model) {
    return SizedBox();
  }

  _buildDocumentOption(snapshot, index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (snapshot.data.data["documents"][index - 5]["type"] == "pdf") {
          _showPDF(context,
              snapshot.data.data["documents"][index - 5]["location"]);
        } else {
          _launchURL(
              snapshot.data.data["documents"][index - 5]["location"]);
        }
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: FutureBuilder(
                      future: FileHelper.getFileFromStorage(
                          url: snapshot.data.data["documents"][index - 5]["icon"],
                          context: context),
                      builder:
                          (BuildContext context, AsyncSnapshot<File> snapshot) {
                        if (snapshot.data == null) {
                          return Image.asset('assets/images/logo.png', width: 48.0,);
                        }
                        return Image.file(snapshot.data, width: 48.0,);
                      }),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    snapshot.data.data["documents"][index - 5]["title"],
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  _buildSecurityOptions() {
    return HeaderButtons(role: role, alert: alertInProgress);
  }

  _buildIncidentReport() {
    if (role == 'school_student' || role == 'school_family') {
      return SizedBox();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IncidentReport()),
        );
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: Image.asset('assets/images/feature_image.png'),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Incident Report Form",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  _buildIncidentList() {
    if (role == 'school_student' || role == 'school_family') {
      return SizedBox();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IncidentList()),
        );
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: Image.asset('assets/images/incident_report_log.png'),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Incident Report Log",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  _buildHotlineButton() {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Text("Anonymous Safety Hotline",
              style: TextStyle(fontSize: 16.0, color: Constants.hotLineBlue),
              textAlign: TextAlign.center),
          Image.asset(
            'assets/images/hotline_header.png',
            width: 160.0,
            height: 160.0,
          ),
          Text(
            "Safety is Everybody's Business!\nYou can make a difference",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16.0,
                color: Constants.hotLineBlue),
          )
        ],
      ),
      onTap: openHotline,
    );
  }

  _buildHotlineMessages() {
    if (role != 'school_admin') {
      return SizedBox();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openHotLineList,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: Icon(Icons.record_voice_over,
                      size: 48.0, color: Colors.black),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Anonymous Hotline Log",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  _buildAlertButton() {
    if (role == 'school_student' || role == 'school_family') {
      return _buildHotlineButton();
    }
    return GestureDetector(
      child:
      Image.asset('assets/images/alert.png', width: 120.0, height: 120.0),
      onTap: sendAlert,
    );
  }

  _buildBroadcastInList() {
    if (role != 'school_student' && role != 'school_family') {
      return SizedBox();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BroadcastMessaging(editable: false))),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: Center(
                  child: Image.asset("assets/images/broadcast_btn.png", width: 48.0),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                    "Broadcast Messages",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                  )),
              Icon(Icons.chevron_right, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 0.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (ref != null && ref != '') {
          model
              .getAlertGroups(
              this.ref.split("/").length > 1 ? this.ref.split("/")[1] : '')
              .then((alerts) {
            print("User");
            print(alerts);
          });
        }

        if (!isLoaded) {
          _getSchoolId();
        } else {
          checkNewSchool();
          if (role != 'school_student') {
            _getLocationPermission();
          }
        }

        if (!isLoaded || !hasSchool) {
          return Material(
              child: Text("Please Select A School from Settings Tab"));
        }

        return FutureBuilder(
            future: Firestore.instance.document(ref).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                int documentCount = snapshot.data.data["documents"] != null ?
                snapshot.data.data["documents"].length : 0;
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    else
                      return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return _buildAlertButton();
                            }
                            if (index == 1) {
                              return _buildSecurityOptions();
                            }
                            if (index == 2) {
                              return _buildIncidentReport();
                            }
                            if (index == 3) {
                              return _buildIncidentList();
                            }
                            if (index == 4) {
                              return _buildBroadcastInList();
                            }
                            if (index == documentCount + 5) {
                              return _buildMessagesOption(model);
                            }
                            if (index == documentCount + 6) {
                              return _buildNotificationsOption(model);
                            }
                            if (index == documentCount + 7) {
                              return _buildHotlineMessages();
                            }
                            if (index == documentCount + 8) {
                              return _buildSettingsOption();
                            }
                            return _buildDocumentOption(snapshot, index);
                          },
                          itemCount: documentCount + 9);
                }
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            });
      },
    );
  }
}
