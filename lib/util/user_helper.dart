import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/model/school_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserHelper {

  static final FirebaseAuth _auth = FirebaseAuth.instance;
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
    List<dynamic> schools = userSnapshot['schools'];
    print("UID:");
    print(currentUser.uid);
    return schools;
  }

  static getSelectedSchoolID() async {
    if(_prefs == null) {
      _prefs = await _prefsFuture;
    }
    return _prefs.getString("school_id");
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
}