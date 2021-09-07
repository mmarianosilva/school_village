import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/util/file_helper.dart';
import 'package:school_village/widgets/sign_up/sign_up_vendor.dart';
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
    if (currentUser != null) {
      String userPath = "/users/${currentUser.uid}";
      print(currentUser);
      DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot != null &&
          userSnapshot["associatedSchools"] is Map<String, dynamic> &&
          (userSnapshot["associatedSchools"] as Map<String, dynamic>)
              .isNotEmpty) {
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
