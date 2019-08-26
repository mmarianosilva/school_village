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
    List<TalkAroundUser> channelList1 = List<TalkAroundUser>();
    TalkAroundChannel channel1 = TalkAroundChannel(
        "2345678",
        "Admin",
        false,
        channelList1);
    List<TalkAroundUser> channelList2 = List<TalkAroundUser>();
    channelList2.add(TalkAroundUser("User1", "GroupExample"));
    TalkAroundChannel channel2 = TalkAroundChannel(
        "34567890",
        "Security",
        false,
        channelList2);
    TalkAroundChannel channel3 = TalkAroundChannel(
        "234562278",
        "Council",
        false,
        channelList1);
    TalkAroundChannel channel4 = TalkAroundChannel(
        "3456789110",
        "Emergency Responders",
        false,
        channelList2);
    List<TalkAroundChannel> channelList = List<TalkAroundChannel>();
    channelList.add(channel1);
    channelList.add(channel2);
    channelList.add(channel3);
    channelList.add(channel4);

    List<TalkAroundUser> messageList1 = List<TalkAroundUser>();
    messageList1.add(TalkAroundUser("${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}", "Self"));
    messageList1.add(TalkAroundUser("Laythan Armor", "Designers"));
    TalkAroundChannel groupMessage1 = TalkAroundChannel(
        "662727",
        "",
        true,
        messageList1);
    List<TalkAroundUser> messageList2 = List<TalkAroundUser>();
    messageList2.add(TalkAroundUser("${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}", "Self"));
    messageList2.add(TalkAroundUser("Laythan Armor", "Designers"));
    messageList2.add(TalkAroundUser("Johnny Lambada", "Project Managers"));
    messageList2.add(TalkAroundUser("Michael Wiggins", "Owners"));
    TalkAroundChannel groupMessage2 = TalkAroundChannel(
        "72717",
        "",
        true,
        messageList2);
    List<TalkAroundUser> messageList3 = List<TalkAroundUser>();
    messageList3.add(TalkAroundUser("${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}", "Self"));
    messageList3.add(TalkAroundUser("Nemanja Stošić", "Developers"));
    TalkAroundChannel groupMessage3 = TalkAroundChannel(
        "1221211",
        "",
        true,
        messageList3);
    List<TalkAroundChannel> directMessageList = List<TalkAroundChannel>();
    directMessageList.add(groupMessage1);
    directMessageList.add(groupMessage2);
    directMessageList.add(groupMessage3);
    channelList.sort((item1, item2) => item1.name.compareTo(item2.name));
    directMessageList.sort((item1, item2) => _buildDirectMessageName(item1).compareTo(_buildDirectMessageName(item2)));
    setState(() {
      _channels.addAll(channelList);
      _directMessages.addAll(directMessageList);
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
