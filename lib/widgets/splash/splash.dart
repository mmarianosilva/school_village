import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/util/file_helper.dart';
import '../../util/user_helper.dart';
import '../../util/analytics_helper.dart';

class Splash extends StatelessWidget {

  goToNextPage(BuildContext context) async {
    FirebaseUser currentUser;
    try {
      currentUser = await UserHelper.getUser();
    } catch(err) {
      print("Bad Password");
    }
    if(currentUser != null) {
      FileHelper.downloadRequiredDocuments();
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/home', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', (Route<dynamic> route) => false);
    }
  }

  startTimeout(BuildContext context) async {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, () =>  goToNextPage(context));
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
        )
      ),
    );
  }
}