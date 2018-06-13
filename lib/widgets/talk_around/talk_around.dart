import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import 'chat/chat.dart';

class TalkAround extends StatefulWidget {
  @override
  _TalkAroundState createState() => new _TalkAroundState();
}

class _TalkAroundState extends State<TalkAround> {

  final TextEditingController _textController = new TextEditingController();
  bool _isLoading = true;

  String _schoolId = '';
  String _securityConversation = "";
  String _securityAdminConversation = "";

  DocumentReference _user;
  DocumentSnapshot _userSnapshot;

  void _handleSubmitted(String text) {
    _textController.clear();
  }

  getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    print("User ID");
    print(user.uid);
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
  Widget build(BuildContext context) {
    if(_isLoading) {
      getUserDetails();
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          title: new Text('Talk Around',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Center(child: new Text("Loading")),
      );
    }
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          bottom: new TabBar(
            labelColor: Colors.black,
            tabs: [
              new Tab(text: "Security"),
              new Tab(text: "Security + Admin")
            ],
          ),
          title: new Text('Talk Around',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new TabBarView(
          children: [
            new Chat(conversation: _securityConversation, user: _userSnapshot),
            new Chat(conversation: _securityAdminConversation, user: _userSnapshot)
          ],
        ),
      ),
    );
  }
}