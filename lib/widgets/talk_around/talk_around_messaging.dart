import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_detail.dart';
import 'package:school_village/widgets/talk_around/talk_around_search.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';

class TalkAroundMessaging extends StatefulWidget {
  final TalkAroundChannel channel;

  const TalkAroundMessaging({Key key, this.channel}) : super(key: key);

  @override
  _TalkAroundMessagingState createState() => _TalkAroundMessagingState(channel);
}

class _TalkAroundMessagingState extends State<TalkAroundMessaging> with TickerProviderStateMixin {
  final TalkAroundChannel channel;
  DocumentSnapshot _userSnapshot;
  String _schoolId;
  bool isLoading = true;
  final TextEditingController messageInputController = TextEditingController();

  _TalkAroundMessagingState(this.channel);

  void _getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        isLoading = false;
      });
    });
  }

  String _buildChannelName() {
    if (!channel.direct) {
      return "#${channel.name}";
    }
    if (_userSnapshot != null) {
      final String userId = _userSnapshot.documentID;
      final List<TalkAroundUser> members = channel.members.where((user) => user.id.documentID != userId).toList();
      members.sort((user1, user2) => user1.name.compareTo(user2.name));
      if (members.length == 1) {
        return members.first.name;
      }
      String name = "";
      for(int i = 0; i < members.length - 1; i++) {
        name += "${members[i].name}, ";
      }
      return "$name${members.last.name}";
    }
    return "Loading...";
  }

  String _buildTitle() {
    if (!channel.direct) {
      return "Talk-Around";
    }
    if (channel.members.length == 2) {
      return "Talk-Around: Direct Message";
    }
    return "Talk-Around: Group Message";

  }

  List<Widget> _buildChannelFooterOptions() {
    if (channel.direct) {
      return [
        GestureDetector(
          child: Icon(Icons.photo_camera, color: Colors.black26,),
          onTap: _onTakePhoto,
        ),
        GestureDetector(
          child: Icon(Icons.photo_size_select_actual, color: Colors.black26),
          onTap: _onSelectPhoto,
        ),
        GestureDetector(
          child: Icon(Icons.add_circle_outline, color: Colors.black26),
          onTap: _onAddTapped,
        ),
      ];
    }
    return [
      GestureDetector(
        child: Icon(Icons.photo_camera, color: Colors.black26,),
        onTap: _onTakePhoto,
      ),
      GestureDetector(
        child: Icon(Icons.photo_size_select_actual, color: Colors.black26),
        onTap: _onSelectPhoto,
      ),
    ];
  }

  void _onAddTapped() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TalkAroundSearch(false, channel)));
  }

  void _onChannelNameTapped() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TalkAroundRoomDetail(channel)));
  }

  void _onTakePhoto() {

  }

  void _onSelectPhoto() {

  }

  void _onSend() async {
    if (messageInputController.text.isEmpty) {
      return;
    }
    final Map<String, dynamic> messageData = {
      "img" : null,
      "thumb" : null,
      "author" : "${_userSnapshot.data["firstName"]} ${_userSnapshot["lastName"]}",
      "authorId" : _userSnapshot.documentID,
      "location" : await UserHelper.getLocation(),
      "timestamp" : FieldValue.serverTimestamp(),
      "body" : messageInputController.text,
      "phone" : _userSnapshot.data["phone"]
    };
    try {
      Firestore.instance.runTransaction((transaction) async {
        CollectionReference messages = Firestore.instance.collection(
            "$_schoolId/messages/${channel.id}/messages");
        await transaction.set(messages.document(), messageData);
      });
      messageInputController.clear();
    } on Exception catch (ex) {
      print("$ex");
    }
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Color.fromARGB(255, 241, 241, 245),
            title: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_buildTitle(), style: TextStyle(fontSize: 16, color: Colors.black)),
                  GestureDetector(
                    child: Text(
                        _buildChannelName(),
                        style: TextStyle(fontSize: 16, color: Colors.blue)
                    ),
                    onTap: _onChannelNameTapped,
                  )
                ],
              ),
            )
        ),
        body:
        Builder(builder: (context) {
          if (isLoading) {
            return Center(
                child: Column(
                  children: <Widget>[
                    Text("Loading..."),
                    CircularProgressIndicator()
                  ],
                )
            );
          } else {
            return Column(
              children: <Widget>[
                Expanded(
                  child: Chat(
                    conversation: "$_schoolId/messages/${channel.id}",
                    showInput: false,
                    user: _userSnapshot,
                    reverseInput: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.black,
                            border: Border.all(
                                color: Colors.white,
                                width: 1.0
                            )
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: messageInputController,
                                decoration: InputDecoration(
                                    hintText: "Message ${_buildChannelName()}",
                                    hintStyle: TextStyle(color: Color.fromARGB(255, 187, 187, 187))
                                ),
                                maxLines: null,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            GestureDetector(
                              child: Icon(Icons.send, color: Color.fromARGB(255, 187, 187, 187)),
                              onTap: _onSend,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _buildChannelFooterOptions()
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }
        })
    );
  }
}
