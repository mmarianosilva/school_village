import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';

class TalkAroundChannel {
  final String id;
  final String name;
  final bool direct;
  final Timestamp timestamp;
  final List<TalkAroundUser> members;
  final TalkAroundUser admin;
  final bool isClass;

  TalkAroundChannel(
    this.id,
    this.name,
    this.direct,
    this.timestamp,
    this.members, {
    this.admin,
    this.isClass = false,
  });

  factory TalkAroundChannel.fromMapAndUsers(
      DocumentSnapshot firebaseModel, List<TalkAroundUser> members) {
    return TalkAroundChannel(
        firebaseModel.id,
        firebaseModel.data()["name"],
        firebaseModel.data()["direct"] ?? false,
        firebaseModel.data()["timestamp"] ?? Timestamp.now(),
        members,
        admin: firebaseModel.data()["admin"] != null
            ? TalkAroundUser(
                FirebaseFirestore.instance
                    .doc("users/${firebaseModel.data()["admin"]}"),
                firebaseModel.data()["adminName"],
                firebaseModel.data()["adminRole"],
              )
            : null,
        isClass: firebaseModel.data()["class"] ?? false);
  }

  bool get showLocation => !direct && name.contains("Security");

  String groupConversationName(String username) {
    if (!direct || isClass) {
      return name;
    }
    List<String> names = members.map((item) => item.name).toList();
    names.removeWhere((name) => name == username);
    names.sort((name1, name2) => name1.compareTo(name2));
    String output = "";
    int i = 0;
    while (i < names.length - 1) {
      output += "${names[i]}, ";
      i++;
    }
    if (names.isNotEmpty) {
      output += names[names.length - 1];
    }
    return output;
  }
}
