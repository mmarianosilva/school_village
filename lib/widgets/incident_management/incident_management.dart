import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/messages/messages.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'incident_message.dart';


class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final String conversationId;
  final String role;

  IncidentManagement({this.key, this.conversationId, this.role}) : super(key: key);

  @override
  createState() => _IncidentManagementState(conversationId: conversationId, role: role);
}

class _IncidentManagementState extends State<IncidentManagement> {
  static const titles = ["Message", "Message", "Alert"];
  static const authors = ["Samuel Security", "Michael Wiggins", "Demo Staff"];
  static const messages = [
    "We have a report from the Anonymous Hotline that Tommy Jones, wearing a black hoodie and blue pants has a gun and is planning to shoot someone at school. Advise if he is seen and watch campus entry points to prevent entry if possible.",
    "A simulation of system communications during an armed assailant incident will begin in one minute. This is only a simulation.",
    "An Armed Assailant has been reported at SchoolVillage Demo"];
  static const timestamps = ["9:16 AM", "9:12 AM", "9:01 AM"];
  static const targetGroups = ["Security/Admin", "Staff, Students, Family", ""];

  GoogleMapController _mapController;
  DocumentSnapshot _userSnapshot;
  bool _isLoading = true;
  String _schoolId = '';
  String _securityConversation = "";
  String _securityAdminConversation = "";
  String newMessageText = "";
  String newMessageConversationId = "";
  final String conversationId;
  final String role;

  _IncidentManagementState({this.conversationId, this.role});

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onSchoolMap() {

  }

  void _showStopAlert() {

  }

  void _showBroadcast() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Messages(
            role: role,
          )),
    );
  }

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        _securityConversation = "$schoolId/conversations/security";
        _securityAdminConversation = "$schoolId/conversations/security-admin";
        _isLoading = false;
      });
    });
  }

  Widget _buildListItem(BuildContext context, int index) {
    return IncidentMessage(
      title: titles[index],
      author: authors[index],
      message: messages[index],
      timestamp: timestamps[index],
      targetGroup: targetGroups[index]);
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Scaffold(
            appBar: BaseAppBar(
                title: Text("Incident Management Dashboard",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
                leading: BackButton(color: Colors.grey.shade800),
                backgroundColor: Colors.grey.shade200,
                elevation: 0.0
            ),
            body:
            Builder(builder: (context) {
              if (_isLoading) {
                return Center(
                    child: CircularProgressIndicator()
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: LatLng(33.9018491, -118.1544462), zoom: 16.4),
                        mapType: MapType.satellite,
                        myLocationButtonEnabled: false,
                        indoorViewEnabled: true,
                        markers: Set<Marker>.from([Marker(markerId: MarkerId("123456789"), position: LatLng(33.902007, -118.1532139), infoWindow: InfoWindow(title: "Armed Assailant Alert", snippet: "Reported by Demo Staff at 9:01 AM"))]),
                      ),
                      flex: 10,
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {launch("https://goo.gl/maps/omQy8JRpbV8CqvzV7");},
                        child: Text("14429 Downey Ave, Paramount, CA 90723, USA",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.blue)
                        ),
                      ),
                    ), flex: 2),
                    Flexible(child:
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Text("Armed Assailant Alert!",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                    ),
                        flex: 1),
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 4.0),
                          child: Row(
                            children: <Widget>[
                              Text("911 Callback: ",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                              Text("John Smith",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 14.0)),
                              GestureDetector(
                                onTap: () { launch("tel://9491234567"); },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                                  child: Text("949-123-4568",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 14.0, color: Colors.blue)),
                                ),
                              )
                            ],
                          ),
                        ),
                        flex: 1
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Text("An Armed Assailant has been reported at Paramount High School",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 14.0)
                      ),
                    ), flex: 2),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Row(
                        children: <Widget>[
                          Text("Reported by: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)
                          ),
                          Text("Michael Wiggins",
                              style: TextStyle(fontSize: 14.0)),
                          GestureDetector(
                              onTap: () { launch("tel://9492741789"); },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                                child: Text("949-274-1709",
                                    style: TextStyle(fontSize: 14.0, color: Colors.blue)),
                              )
                          ),
                          Expanded(
                              child: Text("4:04 PM",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(fontWeight: FontWeight.bold))
                          )
                        ],
                      ),
                    ), flex: 1),
                    Flexible(
                        child: Container(
                          color: Color.fromARGB(255, 121, 123, 128),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    child: GestureDetector(
                                        child: Image.asset("assets/images/group_message_btn.png", width: 64, height: 64),
                                        onTap: _showBroadcast),
                                    padding: EdgeInsets.all(8)),
                                Spacer(),
                                Container(
                                    child: GestureDetector(
                                        child: Image.asset("assets/images/stop_sign.png", width: 64, height: 64),
                                        onTap: _showStopAlert),
                                    padding: EdgeInsets.all(8)),
                                Spacer(),
                                Container(
                                    child: GestureDetector(
                                        child: Image.asset("assets/images/school_map_btn.png", width: 64, height: 64),
                                        onTap: () { launch("https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=33.9014382,-118.1531176"); }),
                                    padding: EdgeInsets.all(8)),
                              ]),
                        ),
                        flex: 3
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                        child: Row(
                          children: <Widget>[
                            Text("SECURITY COMMUNICATIONS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            Spacer(),
                            Text("Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                          ],
                        ),
                      ),
                      flex: 1
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: Divider(color: Colors.red),
                    ),
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: ListView.builder(
                            itemBuilder: _buildListItem,
                            itemCount: 3,
                          ),
                        ),
                        flex: 10
                    )
                  ],
                );
              }
            })

        );
      },
    );
  }
}
