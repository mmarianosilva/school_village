import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/search/search_bar.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_item.dart';
import 'package:school_village/widgets/talk_around/talk_around_search.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';

class TalkAroundHome extends StatefulWidget {
  @override
  _TalkAroundHomeState createState() => _TalkAroundHomeState();
}

class _TalkAroundHomeState extends State<TalkAroundHome> {
  List<TalkAroundChannel> _channels = List<TalkAroundChannel>();
  List<TalkAroundChannel> _directMessages = List<TalkAroundChannel>();
  DocumentSnapshot _userSnapshot;
  String _schoolId;
  final Firestore _firestore = Firestore.instance;
  final TextEditingController _searchBarController = TextEditingController();
  StreamSubscription<QuerySnapshot> _messageListSubscription;

  void getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
      });
      getMessageList();
    });
  }

  void getMessageList() async {
    _messageListSubscription = _firestore
        .collection("$_schoolId/messages")
        .where("members", arrayContains: _userSnapshot.reference)
        .snapshots()
        .listen((snapshot) async {
          final String escapedSchoolId = _schoolId.substring("schools/".length);
          List<DocumentSnapshot> documentList = snapshot.documents;
          Iterable<DocumentSnapshot> channels = documentList.where((item) => !item.data["direct"]);
          Iterable<DocumentSnapshot> groupMessages = documentList.where((item) => item.data["direct"]);
          List<Future<TalkAroundChannel>> processedChannels = channels.map((channel) async {
            Stream<TalkAroundUser> members = Stream.fromIterable(channel.data["members"]).asyncMap((id) async {
              final DocumentSnapshot user = await id.get();
              TalkAroundUser member = TalkAroundUser.fromMapAndGroup(user, user.data["associatedSchools"][escapedSchoolId] != null ? user.data["associatedSchools"][escapedSchoolId]["role"] : "");
              return member;
            });
            List<TalkAroundUser> users = await members.toList();
            return TalkAroundChannel.fromMapAndUsers(channel, users);
          }).toList();
          List<TalkAroundChannel> retrievedChannels = await Future.wait(processedChannels);
          List<Future<TalkAroundChannel>> processedGroupMessages = groupMessages.map((channel) async {
            Stream<TalkAroundUser> members = Stream.fromIterable(channel.data["members"]).asyncMap((id) async {
              final DocumentSnapshot user = await id.get();
              TalkAroundUser member = TalkAroundUser.fromMapAndGroup(user, user.data["associatedSchools"][escapedSchoolId] != null ? user.data["associatedSchools"][escapedSchoolId]["role"] : "");
              return member;
            });
            List<TalkAroundUser> users = await members.toList();
            return TalkAroundChannel.fromMapAndUsers(channel, users);
          }).toList();
          List<TalkAroundChannel> retrievedGroupMessages = await Future.wait(processedGroupMessages);
          if (mounted) {
            setState(() {
              _channels = retrievedChannels;
              _directMessages = retrievedGroupMessages;
            });
          }
    });
  }

  Widget _buildChannelItem(BuildContext context, int index) {
    TalkAroundChannel item = _channels[index];
    return TalkAroundRoomItem(
        item: item,
        username: "",
        onTap: () => _handleOnTap(item)
    );
  }

  Widget _buildDirectMessageItem(BuildContext context, int index) {
    TalkAroundChannel item = _directMessages[index];
    return TalkAroundRoomItem(
      item: item,
      username: "${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}",
      onTap: () => _handleOnTap(item)
    );
  }

  void _handleOnTap(TalkAroundChannel item) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TalkAroundMessaging(channel: item)));
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    if (_messageListSubscription != null) {
      _messageListSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text("Talk Around"),
        backgroundColor: Color.fromARGB(255, 134, 165, 177),
      ),
      body: Container(
        color: Color.fromARGB(255, 7, 133, 164),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  color: Color.fromARGB(255, 10, 104, 127),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset("assets/images/sv_icon_menu.png"),
                      ),
                      Expanded(
                        child: SearchBar(
                          controller: _searchBarController,
                          onTap: () => { Navigator.push(context, MaterialPageRoute(builder: (context) => TalkAroundSearch(true, null))) },
                        ),
                      )
                    ],
                  ),
                ),
                flex: 1
            ),
            Spacer(flex: 1),
            Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "Channels".toUpperCase(),
                      style: TextStyle(color: Color.fromARGB(255, 199, 199, 204)),
                      textAlign: TextAlign.start
                  ),
                )
            ),
            Flexible(
                child: ListView.builder(
                  itemBuilder: _buildChannelItem,
                  itemCount: _channels.length,
                ),
                flex: 6,
                fit: FlexFit.loose
            ),
            Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "Direct Messages".toUpperCase(),
                      style: TextStyle(color: Color.fromARGB(255, 199, 199, 204)),
                      textAlign: TextAlign.start
                  ),
                )
            ),
            Flexible(
                child: ListView.builder(
                  itemBuilder: _buildDirectMessageItem,
                  itemCount: _directMessages.length,
                ),
                flex: 6
            )
          ],
        ),
      ),
    );
  }
}
