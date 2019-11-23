import 'dart:async';
import 'package:async/async.dart' show StreamGroup;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/util/pdf_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/model/talk_around_message.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/incident_management/close_incident_management_alert.dart';
import 'package:school_village/widgets/incident_management/on_map_interface.dart';
import 'package:school_village/widgets/messages/broadcast_messaging.dart';
import 'package:school_village/widgets/talk_around/message_details/message_details.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_home.dart';
import 'package:school_village/widgets/incident_management/incident_message.dart';


class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final SchoolAlert alert;
  final String role;
  final bool resolved;
  final DateFormat timeFormatter = DateFormat("hh:mm a");
  final DateFormat dateFormatter = DateFormat("EEEE, MMM dd, yyyy", "en_US");

  IncidentManagement({this.key, this.alert, this.role, this.resolved = false}) : super(key: key);

  @override
  createState() => _IncidentManagementState(alert: alert, role: role);
}

class _IncidentManagementState extends State<IncidentManagement> implements OnMapInterface {
  GoogleMapController _mapController;
  DocumentSnapshot _userSnapshot;
  bool _isLoading = true;
  String _schoolId = '';
  String _schoolAddress = '';
  Map<String, bool> _broadcastGroupData;
  StreamSubscription<QuerySnapshot> _messageStream;
  StreamSubscription<DocumentSnapshot> _alertSubscription;
  List<TalkAroundMessage> _messages = List<TalkAroundMessage>();
  List<TalkAroundMessage> _fullList = List<TalkAroundMessage>();
  SchoolAlert alert;
  final String role;
  Set<Marker> markers;
  Map<String, dynamic> _mapData;

