import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/search/search_bar.dart';
import 'package:school_village/widgets/talk_around/class/talk_around_create_class.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_item.dart';
import 'package:school_village/widgets/talk_around/talk_around_search.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';
import 'package:school_village/util/localizations/localization.dart';

class TalkAroundHome extends StatefulWidget {
  @override
  _TalkAroundHomeState createState() => _TalkAroundHomeState();
}

class _TalkAroundHomeState extends State<TalkAroundHome> {
  List<TalkAroundChannel> _channels = List<TalkAroundChannel>();
  List<TalkAroundChannel> _groupMessages = List<TalkAroundChannel>();
  List<TalkAroundChannel> _directMessages = List<TalkAroundChannel>();
  DocumentSnapshot _userSnapshot;
  String _schoolId;
  String _schoolRole;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchBarController = TextEditingController();
  StreamSubscription<QuerySnapshot> _messageListSubscription;
  StreamSubscription<QuerySnapshot> _channelListSubscription;
  bool _isLoading = false;

  void getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    final schoolId = await UserHelper.getSelectedSchoolID();
    final schoolRole = await UserHelper.getSelectedSchoolRole();
    FirebaseFirestore.instance.doc('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        _schoolRole = schoolRole;
      });
      getMessageList();
    });
  }

  void getMessageList() async {
    /* This _channelListSubscription shows up as the List of Channels User is a part of Example (Admin/Security)
    resolved by querying for the messages of this school/marina that this user's role is contained in'
    Also as a special case the "911 channel is removed from above list if this user wasnt the creator of it" */
    print("_schoolRole $_schoolRole and $_schoolId");
    _channelListSubscription = _firestore
        .collection("$_schoolId/messages")
        .where("roles", arrayContains: _schoolRole)
        .snapshots()
        .listen((snapshot) async {
      List<DocumentSnapshot> documentList = snapshot.docs;
      documentList.removeWhere((element) {
        print("Guess ChannelName ${element.data()['name']}");
        return (element.data()['name'] == "911 TalkAround Channel") &&
            ((element.data()['createdById'] != _userSnapshot.id) ||
                (element.data()['isActive'] == false));
      });
      Iterable<DocumentSnapshot> channels = documentList;
      List<Future<TalkAroundChannel>> processedChannels =
          channels.map((channel) async {
        return TalkAroundChannel.fromMapAndUsers(channel, null);
      }).toList();
      List<TalkAroundChannel> retrievedChannels =
          await Future.wait(processedChannels);
      print("RETR Channels ${retrievedChannels.length} and userref ${_userSnapshot.reference} and userid ${ _userSnapshot.id}");
      if (mounted) {
        setState(() {
          _isLoading = false;

          _channels = retrievedChannels;
        });
      }
    });
    if (_schoolRole != "school_admin" &&
        _schoolRole != "admin" &&
        _schoolRole != "district" &&
        _schoolRole != "super_admin") {
      // For the non elite/admin users  _messageListSubscription is the list of groups(1 on 1) that our user is a member of
      _messageListSubscription = _firestore
          .collection("$_schoolId/messages")
          .where("members", arrayContainsAny: [_userSnapshot.reference])
          .snapshots()
          .listen((snapshot) async {
            final String escapedSchoolId =
                _schoolId.substring("schools/".length);
            List<DocumentSnapshot> documentList = snapshot.docs;
            Iterable<DocumentSnapshot> groupMessages = documentList;
            List<Future<TalkAroundChannel>> processedGroupMessages =
                groupMessages.map((channel) async {
              Stream<TalkAroundUser> members =
                  Stream.fromIterable(channel.data()["members"])
                      .asyncMap((id) async {
                final DocumentSnapshot user = await id.get();
                TalkAroundUser member = TalkAroundUser.fromMapAndGroup(
                    user,
                    user.data()["associatedSchools"][escapedSchoolId] != null
                        ? user.data()["associatedSchools"][escapedSchoolId]
                            ["role"]
                        : "");
                return member;
              });
              List<TalkAroundUser> users = await members.toList();
              return TalkAroundChannel.fromMapAndUsers(channel, users);
            }).toList();
            List<TalkAroundChannel> retrievedGroupMessages =
                await Future.wait(processedGroupMessages);
            if (retrievedGroupMessages.isNotEmpty) {
              retrievedGroupMessages.sort((group1, group2) =>
                  group2.timestamp.compareTo(group1.timestamp));
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
                _directMessages = retrievedGroupMessages
                    .where((channel) => !channel.isClass)
                    .toList();
                _groupMessages = retrievedGroupMessages
                    .where((channel) => channel.isClass)
                    .toList()
                      ..sort(
                          (item1, item2) => item1.name.compareTo(item2.name));
              });
            }
          });
    } else {
      //Here _messageListSubscription seems to be the Admin channels that are probably auto generated or something
      _messageListSubscription = _firestore
          .collection("$_schoolId/messages")
          .snapshots()
          .listen((snapshot) async {
        final String escapedSchoolId = _schoolId.substring("schools/".length);
        List<DocumentSnapshot> documentList = snapshot.docs;
        Iterable<DocumentSnapshot> groupMessages = documentList.toList()
          ..removeWhere((chatroom) =>
              !(chatroom.data()["class"] ?? false) &&
              !(chatroom.data()["members"] != null &&
                  chatroom
                      .data()["members"]
                      .contains(_userSnapshot.reference)));
        List<Future<TalkAroundChannel>> processedGroupMessages =
            groupMessages.map((channel) async {
          Stream<TalkAroundUser> members =
              Stream.fromIterable(channel.data()["members"])
                  .asyncMap((id) async {
            final DocumentSnapshot user = await id.get();
            TalkAroundUser member = TalkAroundUser.fromMapAndGroup(
                user,
                user.data()["associatedSchools"][escapedSchoolId] != null
                    ? user.data()["associatedSchools"][escapedSchoolId]["role"]
                    : "");
            return member;
          });
          List<TalkAroundUser> users = await members.toList();
          return TalkAroundChannel.fromMapAndUsers(channel, users);
        }).toList();
        List<TalkAroundChannel> retrievedGroupMessages =
            await Future.wait(processedGroupMessages);
        if (retrievedGroupMessages.isNotEmpty) {
          retrievedGroupMessages.sort(
              (group1, group2) => group2.timestamp.compareTo(group1.timestamp));
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _directMessages = retrievedGroupMessages
                .where((channel) => !channel.isClass)
                .toList();
            _groupMessages = retrievedGroupMessages
                .where((channel) => channel.isClass)
                .toList()
                  ..sort((item1, item2) => item1.name.compareTo(item2.name));
          });
        }
      });
    }
  }

  Widget _buildChannelItem(int index) {
    TalkAroundChannel item = _channels[index];
    return TalkAroundRoomItem(
        item: item, username: "", onTap: () => _handleOnTap(item));
  }

  Widget _buildDirectMessageItem(int index) {
    TalkAroundChannel item = _directMessages[index];
    return TalkAroundRoomItem(
        item: item,
        username: UserHelper.getDisplayName(_userSnapshot),
        onTap: () => _handleOnTap(item));
  }

  Widget _buildGroupMessageItem(int index) {
    TalkAroundChannel item = _groupMessages[index];
    return TalkAroundRoomItem(
        item: item,
        username: UserHelper.getDisplayName(_userSnapshot),
        onTap: () => _handleOnTap(item));
  }

  void _handleOnTap(TalkAroundChannel item) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TalkAroundMessaging(channel: item)));
  }

  @override
  void initState() {
    getUserDetails();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_messageListSubscription != null) {
      _messageListSubscription.cancel();
    }
    if (_channelListSubscription != null) {
      _channelListSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(localize("Talk Around")),
        backgroundColor: Color.fromARGB(255, 134, 165, 177),
      ),
      backgroundColor: Color.fromARGB(255, 7, 133, 164),
      body: Builder(
        builder: (BuildContext context) {
          if (_isLoading) {
            return Container(
              color: Color.fromARGB(255, 7, 133, 164),
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }
          return Container(
            color: Color.fromARGB(255, 7, 133, 164),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Color.fromARGB(255, 10, 104, 127),
                  child: Row(
                    children: <Widget>[
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 64.0,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/images/sv_icon_menu.png"),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TalkAroundSearch(true, null)))
                            },
                            child: AbsorbPointer(
                              absorbing: true,
                              child: SearchBar(
                                controller: _searchBarController,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            _channels?.isNotEmpty ?? false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                        localize("Channels").toUpperCase(),
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 199, 199, 204)),
                                        textAlign: TextAlign.start),
                                  )
                                : const SizedBox(),
                            ...List.generate(
                              _channels != null ? _channels.length : 0,
                              _buildChannelItem,
                            ),
                            _groupMessages?.isNotEmpty ?? false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                        localize("Group").toUpperCase(),
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 199, 199, 204)),
                                        textAlign: TextAlign.start),
                                  )
                                : const SizedBox(),
                            ...List.generate(
                                _groupMessages != null
                                    ? _groupMessages.length
                                    : 0,
                                _buildGroupMessageItem),
                            _directMessages?.isNotEmpty ?? false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                        localize("Direct Messages")
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 199, 199, 204)),
                                        textAlign: TextAlign.start),
                                  )
                                : const SizedBox(),
                            ...List.generate(
                              _directMessages != null
                                  ? _directMessages.length
                                  : 0,
                              _buildDirectMessageItem,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: MaterialButton(
                            color: Color(0xff007aff),
                            elevation: 4.0,
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TalkAroundCreateClass())),
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                localize('Create Group'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
