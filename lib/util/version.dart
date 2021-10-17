class Version {
  List<dynamic> blacklisted_ios;
  List<dynamic> blacklisted_android;
  String latest_ios;
  String latest_android;
  bool enabled;
  String update_changelog;
  String update_message;

  Version({
    this.blacklisted_ios,
    this.blacklisted_android,
    this.latest_ios,
    this.latest_android,
    this.enabled,
    this.update_changelog,
    this.update_message,
  });

  factory Version.fromJson(Map<String, dynamic> parsedJson) {
    return Version(
      blacklisted_ios: parsedJson['blacklisted_ios'] as List<double>,
      blacklisted_android: parsedJson['blacklisted_android']as List<double>,
      latest_ios: parsedJson['latest_ios'],
      latest_android: parsedJson['latest_android'],
      enabled: parsedJson['enabled'],
      update_changelog: parsedJson['update_changelog'],
      update_message: parsedJson['update_msg'],
    );
  }

  factory Version.fromMap(Map<String, dynamic> dataMap) {
    return Version(
      blacklisted_ios:dataMap["blacklisted_ios"],
      blacklisted_android:dataMap["blacklisted_android"],
      latest_ios:dataMap["latest_ios"],
      latest_android:dataMap["latest_android"],
      enabled:dataMap["enabled"],
      update_changelog:dataMap["update_changelog"],
      update_message:dataMap["update_msg"],
    );
  }
}
