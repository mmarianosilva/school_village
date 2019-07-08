import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final String conversationId;

  IncidentManagement({this.key, this.conversationId}) : super(key: key);

  @override
  createState() => _IncidentManagementState(conversationId: conversationId);
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

  _IncidentManagementState({this.conversationId});

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onSchoolMap() {

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
                        initialCameraPosition: CameraPosition(target: LatLng(37.7632125, -122.3997630), zoom: 19),
                        mapType: MapType.satellite,
                        myLocationButtonEnabled: false,
                        indoorViewEnabled: true,
                      ),
                      flex: 8,
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Address",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)
                      ),
                    ), flex: 1),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Alert type",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              )
                          ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("911 Callback: ",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              )
                          )
                        ],
                      ),
                      flex: 1,
                    ),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Text("Alert description",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)
                      ),
                    ), flex: 1),
                    Flexible(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: Text("Initial report by",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)
                      ),
                    ), flex: 1),
                    Flexible(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(child: Image.asset("assets/images/broadcast_btn.png", width: 64, height: 64), padding: EdgeInsets.all(8)),
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
