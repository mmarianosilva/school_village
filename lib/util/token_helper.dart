import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'user_helper.dart';
import 'dart:io';
import 'package:device_info/device_info.dart';

class TokenHelper {
  static saveToken() async {
    print("Saving token");
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    final String token = await _firebaseMessaging.getToken();
    print("Fcm token is $token");
    User user = await UserHelper.getUser();
    String userPath = "/users/${user.uid}";
    print('User path /users/${user.uid}');
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot['devices'] != null &&
        userSnapshot['devices'].keys.contains(token)) {
      print("Not adding Token to user");
      (await SharedPreferences.getInstance()).setString("fcmToken", token);
      return;
    }
    addToken(token, user.uid);
  }

  static deleteToken(token, userId) async {
    print("token = $token");
    print("Deleting token");
    String userPath = "/users/$userId";
    DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);

    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic> devices = Map<String, dynamic>.from(userSnapshot['devices']);

    print(devices);

    if (devices != null && devices.containsKey(token)) {
    
      devices[token] = FieldValue.delete();

      await FirebaseFirestore.instance
          .doc("/users/$userId")
          .set(<String, dynamic>{'devices': devices}, SetOptions(merge: true));
      print(devices);
      print("Deleted token");
    }
  }

  static addToken(token, userId) async {
    print("Adding token");
    String deviceInfo = await getDeviceInfo();
    Map<String, String> device = {token: deviceInfo};

    await FirebaseFirestore.instance
        .doc("/users/$userId")
        .set(<String, dynamic>{'devices': device}, SetOptions(merge: true));
    (await SharedPreferences.getInstance()).setString("fcmToken", token);
  }

  static getDeviceInfo() async {
    String deviceInfo = '';
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        deviceInfo = 'Android ';
        Map<String, dynamic> deviceData =
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceInfo =
            '${deviceInfo} ${deviceData["brand"]} ${deviceData["device"]} ${deviceData["model"]}';
        print(deviceData);
      } else if (Platform.isIOS) {
        deviceInfo = 'iOS ';
        Map<String, dynamic> deviceData =
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceInfo =
            '${deviceInfo} ${deviceData["localizedModel"]} ${deviceData["utsname.machine"]}';
        print(deviceData);
      }
    } on PlatformException {}
    return deviceInfo;
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'brand': build.brand,
      'device': build.device,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
