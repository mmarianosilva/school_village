import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';

class Splash extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  goToNextPage(BuildContext context) async {
    final FirebaseUser currentUser = await UserHelper.getUser();
    if(currentUser != null) {
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
    startTimeout(context);
    return new Material(
      color: Theme.of(context).primaryColorLight,
      child: new Center(
        child: new Container(
          padding: const EdgeInsets.all(40.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Image.asset('assets/images/splash_text.png'),
              new Image.asset('assets/images/logo.png', width: 44.0)
            ],
          ),
        )
      ),
    );
  }
}