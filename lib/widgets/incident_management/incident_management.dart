import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:school_village/base/pair.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/model/talk_around_message.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/incident_management/OnMapInterface.dart';
import 'package:school_village/widgets/messages/messages.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'incident_message.dart';


class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final SchoolAlert alert;
  final String role;
  final DateFormat dateFormatter = DateFormat("hh:mm a");


  IncidentManagement({this.key, this.alert, this.role}) : super(key: key);

  @override
  createState() => _IncidentManagementState(alert: alert, role: role);
}

class _IncidentManagementState extends State<IncidentManagement> implements OnMapInterface {
  GoogleMapController _mapController;
  DocumentSnapshot _userSnapshot;
  bool _isLoading = true;
  String _schoolId = '';
  StreamSubscription<QuerySnapshot> _messageStream;
  List<TalkAroundMessage> _messages = List<TalkAroundMessage>();
  String newMessageText = "";
  String newMessageConversationId = "";
  final SchoolAlert alert;
  final String role;
  Set<Marker> markers;

  _IncidentManagementState({this.alert, this.role}) {
    this.markers = Set.from([Marker(
        markerId: MarkerId(alert.createdById),
        position: LatLng(alert.location.latitude, alert.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: alert.title,
            snippet: "Initial report by ${alert.createdBy} : ${alert.reportedByPhone}"
        ))]);
  }

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

  void onMessagesChanged(Pair<QuerySnapshot, QuerySnapshot> snapshotPair) {
    List<DocumentSnapshot> mergedList = snapshotPair.first.documents;
    mergedList.addAll(snapshotPair.second.documents);
    List<TalkAroundMessage> updatedList = mergedList.map((data) {
      return TalkAroundMessage(
          data["body"],
          DateTime.fromMillisecondsSinceEpoch(data["createdAt"]),
          data["createdBy"],
          data["createdById"],
          data["location"]["latitude"],
          data["location"]["longitude"]);
    }).toList();
    updatedList.sort((message1, message2) => message2.timestamp.millisecondsSinceEpoch - message1.timestamp.millisecondsSinceEpoch);
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId(alert.createdById),
        position: LatLng(alert.location.latitude, alert.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: alert.title,
            snippet: "Initial report by ${alert.createdBy} : ${alert.reportedByPhone}"
        )));
    markers.addAll(updatedList.map((message) => Marker(
        markerId: MarkerId(message.authorId),
        position: LatLng(message.latitude, message.longitude),
        infoWindow: InfoWindow(
            title: message.author,
            snippet: message.message)
    ))
    );
    setState(() {
      _messages = updatedList;
    });
  }

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        _isLoading = false;
      });
      getConversationDetails();
    });
  }

  getConversationDetails() async {
    CollectionReference securityAdminMessageCollection = Firestore.instance.collection('${_schoolId}/conversations/security-admin/messages');
    Stream<QuerySnapshot> securityAdminStream = securityAdminMessageCollection
        .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
        .orderBy("createdAt", descending: true)
        .snapshots();
    CollectionReference securityMessageCollection = Firestore.instance.collection('${_schoolId}/conversations/security/messages');
    Stream<QuerySnapshot> securityStream = securityMessageCollection
        .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
        .orderBy("createdAt", descending: true)
        .snapshots();
    ZipStream<QuerySnapshot, Pair<QuerySnapshot, QuerySnapshot>>([securityAdminStream, securityStream], (values) => Pair(values[0], values[1])).listen((data) {
      onMessagesChanged(data);
    });
  }

  Widget _buildListItem(BuildContext context, int index) {
    TalkAroundMessage item = _messages[index];
    String timestamp = widget.dateFormatter.format(item.timestamp);
    return IncidentMessage(
        message: item,
        timestamp: timestamp,
        targetGroup: "",
        onMapClicked: this);
  }

  @override
  void onMapClicked(double latitude, double longitude) {
    _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
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
            body: Builder(builder: (context) {
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
                      child: Container(
                        color: Color.fromARGB(140, 229, 229, 234),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                children: <TextSpan>[
                                  TextSpan(text: "${alert.title}", style: TextStyle(fontSize: 18.0)),
                                  TextSpan(text: " at ${widget.dateFormatter.format(alert.timestamp)}", style: TextStyle(fontSize: 14.0))
                                ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      flex: 2,
                    ),
                    Flexible(
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: LatLng(alert.location.latitude, alert.location.longitude), zoom: 16.4),
                        mapType: MapType.satellite,
                        myLocationButtonEnabled: false,
                        indoorViewEnabled: true,
                        markers: markers,
                      ),
                      flex: 10,
                    ),
                    Flexible(child: Container(
                      color: Color.fromARGB(140, 229, 229, 234),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {launch("https://goo.gl/maps/omQy8JRpbV8CqvzV7");},
                          child: Text("14429 Downey Ave, Paramount, CA 90723, USA",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color.fromARGB(255, 11, 48, 224))
                          ),
                        ),
                      ),
                    ), flex: 2),
                    Flexible(child: Container(
                      color: Color.fromARGB(140, 229, 229, 234),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Text(alert.body,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ), flex: 2),
                    Flexible(
                        child: Container(
                          color: Color.fromARGB(140, 229, 229, 234),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Row(
                              children: <Widget>[
                                Text("911 Callback: ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                Text(alert.createdBy,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 14.0)),
                                GestureDetector(
                                  onTap: () { launch("tel://${alert.reportedByPhone}"); },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                                    child: Text(alert.reportedByPhone,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 11, 48, 224))),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        flex: 1
                    ),
                    Flexible(child: Container(
                      color: Color.fromARGB(140, 229, 229, 234),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: <Widget>[
                            Text("Reported by: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)
                            ),
                            Text(alert.createdBy,
                                style: TextStyle(fontSize: 14.0)),
                            GestureDetector(
                                onTap: () { launch("tel://${alert.reportedByPhone}"); },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                                  child: Text(alert.reportedByPhone,
                                      style: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 11, 48, 224))),
                                )
                            )
                          ],
                        ),
                      ),
                    ), flex: 1),
                    Flexible(
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Container(
                                        child: GestureDetector(
                                            child: Image.asset("assets/images/group_message_btn.png", height: 64),
                                            onTap: _showBroadcast),
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)),
                                  ),
                                  Spacer(),
                                  Container(
                                      child: GestureDetector(
                                          child: Image.asset("assets/images/broadcast_msg_btn_hm.png", height: 64),
                                          onTap: _showBroadcast),
                                      padding: EdgeInsets.all(4)),
                                  Spacer(),
                                  Container(
                                      child: GestureDetector(
                                          child: Image.asset("assets/images/school_map_btn.png", height: 64),
                                          onTap: _onSchoolMap),
                                      padding: EdgeInsets.all(4)),
                                  Spacer(),
                                  Container(
                                      child: GestureDetector(
                                          child: Image.asset("assets/images/stop_sign.png", height: 64),
                                          onTap: _showStopAlert),
                                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)),
                                ]),
                          ),
                        ),
                        flex: 4
                    ),
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      child: Divider(color: Colors.red),
                    ),
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                          child: ListView.builder(
                            itemBuilder: _buildListItem,
                            itemCount: _messages.length,
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

  @override
  void dispose() {
    _messageStream.cancel();
    super.dispose();
  }
}
