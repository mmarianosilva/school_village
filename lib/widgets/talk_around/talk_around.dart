import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import '../../util/user_helper.dart';
import 'chat/chat.dart';

class TalkAround extends StatefulWidget {
  final String conversationId;

  TalkAround({Key key, this.conversationId}) : super(key: key);

  @override
  _TalkAroundState createState() => new _TalkAroundState(conversationId: conversationId);
}

class _TalkAroundState extends State<TalkAround> with SingleTickerProviderStateMixin{
  bool _isLoading = true;

  String _schoolId = '';
  String _securityConversation = "";
  String _securityAdminConversation = "";
  final String conversationId;

  _TalkAroundState({this.conversationId});

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

  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: conversationId == 'security-admin' ? 1 : 0, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      getUserDetails();
      return Scaffold(
        appBar: BaseAppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          title: new Text('Talk Around', textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Center(child: new Text("Loading")),
      );
    }
    return DefaultTabController(
        length: 2,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.white, //Changing this will change the color of the TabBar
          ),
          child:  Scaffold(
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
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Center(
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: Color.fromRGBO(255, 0, 40, 1.0),
                        labelColor: Colors.black,
                        tabs: [Tab(text: "Security"), Tab(text: "Security & Admin")],
                        controller: _tabController,
                      ),
                    ))
              ]),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                Chat(conversation: _securityConversation, user: _userSnapshot),
                Chat(conversation: _securityAdminConversation, user: _userSnapshot)
              ],
            ),
          ),
        ));
  }
}
