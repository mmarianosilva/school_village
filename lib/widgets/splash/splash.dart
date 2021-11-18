import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:school_village/util/file_helper.dart';
import 'package:school_village/util/version.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/user_helper.dart';
import '../../util/analytics_helper.dart';

class Splash extends StatelessWidget {
  goToNextPage(BuildContext context) async {
    User currentUser;
    try {
      currentUser = await UserHelper.getUser();
    } catch (err) {
      print("Bad Password");
      await FirebaseAuth.instance.signOut();
    }
    final versionClearance = await versionCheck(context);
    if (currentUser != null && versionClearance) {
      String userPath = "/users/${currentUser.uid}";
      print(currentUser);
      DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
      print("User data is ${userSnapshot.data()}");
      if (userSnapshot != null &&
          userSnapshot.data() != null &&
          !(userSnapshot.data()["associatedSchools"] is Map<String, dynamic> &&(userSnapshot.data()["associatedSchools"] as Map<String, dynamic>)
              .isEmpty && !userSnapshot.data()['vendor'])&&
          versionClearance) {
        FileHelper.downloadRequiredDocuments();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        return;
      } else {
        await FirebaseAuth.instance.signOut();
      }
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  String APP_STORE_URL =
      'https://apps.apple.com/us/app/marinavillage/id1535375829';
  String PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.oandmtech.marinavillage';

  Future<bool> versionCheck(context) async {
    final appInfo =
        await FirebaseFirestore.instance.collection("app_info").get();
    if(appInfo.docs.isEmpty){
      return true;
    }
    final appData = appInfo.docs.first;
    Version versionInfo =
        appData != null ? Version.fromMap(appData.data()) : null;
    if (versionInfo == null) {
      return true;
    } else {
      //Get Current installed version of app
      final PackageInfo info = await PackageInfo.fromPlatform();
      double currentVersion = double.parse(
          info.version.trim().replaceAll("-dev", "").replaceAll(".", ""));
      print("Initial version is ${info.version} so $currentVersion");

      if (!Platform.isIOS) {
        print("Blacklisted versions are ${versionInfo.blacklisted_android}");
        for (var element in versionInfo.blacklisted_android) {
          String ver = element.replaceAll("-dev", "").replaceAll(".", "");
          if (currentVersion <= double.parse(ver)) {
            await _showVersionDialog(context, versionInfo.update_message,
                versionInfo.update_changelog);
            return false;
          }
        }
        return true;
      } else {
        print("Blacklisted versions are ${versionInfo.blacklisted_ios}");
        for (var element in versionInfo.blacklisted_ios) {
          String ver = element.replaceAll("-dev", "").replaceAll(".", "");
          if (currentVersion <= double.parse(ver)) {
            await _showVersionDialog(context, versionInfo.update_message,
                versionInfo.update_changelog);
            return false;
          }
        }
        return true;
      }
    }
  }

  _showVersionDialog(context, title, message) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String btnLabel = "Update Now";
        String btnLabelCancel = "Exit App";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(APP_STORE_URL),
                  ),
                  FlatButton(
                      child: Text(btnLabelCancel),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        exit(0);
                      }),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(PLAY_STORE_URL),
                  ),
                  FlatButton(
                    child: Text(btnLabelCancel),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      SystemNavigator.pop();
                    },
                  ),
                ],
              );
      },
    );
  }

//
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  startTimeout(BuildContext context) async {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, () => goToNextPage(context));
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logAppOpen();
    startTimeout(context);
    return Material(
      color: Theme.of(context).primaryColorLight,
      child: Center(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: Image.asset('assets/images/splash_text.png'),
      )),
    );
  }
}