  _IncidentManagementState({this.alert, this.role}) {
    this.markers = Set.from([Marker(
        markerId: MarkerId(alert.createdById),
        position: LatLng(alert.location.latitude, alert.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: alert.title,
            snippet: "Initial report by ${alert.createdBy} : ${alert.reportedByPhoneFormatted}"
        ))]);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onSchoolMap() {
    PdfHandler.showPdfFile(context, _mapData["location"], _mapData["title"], connectedFiles: _mapData["connectedFiles"].map<Map<String, dynamic>>((untyped) => Map<String, dynamic>.from(untyped)).toList());
  }

  void _showStopAlert() async {
    String closureComment = await _showStopAlertAsync();
    if (closureComment != null) {
      final String finalMessage = closureComment.isEmpty ? "Incident closed without resolution message" : closureComment;
      final String author = UserHelper.getDisplayName(_userSnapshot);
      Firestore.instance.runTransaction((transaction) {
        DocumentReference alertRef = Firestore.instance.document("$_schoolId/notifications/${alert.id}");
        return transaction.update(alertRef, {
          "endedAt" : FieldValue.serverTimestamp(),
          "resolution" : finalMessage,
          "resolvedBy" : author,
        });
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<String> _showStopAlertAsync() async {
    return showDialog<String>(
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CloseIncidentManagementAlert();
      },
      context: context,
    );
  }

  void _showTalkAround() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TalkAroundHome()
      ),
    );
  }

  void _showBroadcast() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BroadcastMessaging(
            editable: role == 'school_admin' || role == 'school_security' || role == 'pd_fire_ems',
          )),
    );
  }

  void onMessagesChanged(List<DocumentChange> snapshot) async {
    if (snapshot.isEmpty) {
      return;
    }
    if (snapshot.first.document.reference.parent().path == Firestore.instance.collection('$_schoolId/notifications').path) {
      List<TalkAroundMessage> newList = snapshot.map((data) {
        return TalkAroundMessage(
            data.document["title"],
            data.document.documentID,
            "",
            data.document["body"],
            DateTime.fromMillisecondsSinceEpoch(data.document["createdAt"]),
            data.document["createdBy"],
            data.document["createdById"],
            data.document["reportedByPhone"],
            data.document["location"]["latitude"],
            data.document["location"]["longitude"]);
      }).toList();
      _fullList.addAll(newList);
    } else if (snapshot.first.document.reference.parent().path == Firestore.instance.collection('$_schoolId/broadcasts').path) {
      snapshot.removeWhere((item) {
        Map<String, bool> targetGroups = Map<String, bool>.from(item.document.data['groups']);
        for(String key in targetGroups.keys) {
          if (this._broadcastGroupData.containsKey(key) && this._broadcastGroupData[key] && targetGroups[key]) {
            return false;
          }
        }
        return true;
      });
      List<TalkAroundMessage> newList = snapshot.map((data) {
        String channel = "";
        Map<String, bool> broadcastGroup = Map<String, bool>.from(data.document["groups"]);
        for(String key in broadcastGroup.keys) {
          if (broadcastGroup[key]) {
            channel += "$key, ";
          }
        }
        channel = channel.substring(0, channel.length - 2);
        return TalkAroundMessage(
            "Broadcast Message",
            data.document.documentID,
            channel,
            data.document["body"],
            DateTime.fromMillisecondsSinceEpoch(data.document["createdAt"]),
            data.document["createdBy"],
            data.document["createdById"],
            data.document["reportedByPhone"],
            null,
            null);
      }).toList();
      _fullList.addAll(newList);
    } else {
      List<TalkAroundMessage> newList = await Future.wait(snapshot.map((data) async {
        final DocumentSnapshot channelSnapshot = await data.document.reference.parent().parent().get();
        final TalkAroundChannel channel = TalkAroundChannel.fromMapAndUsers(channelSnapshot, []);
        return TalkAroundMessage(
            "Channel Message",
            data.document.documentID,
            channel.groupConversationName("${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}"),
            data.document["body"],
            DateTime.fromMicrosecondsSinceEpoch(data.document["timestamp"].microsecondsSinceEpoch),
            data.document["author"],
            data.document["authorId"],
            data.document["reportedByPhone"],
            data.document["location"]["latitude"],
            data.document["location"]["longitude"]);
      }).toList());
      _fullList.addAll(newList);
    }
    _fullList.sort((message1, message2) => message2.timestamp.millisecondsSinceEpoch - message1.timestamp.millisecondsSinceEpoch);
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId(alert.createdById),
        position: LatLng(alert.location.latitude, alert.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: alert.title,
            snippet: "Initial report by ${alert.createdBy} : ${alert.reportedByPhoneFormatted}"
        )));
    for(TalkAroundMessage message in _fullList) {
      if (message.latitude != null && message.longitude != null) {
        markers.add(Marker(
            markerId: MarkerId(message.authorId),
            position: LatLng(message.latitude, message.longitude),
            infoWindow: InfoWindow(
                title: message.author,
                snippet: message.message
            )
        ));
      }
    }
    setState(() {
      _messages = _fullList;
    });
  }

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    if (schoolId != null) {
      DocumentSnapshot schoolDocument = await Firestore.instance.document(schoolId).get();
      _mapData = _getMapData(schoolDocument);
      _schoolAddress = schoolDocument.data['address'];
    }
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        _broadcastGroupData = Map<String, bool>.from(user.data['associatedSchools'][schoolId.substring(schoolId.indexOf('/') + 1)]['groups']);
        _isLoading = false;
      });
      getConversationDetails();
    });
  }

  Map<String, dynamic> _getMapData(DocumentSnapshot snapshot) {
    final List<Map<String, dynamic>> documents = snapshot["documents"].map<Map<String, dynamic>>((untyped) => Map<String, dynamic>.from(untyped)).toList();
    final Map<String, dynamic> map = documents.firstWhere((document) => document["category"] == "MAP", orElse: null);
    return map;
  }

  getConversationDetails() async {
    if (alert.resolved) {
      _fullList.add(TalkAroundMessage(
          "Incident Record Closed",
          "alert-resolved-identifier",
          "",
          "${alert.resolution != null ? alert.resolution : "This incident has been resolved and closed."}",
          alert.timestampEnded,
          alert.resolvedBy ?? "SCHOOL VILLAGE SYSTEM",
          "",
          null,
          null,
          null));
      setState(() {
        _messages = _fullList;
      });
    } else {
      _alertSubscription = Firestore.instance
          .document("$_schoolId/notifications/${alert.id}")
          .snapshots()
          .listen((snapshot) {
        if (snapshot.data["endedAt"] != null) {
          _fullList.add(TalkAroundMessage(
              "Incident Record Closed",
              "alert-resolved-identifier",
              "",
              "${snapshot.data["resolution"] != null ? snapshot.data["resolution"] : "This incident has been resolved and closed."}",
              DateTime.fromMillisecondsSinceEpoch(snapshot.data["endedAt"].millisecondsSinceEpoch),
              snapshot.data["resolvedBy"] ?? "SCHOOL VILLAGE SYSTEM",
              "",
              null,
              null,
              null));
          final alert = SchoolAlert.fromMap(snapshot);
          setState(() {
            this.alert = alert;
          });
        }
      });
    }
    Query userMessageChannels = Firestore.instance.collection('$_schoolId/messages').where("roles", arrayContains: role);
    QuerySnapshot messageChannels = await userMessageChannels.getDocuments();
    StreamGroup<QuerySnapshot> messageStreamGroup = StreamGroup();
    messageChannels.documents.forEach((channelDocument) {
      if (alert.resolved) {
        messageStreamGroup.add(
            channelDocument.reference.collection("messages")
                .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(alert.timestamp.millisecondsSinceEpoch))
                .where("timestamp", isLessThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(alert.timestampEnded.millisecondsSinceEpoch))
                .snapshots());
      } else {
        messageStreamGroup.add(
            channelDocument.reference.collection("messages")
                .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(alert.timestamp.millisecondsSinceEpoch))
                .snapshots());
      }
    });
    if (alert.resolved) {
      // Broadcast messages
      messageStreamGroup.add(
          Firestore.instance.collection('$_schoolId/broadcasts')
              .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
              .where("createdAt", isLessThanOrEqualTo: alert.timestampEnded.millisecondsSinceEpoch)
              .snapshots());
      // Alerts
      messageStreamGroup.add(
          Firestore.instance.collection('$_schoolId/notifications')
              .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
              .where("createdAt", isLessThanOrEqualTo: alert.timestampEnded.millisecondsSinceEpoch)
              .snapshots());
    } else {
      // Broadcast messages
      messageStreamGroup.add(
          Firestore.instance.collection('$_schoolId/broadcasts')
              .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
              .snapshots());
      // Alerts
      messageStreamGroup.add(
          Firestore.instance.collection('$_schoolId/notifications')
              .where("createdAt", isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
              .snapshots());
    }
    _messageStream = messageStreamGroup.stream.listen((data) {
      data.documentChanges.removeWhere((item) => item.type != DocumentChangeType.added);
      onMessagesChanged(data.documentChanges);
    });
  }

  Widget _buildListItem(BuildContext context, int index) {
    TalkAroundMessage item = _messages[index];
    String timestamp = widget.timeFormatter.format(item.timestamp);
    return IncidentMessage(
        key: Key(item.id),
        message: item,
        timestamp: timestamp,
        targetGroup: item.channel,
        onMapClicked: this);
  }

  @override
  void onMapClicked(TalkAroundMessage message) {
    final messageMap = {
      'location' : {
        'latitude' : message.latitude,
        'longitude' : message.longitude
      },
      'createdBy' : message.author,
      'createdAt' : message.timestamp.millisecondsSinceEpoch,
      'body' : message.message
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetail(notification: messageMap)));
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
                          child: Row(
                              children: [
                                Text("${alert.title}", style: TextStyle(fontSize: 18.0, color: Colors.red, fontWeight: FontWeight.bold)),
                                Expanded(child: Text("${widget.dateFormatter.format(alert.timestamp)}", textAlign: TextAlign.end))
                              ]
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
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Color.fromARGB(140, 229, 229, 234),
                              child: Column(
                                children: <Widget>[
                                  Flexible(child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                      child: GestureDetector(
                                        onTap: () {launch("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_schoolAddress)}");},
                                        child: Text("${_schoolAddress}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Color.fromARGB(255, 11, 48, 224))
                                        ),
                                      ),
                                    ),
                                  ),),
                                  Flexible(child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                      child: Text(alert.body,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ),),
                                  Flexible(
                                    child: Container(
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
                                              onTap: () => showContactDialog(context, alert.createdBy, alert.reportedByPhone),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                                                child: Text(alert.reportedByPhoneFormatted,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 11, 48, 224))),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 4.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text("Reported by: ",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0)
                                          ),
                                          Text(alert.createdBy,
                                              style: TextStyle(fontSize: 14.0)),
                                          GestureDetector(
                                              onTap: () => showContactDialog(context, alert.createdBy, alert.reportedByPhone),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4.0, vertical: 0.0),
                                                child: Text(alert.reportedByPhoneFormatted,
                                                    style: TextStyle(fontSize: 14.0,
                                                        color: Color.fromARGB(
                                                            255, 11, 48, 224))),
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),),
                                ],
                              ),
                            ),
                          ),
                          _mapData != null ? FlatButton(
                            child: Image.asset("assets/images/school_map_btn.png", height: 64.0),
                            onPressed: () {
                              _onSchoolMap();
                            },
                          ): SizedBox(width: 0.0,),
                        ],
                      ),
                      flex: 4,
                    ),
                    Builder(builder: (context) {
                      if (widget.resolved) {
                        return Flexible(
                            child: Container(),
                            flex: 0
                        );
                      } else {
                        return Flexible(
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
                                                onTap: _showTalkAround),
                                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)),
                                      ),
                                      Spacer(),
                                      Container(
                                          child: GestureDetector(
                                              child: Image.asset("assets/images/broadcast_btn.png", height: 64),
                                              onTap: _showBroadcast),
                                          padding: EdgeInsets.all(4)),
                                      Spacer(),
                                      Container(
                                          child: GestureDetector(
                                              child: Image.asset("assets/images/sop_btn.png", height: 64),
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
                        );
                      }
                    }),
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
    if (_messageStream != null) {
      _messageStream.cancel();
    }
    if (_alertSubscription != null) {
      _alertSubscription.cancel();
    }
    super.dispose();
  }
}
