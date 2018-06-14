import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:school_village/model/school_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class UserHelper {

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static final Future<SharedPreferences> _prefsFuture = SharedPreferences.getInstance();
  static SharedPreferences _prefs;

  static signIn({email: String, password: String}) async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("email", email.trim().toLowerCase());
    _prefs.setString("password", password);
    return _auth.signInWithEmailAndPassword(email: email.trim().toLowerCase(), password: password);
  }

  static getUser() async {
    FirebaseUser user = await _auth.currentUser();
    if(user == null) {
      if(_prefs == null) {
        _prefs = await _prefsFuture;
      }
      String email = _prefs.getString("email");
      String password = _prefs.getString("password");
      if(email == null || password == null || email.isEmpty || password.isEmpty) {
        return null;
      }
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
    return user;
  }

  static logout() async {
    _auth.signOut();
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("email", null);
    _prefs.setString("password", null);
    return;
  }

  static getSchools() async {
    final FirebaseUser currentUser = await getUser();
    if(currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = Firestore.instance.document(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();
    subscribeToAllTopics(userSnapshot);
    List<dynamic> schools = [];
    Iterable<dynamic> keys = userSnapshot['associatedSchools'].keys;
    setIsOwner(userSnapshot['owner'] ? true : false);
    print("Schools");
    for(int i = 0; i < keys.length; i++) {
      schools.add({
        "ref" : "schools/${keys.elementAt(i).toString().trim()}",
        "role" : userSnapshot['associatedSchools'][keys.elementAt(i)]["role"]
      });
    }
    print(schools);
    print("UID:");
    print(currentUser.uid);
    return schools;
  }

  static getSchoolAllGroups() async {
    final String selectedSchool = await getSelectedSchoolID();
    print(selectedSchool);
    DocumentReference schoolRef = Firestore.instance.document(selectedSchool);
    DocumentSnapshot schoolSnapshot = await schoolRef.get();
    List<dynamic> groups = [];
    Iterable<dynamic> keys = schoolSnapshot['groups'].keys;
    print("Groups");
    for(int i = 0; i < keys.length; i++) {
      groups.add({
        "name" : keys.elementAt(i).toString().trim(),
      });
    }
    print(groups);
    return groups;
  }

  static getSelectedSchoolID() async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_id");
  }

  static getSelectedSchoolRole() async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_role");
  }

  static setIsOwner(isOwner) async{
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setBool("is_owner", isOwner);
  }

  static getIsOwner() async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getBool("is_owner") == null ? false : _prefs.getBool("is_owner");
  }

  static setSelectedSchool({schoolId: String, schoolName: String, schoolRole: String}) async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("school_id", schoolId);
    _prefs.setString("school_name", schoolName);
    _prefs.setString("school_role", schoolRole);
  }

  static getSchoolName() async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_name");
  }

  static updateTopicSubscription() async {
    print("Subscribing all");
    final FirebaseUser currentUser = await getUser();
    if(currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = Firestore.instance.document(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();
    subscribeToAllTopics(userSnapshot);
  }

  static subscribeToAllTopics(user) async {
    print("Subscribing to topics");
    print(user["associatedSchools"]);
    var schools = user["associatedSchools"].keys;
    bool owner = false;
    if(user["owner"] != null) {
      owner = user["owner"];
    }
    for(int i = 0; i<schools.length; i++) {
      subscribeToSchoolAlerts(schools.elementAt(i), owner);
      var groups = user["associatedSchools"][schools.elementAt(i)].containsKey("groups") ?  user["associatedSchools"][schools.elementAt(i)]["groups"].keys : [];
      print("subscribing to groups $groups");
      for(int j =0; j<groups.length; j ++) {
        print("${schools.elementAt(i)}-grp-${groups.elementAt(j)}");
        _firebaseMessaging.subscribeToTopic(
            "${schools.elementAt(i)}-grp-${groups.elementAt(j)}");
      }
    }
  }

  static subscribeToSchoolAlerts(schoolId, isOwner) {
    print("Subscribung to alerts");
    var id = schoolId;
    _firebaseMessaging.subscribeToTopic(
        "$id-medical");
    _firebaseMessaging.subscribeToTopic(
        "$id-fight");
    _firebaseMessaging.subscribeToTopic(
        "$id-armed");
    _firebaseMessaging.subscribeToTopic(
        "$id-fire");
    _firebaseMessaging.subscribeToTopic(
        "$id-intruder");
    _firebaseMessaging.subscribeToTopic(
        "$id-other");
    if(isOwner) {
      _firebaseMessaging.subscribeToTopic(
          "$id-test");
    }
  }

  static subscribeToSchoolTopics(schoolId, isOwner) {
    var id = schoolId.split(
        "/")[1];
    _firebaseMessaging.subscribeToTopic(
        "$id-medical");
    _firebaseMessaging.subscribeToTopic(
        "$id-fight");
    _firebaseMessaging.subscribeToTopic(
        "$id-armed");
    _firebaseMessaging.subscribeToTopic(
        "$id-fire");
    _firebaseMessaging.subscribeToTopic(
        "$id-intruder");
    _firebaseMessaging.subscribeToTopic(
        "$id-other");
    if(isOwner) {
      _firebaseMessaging.subscribeToTopic(
          "$id-test");
    }
  }
}