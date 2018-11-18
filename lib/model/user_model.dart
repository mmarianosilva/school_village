import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../util/user_helper.dart';
import 'dart:async';

mixin UserModel on Model {

  DocumentSnapshot _user;
  String _token = '';

  Future<DocumentSnapshot> getUser() async {
    if(_user == null){
      FirebaseUser user = await UserHelper.getUser();
      print("User ID");
      print(user.uid);
      DocumentReference userRef = Firestore.instance.document('users/${user.uid}');
      userRef.get().then((user) {
        _user = user;
        notifyListeners();
      });
    }
    return _user;
  }

  getAlertGroups(schoolId) async {
    DocumentSnapshot user = await getUser();
    print(user);
    if(user != null && user.data['associatedSchools'].containsKey(schoolId) && user.data['associatedSchools'][schoolId].containsKey('alerts')) {
      return user.data['associatedSchools'][schoolId]['alerts'].keys.where((k) => user.data['associatedSchools'][schoolId]['alerts'][k] == true);
    } else {
      return [];
    }
  }

  refreshUserIfNull() async{
    if(_user == null){
      FirebaseUser user = await UserHelper.getUser();
      print("User ID");
      print(user.uid);
      DocumentReference userRef = Firestore.instance.document('users/${user.uid}');
      userRef.get().then((user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  void setUser(user) {
    _user = user;
    notifyListeners();
  }

  getToken() {
    return _token;
  }

  setToken(String token) {
    _token = token;
  }
}