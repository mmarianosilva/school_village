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


class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final String conversationId;
  final String role;

  IncidentManagement({this.key, this.conversationId, this.role}) : super(key: key);

  @override
  createState() => _IncidentManagementState(conversationId: conversationId, role: role);
}

class _IncidentManagementState extends State<IncidentManagement> {
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
                      ),
                      flex: 8,
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {launch("https://goo.gl/maps/omQy8JRpbV8CqvzV7");},
                        child: Text("14429 Downey Ave, Paramount, CA 90723, USA",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.lightBlue)
                        ),
                      ),
                    ), flex: 1),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Alert type",
                                textAlign: TextAlign.start,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                          ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Text("911 Callback: ",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                    Text("John Smith",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                    GestureDetector(
                                      onTap: () { launch("tel://9491234567"); },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                                        child: Text("949-123-4568",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.lightBlue)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                      flex: 1,
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Text("An Armed Assailant has been reported at Paramount High School",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)
                      ),
                    ), flex: 2),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Row(
                        children: <Widget>[
                          Text("Initial report by: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)
                          ),
                          Text("Michael Wiggins",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                          GestureDetector(
                              onTap: () { launch("tel://9492741789"); },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                                child: Text("949-274-1709",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.lightBlue)),
                              )
                          )
                        ],
                      ),
                    ), flex: 1),
                    Flexible(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: GestureDetector(
                                      child: Image.asset("assets/images/broadcast_btn.png", width: 64, height: 64),
                                      onTap: _showBroadcast),
                                  padding: EdgeInsets.all(8)),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(4.0),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset("assets/images/logo.png", width: 64, height: 64),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("School Map"),
                                          )
                                        ]),
                                  ),
                                  onTap: _onSchoolMap,
                                ),
                              )
                            ]),
                        flex: 2
                    ),
                    Expanded(
                      child: Chat(
                        conversation: _securityConversation,
                        user: _userSnapshot,
                        showInput: false,
                      ),
                      flex: 8,
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
