import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:school_village/util/help_with_migration.dart';
import 'package:school_village/util/permission_matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'analytics_helper.dart';
import '../model/region_data.dart';

class UserHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();
  static SharedPreferences _prefs;
  static final Location _location = Location();

  static Map<String, String> positiveIncidents;
  static Map<String, String> negativeIncidents;

  static Future<UserCredential> signIn(
      {email: String, password: String}) async {
    if (_prefs == null) {
      _prefs = await _prefsFuture;
    }
    _prefs.setString("email", email.trim().toLowerCase());
    _prefs.setString("password", password);
    return _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(), password: password);
  }

  static Future<User> getUser() async {
    User user = await _auth.currentUser;
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _auth.currentUser;
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

  static Future<RegionData> getRegionData() async {
    final User currentUser = await getUser();
    if (currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();
    List<String> harbors = ["All"];
    List<QueryDocumentSnapshot> harborList = [];
    List<QueryDocumentSnapshot> regionList = [];
    List<DocumentSnapshot> marinasList = [];
    List<String> regions = ["All"];
    final result =
        (await FirebaseFirestore.instance.collection("districts").get()).docs;
    if (result.isNotEmpty) {
      result.forEach((element) {
        String name = element['name'];
        if (element.data().containsKey('deleted')) {
          bool deleted = element['deleted'];
          if (!deleted && !harbors.contains(name)) {
            harbors.add(name);
            harborList.add(element);
            //print("Harbor: $name");
          }
        } else {
          if (!harbors.contains(name)) {
            harbors.add(name);
            harborList.add(element);
            //print("Harbor: $name");
          }
        }
      });
    }
    final regionsResult =
        (await FirebaseFirestore.instance.collection("regions").get()).docs;
    if (regionsResult.isNotEmpty) {
      regionsResult.forEach((element) {
        String name = element['name'];
        if (element.data().containsKey('deleted')) {
          bool deleted = element['deleted'];
          if (!deleted && !regions.contains(name)) {
            regions.add(name);
            regionList.add(element);
            //print("Region: $name");
          }
        } else {
          if (!regions.contains(name)) {
            regions.add(name);
            regionList.add(element);
            //print("Region: $name");
          }
        }
      });
    }
    if ((userSnapshot['associatedSchools'] == null) ? true : false) {
      //Vendor Owner cases
      final result = await FirebaseFirestore.instance
          .collection("vendors")
          .where("owners", arrayContains: userRef)
          .get();
      if (result.docs.isNotEmpty) {
        List<QueryDocumentSnapshot> schoolsInDistrict;
        final vendorDocument = result.docs.first;
        final districts =
            (vendorDocument["districts"] as List).cast<DocumentReference>();
        districts.forEach((district) async {
          schoolsInDistrict = (await FirebaseFirestore.instance
                  .collection("schools")
                  .where("district", isEqualTo: district)
                  .get())
              .docs;
          schoolsInDistrict.forEach((element) {
            element.reference.get().then((value) {
              marinasList.add(value);
            });
          });
        });
      }
    } else {
      //Other cases
      final userData = userSnapshot;
      Iterable<dynamic> associatedSchools = userData['associatedSchools'].keys;
      setIsOwner((userSnapshot.data().toString().contains('owner') &&
              userSnapshot['owner'] != null)
          ? true
          : false);
      await associatedSchools.forEach((schoolId) {
        String schoolPath = "/schools/${schoolId}";
        DocumentReference schoolRef =
            FirebaseFirestore.instance.doc(schoolPath);
        schoolRef.snapshots().listen((school) {
          final data = school;
          if (data == null) {
            return;
          }
          marinasList.add(school);
        });
      });
    }
    return RegionData(
        regions: regions,
        harbors: harbors,
        harborObjects: harborList,
        regionObjects: regionList,
        marinaObjects: marinasList,
        userSnapshot: userSnapshot);
  }

  static getSchools() async {
    final User currentUser = await getUser();
    if (currentUser == null) {
      return null;
    }
    String userPath = "/users/${currentUser.uid}";
    print(currentUser);
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();

    List<dynamic> schools = [];
    if ((userSnapshot['associatedSchools'] == null) ? true : false) {
      final result = await FirebaseFirestore.instance
          .collection("vendors")
          .where("owners", arrayContains: userRef)
          .get();
      if (result.docs.isNotEmpty) {
        final vendorDocument = result.docs.first;
        final districts =
            (vendorDocument["districts"] as List).cast<DocumentReference>();
        for (int i = 0; i < districts.length; i++) {
          final schoolsInDistrict = (await FirebaseFirestore.instance
                  .collection("schools")
                  .where("district", isEqualTo: districts[i])
                  .get())
              .docs;
          schools.addAll(schoolsInDistrict.map((item) => <String, dynamic>{
                "ref": item.reference.path,
                "role": 'vendor',
              }));
        }
      }
      return schools;
    }
    Iterable<dynamic> keys = userSnapshot['associatedSchools'].keys;
    setIsOwner((userSnapshot.data().toString().contains('owner') &&
            userSnapshot['owner'] != null)
        ? true
        : false);
    print("Schools list ${keys.length}");
    for (int i = 0; i < keys.length; i++) {
      schools.add({
        "ref": "schools/${keys.elementAt(i).toString().trim()}",
        "role": userSnapshot['associatedSchools'][keys.elementAt(i)]["role"]
      });
    }
    return schools;
  }

  static getFilteredSchools(
      String searchText,
      String region,
      String harbor,
      QueryDocumentSnapshot harborObj,
      QueryDocumentSnapshot regionObj,
      List<DocumentSnapshot> marinas,
      DocumentSnapshot mSnapshot) async {
    if (marinas.isEmpty) {
      return [];
    }
    List<dynamic> allMarinas = [];
    final regex = (new RegExp(searchText, caseSensitive: false, unicode: true));
    await marinas.forEach((school) {
      final schoolData = school.data();
      final data = schoolData as Map<String, dynamic>;

      if (data == null) {
        return;
      }

      final schoolName = data['name'] ?? null;
      if (schoolName == null) {
        return;
      }
      final harborRef = data['district']?? null;
      final regionRef = data['region']?? null;

      if ((region == 'All') &&
          (harbor == 'All') &&
          schoolName.contains(regex)) {
        allMarinas.add(
          <String, dynamic>{
            "schoolId": "schools/${school.reference.id}",
            "role": mSnapshot['associatedSchools'][school.reference.id]["role"],
            "name": schoolName,
          },
        );
        //allMarinas[schoolId] = school;
      } else if ((region != 'All') && (harbor != 'All')) {
        if (harborRef == harborObj.reference &&
            regionRef == regionObj.reference &&
            schoolName.contains(regex)) {
          allMarinas.add(
            <String, dynamic>{
              "schoolId": "schools/${school.reference.id}",
              "role": mSnapshot['associatedSchools'][school.reference.id]
                  ["role"],
              "name": schoolName,
            },
          );
        }
      } else if ((region != 'All') && (harbor == 'All')) {
        if (regionRef == regionObj.reference && schoolName.contains(regex)) {
          allMarinas.add(
            <String, dynamic>{
              "schoolId": "schools/${school.reference.id}",
              "role": mSnapshot['associatedSchools'][school.reference.id]
                  ["role"],
              "name": schoolName,
            },
          );
        }
      } else if ((region == 'All') && (harbor != 'All')) {
        if (harborRef == harborObj.reference && schoolName.contains(regex)) {
          allMarinas.add(
            <String, dynamic>{
              "schoolId": "schools/${school.reference.id}",
              "role": mSnapshot['associatedSchools'][school.reference.id]
                  ["role"],
              "name": schoolName,
            },
          );
        }
      }
    });

    return allMarinas;
  }

  static loadIncidentTypes() async {
    if (positiveIncidents == null && negativeIncidents == null) {
      String selectedSchool = await getSelectedSchoolID();

      DocumentReference schoolRef =
          FirebaseFirestore.instance.doc(selectedSchool);
      DocumentSnapshot schoolSnapshot = await schoolRef.get();

      var items = schoolSnapshot["incidents"];

      negativeIncidents = (Map<String, String>.from(items["negative"]));
      positiveIncidents = (Map<String, String>.from(items["positive"]));
    }
  }

  static getSchoolAllGroups() async {
    final String selectedSchool = await getSelectedSchoolID();
    print(selectedSchool);
    DocumentReference schoolRef =
        FirebaseFirestore.instance.doc(selectedSchool);
    DocumentSnapshot schoolSnapshot = await schoolRef.get();
    List<dynamic> groups = [];
    if (schoolSnapshot['groups'] != null) {
      Iterable<dynamic> keys = schoolSnapshot['groups'].keys;
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
    final User currentUser = await getUser();
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

  static String getDisplayName([DocumentSnapshot<Map<String, dynamic>> snapshot]) {

    return "${snapshot.data()["firstName"]} ${snapshot.data()["lastName"]} ${snapshot.data()["room"] != null && snapshot.data()["room"].isNotEmpty ? ' (${snapshot.data()["room"]})' : ''}";
  }

  static String getRoomNumber([DocumentSnapshot snapshot]) {
    return snapshot["room"];
  }
}
