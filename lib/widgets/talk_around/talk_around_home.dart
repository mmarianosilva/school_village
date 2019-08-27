import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
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
    _firestore
        .collection("$_schoolId/messages")
        .where("members", arrayContains: _userSnapshot.documentID)
        .getDocuments()
        .then((channelList) async {
          List<DocumentSnapshot> documentList = channelList.documents;
          Iterable<DocumentSnapshot> channels = documentList.where((item) => !item.data["direct"]);
          Iterable<DocumentSnapshot> groupMessages = documentList.where((item) => item.data["direct"]);
          List<Future<TalkAroundChannel>> processedChannels = channels.map((channel) async {
            Stream<TalkAroundUser> members = Stream.fromIterable(channel.data["members"]).asyncMap((id) async {
              final DocumentSnapshot user = await _firestore.document("users/$id").get();
              TalkAroundUser member = TalkAroundUser.fromMapAndGroup(user.data, channel.data["name"]);
              return member;
            });
            List<TalkAroundUser> users = await members.toList();
            return TalkAroundChannel.fromMapAndUsers(channel, users);
          }).toList();
          List<TalkAroundChannel> retrievedChannels = await Future.wait(processedChannels);
          List<Future<TalkAroundChannel>> processedGroupMessages = groupMessages.map((channel) async {
            Stream<TalkAroundUser> members = Stream.fromIterable(channel.data["members"]).asyncMap((id) async {
              final DocumentSnapshot user = await _firestore.document("users/$id").get();
              TalkAroundUser member = TalkAroundUser.fromMapAndGroup(user.data, "");
              return member;
            });
            List<TalkAroundUser> users = await members.toList();
            return TalkAroundChannel.fromMapAndUsers(channel, users);
          }).toList();
          List<TalkAroundChannel> retrievedGroupMessages = await Future.wait(processedGroupMessages);
          setState(() {
            _channels = retrievedChannels;
            _directMessages = retrievedGroupMessages;
          });
    });
  }

  Widget _buildChannelItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
                "#",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic)),
            flex: 1,
            fit: FlexFit.tight,
          ),
          Flexible(
              child: Text(
                  _channels[index].name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0),
              ),
              flex: 13,
              fit: FlexFit.tight
          )
        ],
      ),
    );
  }

  Widget _buildDirectMessageItem(BuildContext context, int index) {
    TalkAroundChannel item = _directMessages[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: Builder(builder: (context) {
                if (item.members.length > 2) {
                  return Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(const Radius.circular(4.0))
                      ),
                      child: Text(
                          "${item.members.length - 1}",
                          style: TextStyle(color: Color.fromARGB(255, 10, 104, 127), fontSize: 16.0),
                          textAlign: TextAlign.center),
                    ),
                  );
                } else {
                  return Text(
                      "•",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                      textAlign: TextAlign.center
                  );
                }
              }),
              flex: 1,
              fit: FlexFit.tight
          ),
          Flexible(
              child: Text(
                  _buildDirectMessageName(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white, fontSize: 16.0)
              ),
              flex: 12,
              fit: FlexFit.tight
          ),
          Flexible(
            child: Builder(builder: (context) {
              if (item.members.length > 2) {
                return Text(
                    "Group",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0));
              } else {
                return Text(
                  item.members.first.name != "${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}" ?
                  item.members.first.group : item.members[1].group,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0));
              }
            }),
            flex: 3,
            fit: FlexFit.tight,
          )
        ],
      ),
    );
  }

  String _buildDirectMessageName(TalkAroundChannel item) {
    List<String> names = item.members.map((item) => item.name).toList();
    names.removeWhere((name) => name == "${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}");
    names.sort((name1, name2) => name1.compareTo(name2));
    String output = "";
    int i = 0;
    while ( i < names.length - 1) {
      output += "${names[i]}, ";
      i++;
    }
    output += names[names.length - 1];
    return output;
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
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
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/images/sv_icon_menu.png"),
                      ),
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
