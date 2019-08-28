import 'package:cloud_firestore/cloud_firestore.dart';

class TalkAroundUser {
  final String id;
  final String name;
  final String group;

  TalkAroundUser(this.id, this.name, this.group);

  factory TalkAroundUser.fromMapAndGroup(DocumentSnapshot firebaseModel, String group) {
    return TalkAroundUser(firebaseModel.documentID, "${firebaseModel["firstName"]} ${firebaseModel["lastName"]}", group);
  }
}