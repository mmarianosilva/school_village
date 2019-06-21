import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/splash/splash.dart';
import 'widgets/home/home.dart';
import 'widgets/login/login.dart';
import 'package:firebase_analytics/observer.dart';
import 'util/analytics_helper.dart';
import 'util/constants.dart';
import 'package:sentry/sentry.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'model/main_model.dart';

final SentryClient _sentry = new SentryClient(dsn: Constants.sentry_dsn);

_configureFirestoreOfflinePersistence() {
  Firestore.instance.settings(persistenceEnabled: false);
}

Future<Null> main() async {
  _configureFirestoreOfflinePersistence();
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZoned<Future<Null>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(new ScopedModel<MainModel>(
        model: MainModel(),
        child: new MaterialApp(
          home: Splash(),
          theme: new ThemeData(
              primaryColor: Colors.grey.shade900,
              accentColor: Colors.blue,
              brightness: Brightness.light,
              primaryColorDark: Colors.white10,
              primaryColorLight: Colors.white),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => new Home(),
            '/login': (BuildContext context) => new Login(),
          },
          navigatorObservers: [
            new FirebaseAnalyticsObserver(
                analytics: AnalyticsHelper.getAnalytics()),
          ],
        ),
      ));
    });
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }
  print('Reporting to Sentry.io...');
  final SentryResponse response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}
