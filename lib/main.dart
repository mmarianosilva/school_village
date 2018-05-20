import 'package:flutter/material.dart';
import 'widgets/splash/splash.dart';
import 'widgets/home/home.dart';
import 'widgets/login/login.dart';
import 'widgets/schoollist/school_list.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

FirebaseAnalytics analytics = new FirebaseAnalytics();

void main() => runApp(new MaterialApp(
    home: Splash(),
    theme: new ThemeData(
      primaryColor: Colors.grey.shade900,
      accentColor: Colors.blue,
      brightness: Brightness.light,
      primaryColorDark: Colors.white10,
      primaryColorLight: Colors.white
    ),
    routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new Login()
    },
    navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: analytics),
    ],
));
