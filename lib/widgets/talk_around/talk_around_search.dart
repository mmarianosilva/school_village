import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/search/search_bar.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_item.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';

class TalkAroundSearch extends StatefulWidget {
  @override
  _TalkAroundSearchState createState() => _TalkAroundSearchState();
}

class _TalkAroundSearchState extends State<TalkAroundSearch> {
  List<TalkAroundChannel> _chats;
  List<TalkAroundChannel> _filteredList;
  final TextEditingController _searchBarController = TextEditingController();
  DocumentSnapshot _userSnapshot;
  String _schoolId;

  Widget _buildListItem(BuildContext context, int index) {
    final TalkAroundChannel item = _filteredList[index];
    return TalkAroundRoomItem(
      item: item,
      username: "${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}",
    );
  }

  void _setupTextInputController() {

  }

  void _onSearchTextInput(String input) {
    final List<TalkAroundChannel> filter = _chats.where((channel) {
      input = input.toLowerCase();
      return channel.name.toLowerCase().contains(input) ||
          (channel.members.where((member) => member.name.toLowerCase().contains(input)).isNotEmpty); // For group messages
    }).toList();
    setState(() {
      _filteredList = filter;
    });
  }

  void _getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    Firestore.instance.document('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
      });
      _getChatrooms();
    });
  }

  void _getChatrooms() async {
    final escapedSchoolId = _schoolId.substring("schools/".length);
    final QuerySnapshot channels = await Firestore
        .instance
        .collection("$_schoolId/messages")
        .where("members", arrayContains: _userSnapshot.documentID)
        .getDocuments();
    List<Future<TalkAroundChannel>> processedChannels = channels.documents.map((channel) async {
      Stream<TalkAroundUser> members = Stream.fromIterable(channel.data["members"]).asyncMap((id) async {
        final DocumentSnapshot user = await Firestore.instance.document("users/$id").get();
        TalkAroundUser member = TalkAroundUser.fromMapAndGroup(user, user.data["associatedSchools"][escapedSchoolId]["groups"].keys.first);
        return member;
      });
      List<TalkAroundUser> users = await members.toList();
      return TalkAroundChannel.fromMapAndUsers(channel, users);
    }).toList();
    List<TalkAroundChannel> retrievedChannels = await Future.wait(processedChannels);
    retrievedChannels = retrievedChannels.where((channel) {
      return channel.members.length != 1 || channel.members.first.name != "${_userSnapshot.data["firstName"]} ${_userSnapshot.data["lastName"]}";
    }).toList();

    final QuerySnapshot users = await Firestore
        .instance
        .collection("users")
        .where("associatedSchools.$escapedSchoolId.allowed", isEqualTo: true)
        .getDocuments();
    users.documents.removeWhere((doc) => doc.documentID == _userSnapshot.documentID ||
        retrievedChannels.firstWhere((item) =>
            item.members.firstWhere((member) =>
              member.id == doc.documentID,
                orElse: () => null) != null,
            orElse: () => null)
            != null);
    final List<TalkAroundChannel> userList = users.documents.map((doc) {
      return TalkAroundChannel(
        "",
        "",
        true,
        List.of([TalkAroundUser(doc.documentID, doc.data["firstName"] + doc.data["lastName"], doc.data["associatedSchools"][escapedSchoolId]["groups"] != null ? doc.data["associatedSchools"][escapedSchoolId]["groups"].keys.first : "")])
      );
    }).toList();
    final List<TalkAroundChannel> fullList = [...userList, ...retrievedChannels];
    setState(() {
      _chats = fullList;
      _filteredList = _chats;
    });
  }

  @override
  void initState() {
    _getUserDetails();
    _setupTextInputController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        backgroundColor: Color.fromARGB(255, 10, 104, 127),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          color: Color.fromARGB(255, 10, 104, 127),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SearchBar(
                  controller: _searchBarController,
                  onTextInput: _onSearchTextInput,
                ),
              ),
              MaterialButton(
                child: Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context)
              )
            ],
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 7, 133, 164),
        child: ListView.builder(
            itemBuilder: _buildListItem,
            itemCount: _filteredList != null ? _filteredList.length : 0,
        ),
      ),
    );
  }
}
