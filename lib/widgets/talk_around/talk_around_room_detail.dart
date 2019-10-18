import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_item.dart';

class TalkAroundRoomDetail extends StatelessWidget {
  final TalkAroundChannel _channel;

  const TalkAroundRoomDetail(this._channel, {Key key}) : super(key: key);

  String _buildTitle() {
    if (!_channel.direct) {
      return "${_channel.name} Details";
    }
    if (_channel.members.length > 2) {
      return "Group Detail";
    }
    return "Direct Message: User Detail";
  }

  Widget _buildListItem(BuildContext context, int index) {
    final mappedMember = TalkAroundChannel(
      "",
      "",
      true,
      null,
      [_channel.members[index]]);
    return TalkAroundRoomItem(
      item: mappedMember,
      username: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(_buildTitle()),
        backgroundColor: Color.fromARGB(255, 134, 165, 177),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Color.fromARGB(255, 10, 104, 127),
        child: ListView.builder(
            itemBuilder: _buildListItem,
            itemCount: _channel.members.length),
      ),
    );
  }
}
