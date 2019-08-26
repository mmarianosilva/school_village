import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';

class TalkAroundChannel {
  final String id;
  final String name;
  final bool direct;
  final List<TalkAroundUser> members;

  TalkAroundChannel(this.id, this.name, this.direct, this.members);

  factory TalkAroundChannel.fromMap(DocumentSnapshot firebaseModel) {
    return TalkAroundChannel(
        firebaseModel.documentID,
        firebaseModel.data["name"],
        firebaseModel.data["direct"],
        firebaseModel.data["members"].toList());
  }
}