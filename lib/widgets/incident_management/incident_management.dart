import 'dart:async';
import 'package:async/async.dart' show StreamGroup;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/util/pdf_handler.dart';
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
import 'package:school_village/util/localizations/localization.dart';

class IncidentManagement extends StatefulWidget {
  final GlobalKey<_IncidentManagementState> key;
  final SchoolAlert alert;
  final String role;
  final bool resolved;

  IncidentManagement({this.key, this.alert, this.role, this.resolved = false})
      : super(key: key);

  @override
  createState() => _IncidentManagementState(alert: alert, role: role);
}

class _IncidentManagementState extends State<IncidentManagement>
    implements OnMapInterface {
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
    this.markers = Set.from([
      Marker(
          markerId: MarkerId(alert.createdById),
          position: LatLng(alert.location.latitude, alert.location.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
              title: alert.title,
              snippet:
                  "Initial report by ${alert.createdBy} : ${alert.reportedByPhoneFormatted}"))
    ]);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onSchoolMap() {
    PdfHandler.showPdfFile(context, _mapData["location"], _mapData["title"],
        connectedFiles: _mapData["connectedFiles"] != null
            ? _mapData["connectedFiles"]
                .map<Map<String, dynamic>>(
                    (untyped) => Map<String, dynamic>.from(untyped))
                .toList()
            : null);
  }

  void _onSop() async {
    DocumentSnapshot schoolData =
        await FirebaseFirestore.instance.doc(_schoolId).get();
    if (schoolData.data()["sop"][alert.type] != null) {
      PdfHandler.showPdfFile(
          context,
          schoolData.data()["sop"][alert.type]["location"],
          schoolData.data()["sop"][alert.type]["title"]);
    } else {
      PdfHandler.showPdfFile(
          context,
          schoolData.data()["sop"]["other"]["location"],
          schoolData.data()["sop"]["other"]["title"]);
    }
  }

  void _showStopAlert() async {
    String closureComment = await _showStopAlertAsync();
    if (closureComment != null) {
      final String finalMessage = closureComment.isEmpty
          ? "Incident closed without resolution message"
          : closureComment;
      final String author = UserHelper.getDisplayName(_userSnapshot);
      FirebaseFirestore.instance.runTransaction((transaction) {
        DocumentReference alertRef = FirebaseFirestore.instance
            .doc("$_schoolId/notifications/${alert.id}");
        transaction.update(alertRef, {
          "endedAt": FieldValue.serverTimestamp(),
          "resolution": finalMessage,
          "resolvedBy": author,
        });
        return Future.value(true);
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
      MaterialPageRoute(builder: (context) => TalkAroundHome()),
    );
  }

  void _showBroadcast() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BroadcastMessaging(
                editable: role == 'school_admin' || role == 'admin' ||
                    role == 'school_security' || role == 'security' ||
                    role == 'pd_fire_ems' ||
                    role == 'district' || role == 'super_admin',
              )),
    );
  }

  void onMessagesChanged(List<DocumentChange> snapshot) async {
    if (snapshot.isEmpty) {
      return;
    }
    if (snapshot.first.doc.reference.parent.path ==
        FirebaseFirestore.instance
            .collection('$_schoolId/notifications')
            .path) {
      List<TalkAroundMessage> newList = snapshot.map((data) {
        return TalkAroundMessage(
            data.doc.data()["title"],
            data.doc.id,
            "",
            data.doc.data()["body"],
            DateTime.fromMillisecondsSinceEpoch(data.doc.data()["createdAt"]),
            data.doc.data()["createdBy"],
            data.doc.data()["createdById"],
            data.doc.data()["reportedByPhone"],
            data.doc.data()["location"]["latitude"],
            data.doc.data()["location"]["longitude"]);
      }).toList();
      _fullList.addAll(newList);
    } else if (snapshot.first.doc.reference.parent.path ==
        FirebaseFirestore.instance.collection('$_schoolId/broadcasts').path) {
      snapshot.removeWhere((item) {
        Map<String, bool> targetGroups = item.doc.data()['groups'] != null
            ? Map<String, bool>.from(item.doc.data()['groups'])
            : null;
        if (targetGroups == null) {
          return false;
        }
        for (String key in targetGroups.keys) {
          if (this._broadcastGroupData.containsKey(key) &&
              this._broadcastGroupData[key] &&
              targetGroups[key]) {
            return false;
          }
        }
        return true;
      });
      List<TalkAroundMessage> newList = snapshot.map((data) {
        String channel = "";
        Map<String, bool> broadcastGroup = data.doc.data()["groups"] != null
            ? Map<String, bool>.from(data.doc.data()["groups"])
            : null;
        if (broadcastGroup != null) {
          for (String key in broadcastGroup.keys) {
            if (broadcastGroup[key]) {
              channel += "$key, ";
            }
          }
        channel = channel.substring(0, channel.length - 2);
        } else {
          channel = "All";
        }
        return TalkAroundMessage(
            "Broadcast Message",
            data.doc.id,
            channel,
            data.doc.data()["body"],
            DateTime.fromMillisecondsSinceEpoch(data.doc.data()["createdAt"]),
            data.doc.data()["createdBy"],
            data.doc.data()["createdById"],
            data.doc.data()["reportedByPhone"],
            null,
            null);
      }).toList();
      _fullList.addAll(newList);
    } else {
      List<TalkAroundMessage> newList =
          await Future.wait(snapshot.map((data) async {
        final DocumentSnapshot channelSnapshot =
            await data.doc.reference.parent.parent.get();
        final TalkAroundChannel channel =
            TalkAroundChannel.fromMapAndUsers(channelSnapshot, []);
        return TalkAroundMessage(
          "Channel Message",
          data.doc.id,
          channel.groupConversationName(
              "${_userSnapshot.data()['firstName']} ${_userSnapshot.data()['lastName']}"),
          data.doc.data()["body"],
          DateTime.fromMicrosecondsSinceEpoch(
              data.doc.data()["timestamp"].microsecondsSinceEpoch),
          data.doc.data()["author"],
          data.doc.data()["authorId"],
          data.doc.data()["reportedByPhone"],
          data.doc.data()["location"] != null
              ? data.doc.data()["location"]["latitude"]
              : null,
          data.doc.data()["location"] != null
              ? data.doc.data()["location"]["longitude"]
              : null,
        );
      }).toList());
      _fullList.addAll(newList);
    }
    _fullList.sort((message1, message2) =>
        message2.timestamp.millisecondsSinceEpoch -
        message1.timestamp.millisecondsSinceEpoch);
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId(alert.createdById),
        position: LatLng(alert.location.latitude, alert.location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: alert.title,
            snippet:
                "Initial report by ${alert.createdBy} : ${alert.reportedByPhoneFormatted}")));
    for (TalkAroundMessage message in _fullList) {
      if (message.latitude != null && message.longitude != null) {
        markers.add(Marker(
            markerId: MarkerId(message.authorId),
            position: LatLng(message.latitude, message.longitude),
            infoWindow:
                InfoWindow(title: message.author, snippet: message.message)));
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
      DocumentSnapshot schoolDocument =
          await FirebaseFirestore.instance.doc(schoolId).get();
      if (schoolDocument.data()["documents"] != null) {
        _mapData = _getMapData(schoolDocument);
      }
      _schoolAddress = schoolDocument.data()['address'];
    }
    FirebaseFirestore.instance.doc('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        _broadcastGroupData = Map<String, bool>.from(
            user.data()['associatedSchools']
                [schoolId.substring(schoolId.indexOf('/') + 1)]['groups']);
        _isLoading = false;
      });
      getConversationDetails();
    });
  }

  Map<String, dynamic> _getMapData(DocumentSnapshot snapshot) {
    final List<Map<String, dynamic>> documents = snapshot
        .data()["documents"]
        .map<Map<String, dynamic>>(
            (untyped) => Map<String, dynamic>.from(untyped))
        .toList();
    final Map<String, dynamic> map = documents
        .firstWhere((document) => document["category"] == "MAP", orElse: () => null);
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
          alert.resolvedBy ?? "MARINA VILLAGE SYSTEM",
          "",
          null,
          null,
          null));
      setState(() {
        _messages = _fullList;
      });
    } else {
      print("Schoold id = $_schoolId and notificationid = ${alert.id}");
      _alertSubscription = FirebaseFirestore.instance
          .doc("$_schoolId/notifications/${alert.id}")
          .snapshots()
          .listen((snapshot) {
        if (snapshot.data()["endedAt"] != null) {
          _fullList.add(TalkAroundMessage(
              "Incident Record Closed",
              "alert-resolved-identifier",
              "",
              "${snapshot.data()["resolution"] != null ? snapshot.data()["resolution"] : "This incident has been resolved and closed."}",
              DateTime.fromMillisecondsSinceEpoch(
                  snapshot.data()["endedAt"].millisecondsSinceEpoch),
              snapshot.data()["resolvedBy"] ?? "MARINA VILLAGE SYSTEM",
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
    Query userMessageChannels = FirebaseFirestore.instance
        .collection('$_schoolId/messages')
        .where("roles",
            arrayContainsAny: [role, "school_security", "school_admin", "security", "admin"]);
    QuerySnapshot messageChannels = await userMessageChannels.get();
    StreamGroup<QuerySnapshot> messageStreamGroup = StreamGroup();
    messageChannels.docs.forEach((channelDocument) {
      if (alert.resolved) {
        messageStreamGroup.add(channelDocument.reference
            .collection("messages")
            .where("timestamp",
                isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                    alert.timestamp.millisecondsSinceEpoch))
            .where("timestamp",
                isLessThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                    alert.timestampEnded.millisecondsSinceEpoch))
            .snapshots());
      } else {
        messageStreamGroup.add(channelDocument.reference
            .collection("messages")
            .where("timestamp",
                isGreaterThanOrEqualTo: Timestamp.fromMillisecondsSinceEpoch(
                    alert.timestamp.millisecondsSinceEpoch))
            .snapshots());
      }
    });
    if (alert.resolved) {
      // Broadcast messages
      messageStreamGroup.add(FirebaseFirestore.instance
          .collection('$_schoolId/broadcasts')
          .where("createdAt",
              isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
          .where("createdAt",
              isLessThanOrEqualTo: alert.timestampEnded.millisecondsSinceEpoch)
          .snapshots());
      // Alerts
      messageStreamGroup.add(FirebaseFirestore.instance
          .collection('$_schoolId/notifications')
          .where("createdAt",
              isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
          .where("createdAt",
              isLessThanOrEqualTo: alert.timestampEnded.millisecondsSinceEpoch)
          .snapshots());
    } else {
      // Broadcast messages
      messageStreamGroup.add(FirebaseFirestore.instance
          .collection('$_schoolId/broadcasts')
          .where("createdAt",
              isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
          .snapshots());
      // Alerts
      messageStreamGroup.add(FirebaseFirestore.instance
          .collection('$_schoolId/notifications')
          .where("createdAt",
              isGreaterThanOrEqualTo: alert.timestamp.millisecondsSinceEpoch)
          .snapshots());
    }
    _messageStream = messageStreamGroup.stream.listen((data) {
      data.docChanges
          .removeWhere((item) => item.type != DocumentChangeType.added);
      onMessagesChanged(data.docChanges);
    });
  }

  Widget _buildListItem(BuildContext context, int index) {
    TalkAroundMessage item = _messages[index];
    String timestamp = timeFormatter.format(item.timestamp);
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
      'location': {
        'latitude': message.latitude,
        'longitude': message.longitude
      },
      'createdBy': message.author,
      'createdAt': message.timestamp.millisecondsSinceEpoch,
      'body': message.message
    };
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageDetail(notification: messageMap)));
  }

  List<Widget> _buildStopAlertItems() {
    if (role == 'school_security' || role == 'school_admin' || role == 'district' || role == 'security' || role == 'admin' || role == 'super_admin') {
      return [
        Spacer(),
        Container(
            child: GestureDetector(
                child: Image.asset("assets/images/stop_sign.png", height: 64),
                onTap: _showStopAlert),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)),
      ];
    }
    return [];
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
                title: Text(localize("Incident Dashboard"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
                leading: BackButton(color: Colors.grey.shade800),
                backgroundColor: Colors.grey.shade200,
                elevation: 0.0),
            body: Builder(builder: (context) {
              if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                                target: LatLng(alert.location.latitude,
                                    alert.location.longitude),
                                zoom: 16.4),
                            mapType: MapType.satellite,
                            myLocationButtonEnabled: false,
                            indoorViewEnabled: true,
                            markers: markers,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              color: Color.fromARGB(190, 229, 229, 234),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 4.0),
                                child: Row(
                                  children: [
                                    Text("${alert.title}",
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                        child: Text(
                                            "${dateFormatter.format(alert.timestamp)} ${timeFormatter.format(alert.timestamp)}",
                                            textAlign: TextAlign.end))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      flex: 12,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      color: Color.fromARGB(140, 229, 229, 234),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "${alert.body}",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      launch(
                                          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_schoolAddress)}");
                                    },
                                    child: Text(
                                      "${_schoolAddress}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 11, 48, 224),
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                                _mapData != null
                                    ? GestureDetector(
                                        onTap: _onSchoolMap,
                                        child: const Icon(
                                          Icons.map,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(localize("911 Callback: "),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0)),
                                Text(alert.createdBy,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 12.0)),
                                GestureDetector(
                                  onTap: () => showContactDialog(context,
                                      alert.createdBy, alert.reportedByPhone),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(
                                      alert.reportedByPhoneFormatted,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color.fromARGB(255, 11, 48, 224),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  localize("Reported by: "),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                                Text(alert.createdBy,
                                    style: TextStyle(fontSize: 12.0)),
                                GestureDetector(
                                  onTap: () => showContactDialog(context,
                                      alert.createdBy, alert.reportedByPhone),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 0.0),
                                    child: Text(alert.reportedByPhoneFormatted,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Color.fromARGB(
                                                255, 11, 48, 224))),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      if (widget.resolved) {
                        return Flexible(child: Container(), flex: 1);
                      } else {
                        return Flexible(
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                child: Row(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Container(
                                        child: GestureDetector(
                                            child: Image.asset(
                                                "assets/images/group_message_btn.png",
                                                height: 64),
                                            onTap: _showTalkAround),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.0)),
                                  ),
                                  Spacer(),
                                  Container(
                                      child: GestureDetector(
                                          child: Image.asset(
                                              "assets/images/broadcast_btn.png",
                                              height: 64),
                                          onTap: _showBroadcast),
                                      padding: EdgeInsets.all(4)),
                                  Spacer(),
                                  Container(
                                      child: GestureDetector(
                                          child: Image.asset(
                                              "assets/images/sop_btn.png",
                                              height: 64),
                                          onTap: _onSop),
                                      padding: EdgeInsets.all(4)),
                                  ..._buildStopAlertItems(),
                                ]),
                              ),
                            ),
                            flex: 3);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: <Widget>[
                          Text(localize("SECURITY COMMUNICATIONS"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          Spacer(),
                          Text(localize("Time"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 0.0),
                      child: Divider(color: Colors.red),
                    ),
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 0.0),
                          child: ListView.builder(
                            itemBuilder: _buildListItem,
                            itemCount: _messages.length,
                          ),
                        ),
                        flex: 9)
                  ],
                );
              }
            }));
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
