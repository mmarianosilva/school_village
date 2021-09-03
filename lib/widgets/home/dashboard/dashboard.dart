import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/util/help_with_migration.dart';
import 'package:school_village/widgets/vendor/vendor_category_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:school_village/widgets/home/dashboard/dashboard_scope_observer.dart';

// import 'package:school_village/widgets/roll_call/roll_call_log.dart';
import 'package:school_village/widgets/search/search_dropdown_field.dart';
import 'package:school_village/main.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/home/dashboard/header_buttons.dart';
import 'package:school_village/widgets/incident_management/incident_management.dart';
import 'package:school_village/widgets/incident_report/incident_list.dart';
import 'package:school_village/widgets/incident_report/incident_report.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/file_helper.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/widgets/alert/alert.dart';
import 'package:school_village/widgets/hotline/hotline.dart';
import 'package:school_village/widgets/notifications/notifications.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/widgets/holine_list/hotline_list.dart';

class Dashboard extends StatefulWidget {
  const Dashboard(this.listener);

  final DashboardScopeObserver listener;

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
  StreamSubscription<QuerySnapshot> _alertSubscription;

  // Roll call
  bool rollCallAll = false;

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
    if (_alertSubscription != null) {
      _alertSubscription.cancel();
    }
    super.dispose();
  }

  void didPopNext() {
    if (widget.listener != null) {
      widget.listener.onDidPopScope();
    }
    _checkIfAlertIsInProgress();
  }

  _checkIfAlertIsInProgress() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
    print("Fatal Error $schoolId");
    try {
      CollectionReference alerts =
      FirebaseFirestore.instance.collection("${schoolId}/notifications");
      _alertSubscription = alerts
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((result) async {
        if (result.docs.isEmpty) {
          this.setState(() {
            this.alertInProgress = null;
          });
          return;
        }
        final List<QueryDocumentSnapshot> lastAlert =
            (await alerts.orderBy("endedAt", descending: true).limit(1).get())
                .docs;
        final DocumentSnapshot latestResolved =
        lastAlert.isNotEmpty ? lastAlert.first : null;
        final Timestamp lastResolvedTimestamp = latestResolved != null
            ? latestResolved.data()["endedAt"]
            : Timestamp.fromMillisecondsSinceEpoch(0);
        final latestAlert = result.docs.lastWhere(
                (DocumentSnapshot snapshot) =>
            snapshot.data()["createdAt"] >
                lastResolvedTimestamp.millisecondsSinceEpoch,
            orElse: () => null);
        SchoolAlert alert =
        latestAlert != null ? SchoolAlert.fromMap(latestAlert) : null;
        if (this.alertInProgress != alert) {
          this.setState(() {
            this.alertInProgress = alert;
          });
        }
      });
    }catch (e){
      setState(() {
        hasSchool = false;
      });
      print(e.toString());
    }


  }

  void _openIncidentManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentManagement(
          alert: this.alertInProgress,
          role: this.role,
        ),
      ),
    );
  }

  _showPDF(context, url, name, {List<Map<String, dynamic>> connectedFiles}) {
    print(url);
    PdfHandler.showPdfFile(context, url, name, connectedFiles: connectedFiles);
  }

  Future<void> _showLinkedPDF(BuildContext context, String documentId) async {
    PdfHandler.showLinkedPdf(context, documentId);
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
        debugPrint("Schoolid is $schoolId and role is $userRole");
      }
      isLoaded = true;
    });
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
    _launchURL("https://villagesafety.net/support_dashboard_vs");
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
        MaterialPageRoute(
            builder: (context) =>
                IncidentManagement(alert: alertInProgress, role: role)));
  }

  _buildSettingsOption() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openSettings,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
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
                style: TextStyle(
                    fontSize: 18.0, color: SVColors.dashboardItemFontColor),
              )),
              const Icon(Icons.chevron_right, color: Colors.grey),
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

  _buildNotificationsOption(model) {
    if (role == 'boater' || role == 'vendor' || role == 'maintenance') {
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
                      child: Center(
                        child: Image.asset('assets/images/alert.png'),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                        child: Text(
                      "Alert Log",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: SVColors.dashboardItemFontColor),
                    )),
                    const Icon(Icons.chevron_right, color: Colors.grey)
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

  _buildDocumentOption(DocumentSnapshot snapshot, index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (snapshot.data()["documents"][index - 4]["type"] == "pdf") {
          final List<Map<String, dynamic>> connectedFiles =
              snapshot.data()["documents"][index - 4]["connectedFiles"] != null
                  ? snapshot
                      .data()["documents"][index - 4]["connectedFiles"]
                      .map<Map<String, dynamic>>(
                          (untyped) => Map<String, dynamic>.from(untyped))
                      .toList()
                  : null;
          _showPDF(context, snapshot.data()["documents"][index - 4]["location"],
              snapshot.data()["documents"][index - 4]["title"],
              connectedFiles: connectedFiles);
        } else if (snapshot.data()["documents"][index - 4]["type"] ==
            "linked-pdf") {
          _showLinkedPDF(
            context,
            snapshot.data()["documents"][index - 4]["location"],
          );
        } else {
          _launchURL(snapshot.data()["documents"][index - 4]["location"]);
        }
      },
      onLongPress: () {
        if (snapshot.data()["documents"][index - 4]["type"] == "pdf") {
        } else if (snapshot.data()["documents"][index - 4]["type"] ==
            "linked-pdf") {}
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                child: Center(
                  child: FutureBuilder(
                      future: FileHelper.getFileFromStorage(
                          url: snapshot.data()["documents"][index - 4]["icon"],
                          context: context),
                      builder:
                          (BuildContext context, AsyncSnapshot<File> snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data.lengthSync() == 0) {
                          return Image.asset(
                            'assets/images/logo.png',
                            width: 48.0,
                          );
                        }
                        return Image.file(
                          snapshot.data,
                          width: 48.0,
                        );
                      }),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                snapshot.data()["documents"][index - 4]["title"],
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 18.0, color: SVColors.dashboardItemFontColor),
              )),
              const Icon(Icons.chevron_right, color: Colors.grey)
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
    return HeaderButtons(role: role);
  }

  _buildIncidentReport() {
    if (role == 'pd_fire_ems') {
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
                child: Center(
                  child: Image.asset('assets/images/feature_image.png'),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                "Incident Report Form",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 18.0, color: SVColors.dashboardItemFontColor),
              )),
              const Icon(Icons.chevron_right, color: Colors.grey)
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
    if (role == 'pd_fire_ems') {
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
                child: Center(
                  child: Image.asset('assets/images/incident_report_log.png'),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                  child: Text(
                "Incident Report Log",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 18.0, color: SVColors.dashboardItemFontColor),
              )),
              const Icon(Icons.chevron_right, color: Colors.grey)
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

  _buildHotlineMessages() {
    if (role != 'admin' && role != 'super_admin') {
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
                style: TextStyle(
                    fontSize: 18.0, color: SVColors.dashboardItemFontColor),
              )),
              const Icon(Icons.chevron_right, color: Colors.grey)
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
    const size = HeaderButtons.iconSize;
    if (role == 'pd_fire_ems') {
      return SizedBox(
        height: size,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: const SizedBox()),
          GestureDetector(
            child: Image.asset(
              'assets/images/alert.png',
              width: size * 2.0,
              fit: BoxFit.fitWidth,
            ),
            onTap: sendAlert,
          ),
          Expanded(
            child: (role != 'boater' &&
                        role != 'vendor' &&
                        role != 'maintenance') &&
                    alertInProgress != null
                ? GestureDetector(
                    child: Center(
                      child: Image.asset(
                        'assets/images/incident_management_icon.png',
                        width: size,
                        height: size,
                        fit: BoxFit.fill,
                      ),
                    ),
                    onTap: () => _openIncidentManagement(context))
                : const SizedBox(width: size),
          ),
        ],
      ),
    );
  }

  Future<bool> _displayRollCallDialog() async {
    return showDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(
          localize('Start a Roll Call?'),
          style: TextStyle(
              color: Color(0xff111010),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.48),
          textAlign: TextAlign.center,
        ),
        titlePadding: EdgeInsets.only(top: 8.0),
        contentPadding: EdgeInsets.zero,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (role == 'admin' ||
                role == 'school_admin' ||
                role == 'district' ||
                role == 'super_admin') ...[
              Text(
                localize('Schoolwide roll call').toUpperCase(),
                style: TextStyle(
                  color: Color(0xff810317),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  height: 24.0 / 18.0,
                  letterSpacing: 0.64,
                ),
              ),
              Text(
                localize('Select the Recipient'),
                style: TextStyle(
                  color: Color(0xff111010),
                  fontSize: 20.0,
                  letterSpacing: -0.48,
                ),
              ),
              Row(
                children: [
                  Radio(
                    activeColor: Color(0xff810317),
                    onChanged: (value) {
                      setState(() {
                        rollCallAll = !value;
                      });
                    },
                    groupValue: rollCallAll,
                    value: !rollCallAll,
                  ),
                  Text(
                    localize('Staff').toUpperCase(),
                    style: TextStyle(
                      color: Color(0xff881037),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.16,
                    ),
                  ),
                  const Spacer(),
                  Radio(
                    activeColor: Color(0xff810317),
                    onChanged: (value) {
                      setState(() {
                        rollCallAll = value;
                      });
                    },
                    groupValue: rollCallAll,
                    value: rollCallAll,
                  ),
                  Text(
                    localize('All').toUpperCase(),
                    style: TextStyle(
                      color: Color(0xff881037),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.16,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      child: Container(
                        height: 60.0,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xff48484a),
                        ),
                        child: Center(
                          child: Text(
                            localize('Cancel').toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              height: 22.0 / 17.0,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      child: Container(
                        height: 60.0,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Color(0xff48484a),
                        ),
                        child: Center(
                          child: Text(
                            localize('Send').toUpperCase(),
                            style: TextStyle(
                              color: Color(0xff14c3ef),
                              fontSize: 17.0,
                              height: 22.0 / 17.0,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ] else
              const SizedBox(),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                color: Color(0xffe5e5ea),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      localize('GROUP or CLASS ROLL CALL'),
                      style: TextStyle(
                        color: Color(0xff810317),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.46,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SearchDropdownField(),
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: Colors.black,
                          groupValue: true,
                          onChanged: (value) {},
                          value: true,
                        ),
                        Expanded(
                          child: Text(
                            localize('Self-Reported Roll Call'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: Colors.black,
                          groupValue: true,
                          onChanged: (value) {},
                          value: false,
                        ),
                        Expanded(
                          child: Text(
                            localize('Manual Roll Call'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                            child: Container(
                              height: 60.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xff48484a),
                              ),
                              child: Center(
                                child: Text(
                                  localize('Cancel').toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    height: 22.0 / 17.0,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                        ),
                        Expanded(
                          child: MaterialButton(
                            child: Container(
                              height: 60.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Color(0xff48484a),
                              ),
                              child: Center(
                                child: Text(
                                  localize('Send').toUpperCase(),
                                  style: TextStyle(
                                    color: Color(0xff14c3ef),
                                    fontSize: 17.0,
                                    height: 22.0 / 17.0,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            MaterialButton(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Color(0xff48484a),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                child: Text(
                  localize('Roll call log').toUpperCase(),
                  style: TextStyle(
                    color: Color(0xff14c3ef),
                    fontSize: 17.0,
                    height: 22.0 / 17.0,
                    letterSpacing: -0.41,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      context: context,
    );
  }

  _buildRollCallRequest() {
    if (role == 'school_student' ||
        role == 'enduser' ||
        role == 'school_family') {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () async {
        if ((await _displayRollCallDialog()) ?? false) {
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (context) => RollCallLog()),
          // );
        }
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                child: Center(
                  child: Image.asset('assets/images/roll_call_button.png',
                      fit: BoxFit.contain),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  localize('Roll Call Request'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                ),
              ),
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

  _buildServiceProvidersOption() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => VendorCategoryList()));
      },
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                child: Center(
                  child: Image.asset('assets/images/marine_services.png'),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  localize('Services'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18.0, color: SVColors.dashboardItemFontColor),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey)
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

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (model.user == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (!isLoaded) {
          _getSchoolId();
        } else {
          checkNewSchool();
          if (role != 'boater' && role != 'vendor') {
            _getLocationPermission();
          }
        }

        if (!isLoaded || !hasSchool) {
          return Material(
              child:
                  Text(localize("Please Select A Marina from Settings Tab")));
        }

        return FutureBuilder(
            future: FirebaseFirestore.instance.doc(ref).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final List<DocumentSnapshot> documents =
                    snapshot.data.data()["documents"] != null
                        ? snapshot.data
                            .data()["documents"]
                            .where((snapshot) {
                              if (snapshot["accessRoles"] == null) {
                                return true;
                              }
                              final accessRoles =
                                  (snapshot["accessRoles"] as List)
                                      .cast<String>();
                              //debugPrint("Access roles are $accessRoles");
                              for (final accessRole in accessRoles) {
                                if (accessRole.contains(role) ) {
                                  //||
                                  //                                     Temporary.updateRole(accessRole)
                                  //                                         .contains(role)
                                  //Removed above since we're upgrading
                                  //debugPrint("Print this");
                                  return true;
                                }
                              }
                              return false;
                            })
                            .toList()
                            .cast<DocumentSnapshot>()
                        : null;
                final int documentCount =
                    documents != null ? documents.length : 0;
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
                    } else
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
                            // if (index == 4) {
                            //   return _buildRollCallRequest();
                            // }
                            if (index == documentCount + 4) {
                              return _buildMessagesOption(model);
                            }
                            if (index == documentCount + 5) {
                              return _buildNotificationsOption(model);
                            }
                            if (index == documentCount + 6) {
                              return _buildHotlineMessages();
                            }
                            if (index == documentCount + 7) {
                              return _buildSettingsOption();
                            }
                            if (index == documentCount + 8) {
                              return _buildServiceProvidersOption();
                            }
                            return _buildDocumentOption(snapshot.data, index);
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
