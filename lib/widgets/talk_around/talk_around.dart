import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/colors.dart';
import '../../util/user_helper.dart';
import 'chat/chat.dart';

class TalkAround extends StatefulWidget {
  final String conversationId;

  final GlobalKey<_TalkAroundState> key;

  static Route _route;
  static TalkAround _talkAround;
  static String role;

  static navigate(conversationId, context) {
    if (_route != null && _route.isCurrent) {
//      final talkAroundState = _talkAround.key.currentState;
//      talkAroundState.tabController.index =
//          talkAroundState.getInitialIndex(conversationId);
      return true;
    } else {
      _talkAround =
          TalkAround(key: GlobalKey(), conversationId: conversationId);
      _route = MaterialPageRoute(
        builder: (context) => _talkAround,
      );
      Navigator.push(
        context,
        _route,
      );
      return false;
    }
  }

  static triggerNewMessage(String conversationId, String title) {
    _talkAround.key.currentState.newMessage(title, conversationId);
  }

  TalkAround({this.key, this.conversationId}) : super(key: key);

  @override
  _TalkAroundState createState() =>
      new _TalkAroundState(conversationId: conversationId);
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

  TabController tabController;

  @override
  void initState() {
    tabController = TabController(
        length: 2,
        initialIndex: getInitialIndex(this.conversationId),
        vsync: this);
    getUserDetails();
    super.initState();
  }

  getInitialIndex(conversationId) {
    return conversationId == 'security-admin' ? 1 : 0;
  }

  getTabName(id) {
    if (id == 'security-admin') {
      return 'Security & Admin';
    }
    return 'Security';
  }

  newMessage(title, conversationId) {
    newMessageConversationId = conversationId;
    if (conversationId == 'security-admin') {
      if (tabController.index == 0) {
        showNewMessage = true;
      }
    } else {
      if (tabController.index == 1) {
        showNewMessage = true;
      }
    }

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
      return GestureDetector(
          onTap: () {
            tabController.index =
                newMessageConversationId == 'security-admin' ? 1 : 0;
          },
          child: Container(
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
                    Row(
                      children: [
                        Text('New Message:',
                            style: TextStyle(
                                inherit: false,
                                fontSize: 13.0,
                                color: SVColors.colorFromHex('#333333'))),
                        SizedBox(width: 10.0),
                        Text(getTabName(newMessageConversationId),
                            style: TextStyle(
                                inherit: false,
                                fontSize: 14.0,
                                color: SVColors.talkAroundBlue)),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      newMessageText,
                      style: TextStyle(
                          inherit: false,
                          color: SVColors.colorFromHex('#333333'),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )
                  ])));
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
          title: new Text('Talk Around',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          leading: new BackButton(color: Colors.grey.shade800),
        ),
        body: new Center(child: new Text("Loading")),
      );
    }
    return Stack(
      children: [
        DefaultTabController(
            length: 2,
            child: Theme(
              data: ThemeData(
                primaryColor: Colors
                    .white, //Changing this will change the color of the TabBar
              ),
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize:
                      Size.fromHeight(kToolbarHeight + kTextTabBarHeight + 8),
                  child: Column(children: [
                    AppBar(
                      backgroundColor: Color.fromRGBO(241, 241, 245, 1.0),
                      elevation: 0.0,
                      title: new Text('Security Talk-Around',
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.black)),
                      leading: new BackButton(color: Colors.grey.shade800),
                    ),
                    Card(
                        elevation: 2.0,
                        child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: TabBar(
                                isScrollable: true,
                                indicatorColor: Color.fromRGBO(255, 0, 40, 1.0),
                                labelColor: Colors.black,
                                tabs: [
                                  Tab(text: "Security"),
                                  Tab(text: "Security & Admin")
                                ],
                                controller: tabController,
                              ),
                            )))
                  ]),
                ),
                body: TabBarView(
                  controller: tabController,
                  children: [
                    Chat(
                      conversation: _securityConversation,
                      user: _userSnapshot,
                      // showInput: TalkAround.role == 'school_security',
                      showInput: true
                    ),
                    Chat(
                      conversation: _securityAdminConversation,
                      user: _userSnapshot,
                      // showInput: TalkAround.role == 'school_admin',
                      showInput: true,
                    )
                  ],
                ),
              ),
            )),
        _buildNotificationWidget()
      ],
    );
  }
}
