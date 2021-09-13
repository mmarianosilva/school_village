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
    final data = firebaseModel.data() as Map<String, dynamic>;

    return TalkAroundChannel(
        firebaseModel.id,
        data["name"],
        ((data['direct'] ?? null) !=null)? data['direct'] : false,
        ((data['timestamp'] ?? null) !=null) ? data["timestamp"] : Timestamp.now(),
        members,
        admin: ((data['admin'] ?? null) !=null)
            ? TalkAroundUser(
                FirebaseFirestore.instance
                    .doc("users/${firebaseModel["admin"]}"),
                firebaseModel["adminName"],
                firebaseModel["adminRole"],
              )
            : null,
        isClass: ((data['class'] ?? null) !=null) ? data['class'] : false);
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
