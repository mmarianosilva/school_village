import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/util/user_helper.dart';

class TalkAroundUser {
  final DocumentReference id;
  final String name;
  final String group;

  TalkAroundUser(this.id, this.name, this.group);

  factory TalkAroundUser.fromMapAndGroup(DocumentSnapshot firebaseModel, String group) {
    return TalkAroundUser(firebaseModel.reference, UserHelper.getDisplayName(firebaseModel), mapGroup(group));
  }

  static String mapGroup(String firebaseValue) {
    if (firebaseValue.contains("school_")) {
      return firebaseValue.substring("school_".length);
    }
    return firebaseValue;
  }
}