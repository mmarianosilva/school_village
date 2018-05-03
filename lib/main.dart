import 'package:flutter/material.dart';
import 'widgets/splash/splash.dart';
import 'widgets/home/home.dart';

void main() => runApp(new MaterialApp(
    home: Splash(),
    theme: new ThemeData(
      primaryColor: Colors.redAccent,
      accentColor: Colors.red,
      brightness: Brightness.dark,
      primaryColorDark: Colors.red.shade900
    ),
    routes: <String, WidgetBuilder> {
    '/home': (BuildContext context) => new Home(),
    }
));
