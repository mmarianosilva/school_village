import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
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
    if (_isLoading) {
      getUserDetails();
      return  Scaffold(
        appBar: BaseAppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          title: new Text('Talk Around', textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Center(child: new Text("Loading")),
      );
    }
    return  DefaultTabController(
        length: 2,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.white, //Changing this will change the color of the TabBar
          ),
          child: new Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
              child: Column(children: [
                AppBar(
                  backgroundColor: Color.fromRGBO(241, 241, 245, 1.0),
                  elevation: 0.0,
                  title: new Text('Security Talk-Around',
                      textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
                  leading: new BackButton(color: Colors.grey.shade800),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: TabBar(
                    isScrollable: true,
                    indicatorColor: Color.fromRGBO(255, 0, 40, 1.0),
                    labelColor: Colors.black,
                    tabs: [Tab(text: "Security"), new Tab(text: "Security & Admin")],
                  ),)
                )

              ]),
            ),
            body: TabBarView(
              children: [
                Chat(conversation: _securityConversation, user: _userSnapshot),
                Chat(conversation: _securityAdminConversation, user: _userSnapshot)
              ],
            ),
          ),
        ));
  }
}
