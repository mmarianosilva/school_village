import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/permission_matrix.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/search/search_bar.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_item.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';
import 'package:school_village/util/localizations/localization.dart';

class TalkAroundSearch extends StatefulWidget {
  final bool _createMode;
  final TalkAroundChannel _channel;

  const TalkAroundSearch(this._createMode, this._channel, {Key key})
      : super(key: key);

  @override
  _TalkAroundSearchState createState() => _TalkAroundSearchState();
}

class _TalkAroundSearchState extends State<TalkAroundSearch> {
  List<TalkAroundChannel> _chats;
  List<TalkAroundChannel> _filteredList;
  final TextEditingController _searchBarController = TextEditingController();
  final FocusNode _searchBarFocusNode = FocusNode();
  DocumentSnapshot _userSnapshot;
  String _schoolId;
  String _role;
  bool _isLoading = false;

  Widget _buildListItem(BuildContext context, int index) {
    final TalkAroundChannel item = _filteredList[index];
    return TalkAroundRoomItem(
      item: item,
      username: UserHelper.getDisplayName(_userSnapshot),
      onTap: () => _handleOnTap(item),
    );
  }

  void _handleOnTap(TalkAroundChannel item) async {
    TalkAroundChannel selectedChannel = item;
    if (item.id.isEmpty) {
      final DocumentReference userRef = item.members.first.id;
      final List<DocumentReference> members = List<DocumentReference>();
      members.add(userRef);
      if (!widget._createMode) {
        members.addAll(widget._channel.members.map((member) => member.id));
      } else {
        members.add(_userSnapshot.reference);
      }
      Map<String, dynamic> channel = Map<String, dynamic>();
      channel["direct"] = true;
      channel["name"] = "";
      channel["members"] = members;
      final Map<String, dynamic> channelDoc =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentReference documentReference = await FirebaseFirestore.instance
            .collection("$_schoolId/messages")
            .add(channel);
        return {
          "id": documentReference.id,
        };
      });
      final DocumentSnapshot firebaseModel = await FirebaseFirestore.instance
          .doc("$_schoolId/messages/${channelDoc["id"]}")
          .get();
      final String escapedSchoolId = _schoolId.substring("schools/".length);
      Stream<TalkAroundUser> participants =
          Stream.fromIterable(members).asyncMap((id) async {
        final DocumentSnapshot user = await id.get();
        TalkAroundUser member = TalkAroundUser.fromMapAndGroup(
            user,
            user.data()["associatedSchools"][escapedSchoolId] != null
                ? user.data()["associatedSchools"][escapedSchoolId]["role"]
                : "");
        return member;
      });
      List<TalkAroundUser> users = await participants.toList();
      selectedChannel = TalkAroundChannel.fromMapAndUsers(firebaseModel, users);
    }
    if (widget._createMode) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TalkAroundMessaging(channel: selectedChannel)));
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TalkAroundMessaging(channel: selectedChannel)),
          (route) => route.settings.name == '/talk-around');
    }
  }

  void _setupTextInputController() {}

  void _onSearchTextInput(String input) {
    final List<TalkAroundChannel> filter = _chats.where((channel) {
      input = input.toLowerCase();
      return channel.name.toLowerCase().contains(input) ||
          (channel.members
              .where((member) => member.name.toLowerCase().contains(input))
              .isNotEmpty); // For group messages
    }).toList();
    setState(() {
      _filteredList = filter;
    });
  }

  void _getUserDetails() async {
    User user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    _role = await UserHelper.getSelectedSchoolRole();
    FirebaseFirestore.instance.doc('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
      });
      _getChatrooms();
    });
  }

  void _getChatrooms() async {
    final escapedSchoolId = _schoolId.substring("schools/".length);
    final username = UserHelper.getDisplayName(_userSnapshot);
    final QuerySnapshot users = await FirebaseFirestore.instance
        .collection("users")
        .where("associatedSchools.$escapedSchoolId.allowed", isEqualTo: true)
        .get();

    final List<DocumentSnapshot> modifiableUserList = [...users.docs];
    modifiableUserList
        .removeWhere((doc) => doc.id == _userSnapshot.id);

    if (!widget._createMode) {
      modifiableUserList.removeWhere((doc) =>
          widget._channel.members.firstWhere(
              (member) => member.id == doc.reference,
              orElse: () => null) !=
          null);
    }

    final List<TalkAroundChannel> retrievedChannels = List<TalkAroundChannel>();

    if (widget._createMode) {
      final QuerySnapshot channels = await FirebaseFirestore.instance
          .collection("$_schoolId/messages")
          .where("members", arrayContains: _userSnapshot.reference)
          .get();
      List<Future<TalkAroundChannel>> processedChannels =
          channels.docs.map((channel) async {
        Stream<TalkAroundUser> members =
            Stream.fromIterable(channel.data()["members"]).asyncMap((id) async {
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
      retrievedChannels.addAll(await Future.wait(processedChannels));
      retrievedChannels.removeWhere((channel) =>
          !(channel.members.length != 1 ||
              channel.members.first.name != username));



      modifiableUserList.removeWhere((doc) =>
          retrievedChannels.firstWhere(
              (item) =>
                  item.members.firstWhere(
                      (member) => member.id.id == doc.id,
                      orElse: () => null) !=
                  null && (item.direct ?? false),
              orElse: () => null) !=
          null);
    }

    final List<String> talkAroundPermissions =
        PermissionMatrix.getTalkAroundPermissions(_role);
    modifiableUserList.removeWhere((userSnapshot) =>
        userSnapshot.data()["associatedSchools"][escapedSchoolId] == null ||
        !talkAroundPermissions.contains(
            userSnapshot.data()["associatedSchools"][escapedSchoolId]["role"]));

    final List<TalkAroundChannel> userList = modifiableUserList.map((doc) {
      return TalkAroundChannel(
          "",
          "",
          true,
          null,
          List.of([
            TalkAroundUser(
                doc.reference,
                UserHelper.getDisplayName(doc),
                doc.data()["associatedSchools"][escapedSchoolId] != null
                    ? TalkAroundUser.mapGroup(
                        doc.data()["associatedSchools"][escapedSchoolId]["role"])
                    : "")
          ]));
    }).toList();

    final List<TalkAroundChannel> fullList = [
      ...userList,
      ...retrievedChannels
    ];
    fullList.sort((channel1, channel2) => channel1
        .groupConversationName(username)
        .compareTo(channel2.groupConversationName(username)));
    setState(() {
      _chats = fullList;
      _filteredList = _chats;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getUserDetails();
    _setupTextInputController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _searchBarFocusNode.requestFocus();
      setState(() {
        _isLoading = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        return Future.value(true);
      },
      child: Scaffold(
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
                    focusNode: _searchBarFocusNode,
                  ),
                ),
                MaterialButton(
                    child: Text(localize("Cancel"),
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
        ),
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
              child: ListView.builder(
                itemBuilder: _buildListItem,
                itemCount: _filteredList != null ? _filteredList.length : 0,
              ),
            );
          },
        ),
      ),
    );
  }
}
