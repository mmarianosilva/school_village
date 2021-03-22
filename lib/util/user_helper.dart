import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'analytics_helper.dart';

class UserHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();
  static SharedPreferences _prefs;
  static final Location _location = Location();

  static Map<String, String> positiveIncidents;
  static Map<String, String> negativeIncidents;

  static Future<AuthResult> signIn({email: String, password: String}) async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("email", email.trim().toLowerCase());
    _prefs.setString("password", password);
    return _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
  }

  static Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _auth.currentUser();
    if (user == null) {
      if (_prefs == null) {
        _prefs = await _prefsFuture;
      }
      String email = _prefs.getString("email");
      String password = _prefs.getString("password");
      if (email == null ||
          password == null ||
          email.isEmpty ||
          password.isEmpty) {
        return null;
      }
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _auth.currentUser();
    }
    AnalyticsHelper.setUserId(user.uid);
    return user;
  }

  static logout(token) async {
    _auth.signOut();
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    await _prefs.clear();
    setSelectedSchool(schoolRole: null, schoolName: null, schoolId: null);
    return;
  }

  static getSchools() async {
    final FirebaseUser currentUser = await getUser();
    if (currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();

    List<dynamic> schools = [];
    Iterable<dynamic> keys = userSnapshot.data()['associatedSchools'].keys;
    setIsOwner(userSnapshot.data()['owner'] != null && userSnapshot.data()['owner'] == true
        ? true
        : false);
    for (int i = 0; i < keys.length; i++) {
      schools.add({
        "ref": "schools/${keys.elementAt(i).toString().trim()}",
        "role": userSnapshot.data()['associatedSchools'][keys.elementAt(i)]["role"]
      });
    }
    return schools;
  }

  static loadIncidentTypes() async {
    if (positiveIncidents == null && negativeIncidents == null) {
      String selectedSchool = await getSelectedSchoolID();

      DocumentReference schoolRef = FirebaseFirestore.instance.doc(selectedSchool);
      DocumentSnapshot schoolSnapshot = await schoolRef.get();

      var items = schoolSnapshot.data()["incidents"];

      negativeIncidents = (Map<String, String>.from(items["negative"]));
      positiveIncidents =  (Map<String, String>.from(items["positive"]));
    }
  }

  static getSchoolAllGroups() async {
    final String selectedSchool = await getSelectedSchoolID();
    print(selectedSchool);
    DocumentReference schoolRef = FirebaseFirestore.instance.doc(selectedSchool);
    DocumentSnapshot schoolSnapshot = await schoolRef.get();
    List<dynamic> groups = [];
    if (schoolSnapshot.data()['groups'] != null) {
      Iterable<dynamic> keys = schoolSnapshot.data()['groups'].keys;
      for (int i = 0; i < keys.length; i++) {
        groups.add({
          "name": keys.elementAt(i).toString().trim(),
        });
      }
    }
    return groups;
  }

  static getSelectedSchoolID() async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_id");
  }

  static getSelectedSchoolRole() async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_role");
  }

  static setIsOwner(isOwner) async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setBool("is_owner", isOwner);
  }

  static getIsOwner() async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getBool("is_owner") == null
        ? false
        : _prefs.getBool("is_owner");
  }

  static setAnonymousRole(role) async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("anonymous_role", role);
  }

  static getAnonymousRole() async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("anonymous_role") == null
        ? ''
        : _prefs.getString("anonymous_role");
  }

  static setSelectedSchool(
      {schoolId: String, schoolName: String, schoolRole: String}) async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("school_id", schoolId);
    _prefs.setString("school_name", schoolName);
    _prefs.setString("school_role", schoolRole);
    AnalyticsHelper.setSchoolId(schoolId, schoolName, schoolRole);
  }

  static getSchoolName() async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_name");
  }

  static updateTopicSubscription() async {
    final FirebaseUser currentUser = await getUser();
    if (currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();
    subscribeToAllTopics(userSnapshot);
  }

  static subscribeToAllTopics(user) async {
    var schools = user["associatedSchools"].keys;
    bool owner = false;
    if (user["owner"] != null) {
      owner = user["owner"];
    }
    for (int i = 0; i < schools.length; i++) {
      subscribeToSchoolAlerts(schools.elementAt(i), owner);
      var groups =
          user["associatedSchools"][schools.elementAt(i)].containsKey("groups")
              ? user["associatedSchools"][schools.elementAt(i)]["groups"].keys
              : [];
      for (int j = 0; j < groups.length; j++) {
        print("${schools.elementAt(i)}-grp-${groups.elementAt(j)}");
        _firebaseMessaging.subscribeToTopic(
            "${schools.elementAt(i)}-grp-${groups.elementAt(j)}");
      }
    }
  }

  static subscribeToSchoolAlerts(schoolId, isOwner) {
    print("Subscribung to alerts");
    var id = schoolId;
    _firebaseMessaging.subscribeToTopic("$id-medical");
    _firebaseMessaging.subscribeToTopic("$id-fight");
    _firebaseMessaging.subscribeToTopic("$id-armed");
    _firebaseMessaging.subscribeToTopic("$id-fire");
    _firebaseMessaging.subscribeToTopic("$id-intruder");
    _firebaseMessaging.subscribeToTopic("$id-other");
    if (isOwner) {
      _firebaseMessaging.subscribeToTopic("$id-test");
    }
  }

  static subscribeToSchoolTopics(schoolId, isOwner) {
    var id = schoolId.split("/")[1];
    _firebaseMessaging.subscribeToTopic("$id-medical");
    _firebaseMessaging.subscribeToTopic("$id-fight");
    _firebaseMessaging.subscribeToTopic("$id-armed");
    _firebaseMessaging.subscribeToTopic("$id-fire");
    _firebaseMessaging.subscribeToTopic("$id-intruder");
    _firebaseMessaging.subscribeToTopic("$id-other");
    if (isOwner) {
      _firebaseMessaging.subscribeToTopic("$id-test");
    }
  }

  static Future<Map<String, double>> getLocation() async {
    final locationData = await _location.getLocation();
    Map<String, double> location = new Map();
    try {
      location['accuracy'] = locationData.accuracy;
      location['altitude'] = locationData.altitude;
      location['latitude'] = locationData.latitude;
      location['longitude'] = locationData.longitude;
    } catch (e) {
      if (e is Error) {
        print(e.stackTrace);
      }
      location = null;
    }
    return location;
  }

  static String getDisplayName([DocumentSnapshot snapshot]) {
    return "${snapshot.data()["firstName"]} ${snapshot.data()["lastName"]} ${snapshot.data()["room"] != null && snapshot.data()["room"].isNotEmpty ? ' (${snapshot.data()["room"]})' : ''}";
  }

  static String getRoomNumber([DocumentSnapshot snapshot]) {
    return snapshot.data()["room"];
  }
}
