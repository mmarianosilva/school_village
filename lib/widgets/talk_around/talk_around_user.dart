class TalkAroundUser {
  final String name;
  final String group;

  TalkAroundUser(this.name, this.group);

  factory TalkAroundUser.fromMapAndGroup(Map<String, dynamic> firebaseModel, String group) {
    return TalkAroundUser("${firebaseModel["firstName"]} ${firebaseModel["lastName"]}", group);
  }
}