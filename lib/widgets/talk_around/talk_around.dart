import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:school_village/util/localizations/localization.dart';

class TalkAround extends StatefulWidget {
  final TalkAroundChannel conversation;

  final GlobalKey<_TalkAroundState> key;

  TalkAround({this.key, this.conversation}) : super(key: key);

  @override
  _TalkAroundState createState() => new _TalkAroundState(conversation: conversation);
}

class _TalkAroundState extends State<TalkAround>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool showNewMessage = false;
  String _schoolId = '';
  String _securityConversation = "";
  String _securityAdminConversation = "";
  String newMessageText = "";
  String newMessageConversationId = "";
  final TalkAroundChannel conversation;

  _TalkAroundState({this.conversation});

  DocumentReference _user;
  DocumentSnapshot _userSnapshot;

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    _user = Firestore.instance.document('users/${user.uid}');
    _user.get().then((user) {
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

  newMessage(title, conversationId) {
    newMessageConversationId = conversationId;
    newMessageText = title;

    setState(() {});

    if (showNewMessage) {
      Timer(const Duration(milliseconds: 4000), () {
        setState(() {
          showNewMessage = false;
        });
      });
    }
  }

  _buildNotificationWidget() {
    if (showNewMessage)
      return Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints.expand(height: 70.0),
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 80.0),
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: SVColors.colorFromHex('#dfdfe2')),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localize('New Message:'),
                    style: TextStyle(
                        inherit: false,
                        fontSize: 13.0,
                        color: SVColors.colorFromHex('#333333'))),
                SizedBox(height: 5.0),
                Text(
                  newMessageText,
                  style: TextStyle(
                      inherit: false,
                      color: SVColors.colorFromHex('#333333'),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                )
              ]));
    else
      return SizedBox(width: 0.0, height: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: BaseAppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          title: Text(localize('Talk Around'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Center(child: Text(localize("Loading"))),
      );
    }
    return Scaffold(
      appBar: BaseAppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          title: Text(conversation.direct ? conversation.groupConversationName(UserHelper.getDisplayName(_userSnapshot)) : '${conversation.name}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          leading: BackButton(color: Colors.grey.shade800),
      ),
      body: Chat(
        conversation: "${_schoolId}/messages/${conversation.id}",
        user: _userSnapshot,
        showInput: true,
        reverseInput: true,
      ),
    );
  }
}
