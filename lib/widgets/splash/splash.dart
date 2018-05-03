import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatelessWidget {

  startTimeout(BuildContext context) async {
    var duration = const Duration(seconds: 2);
    return new Timer(duration, () =>  Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false));
  }

  @override
  Widget build(BuildContext context) {
    startTimeout(context);
    return new Material(
      color: Theme.of(context).primaryColor,
      child: new Center(
        child: new Text("School Village",
            textDirection: TextDirection.ltr,
            style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36.0
            )
        ),
      ),
    );
  }
}