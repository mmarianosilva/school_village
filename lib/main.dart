import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:sentry/sentry.dart';
import 'package:school_village/util/token_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/splash/splash.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/widgets/login/login.dart';
import 'package:school_village/util/analytics_helper.dart';
import 'package:school_village/util/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/localizations/localization.dart';

final SentryClient _sentry = new SentryClient(dsn: Constants.sentry_dsn);

_configureFirestoreOfflinePersistence() {
  Firestore.instance.settings(persistenceEnabled: false);
}

final RouteObserver<PageRoute> homePageRouteObserver = RouteObserver<PageRoute>();
final model = MainModel();

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PdftronFlutter.initialize(Constants.pdftronLicenseKey);
  _configureFirestoreOfflinePersistence();
  ErrorWidget.builder = (FlutterErrorDetails error) {
    if (FirebaseAuth.instance.currentUser() != null) {
      return Builder(
        builder: (context) => Scaffold(
          appBar: null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              children: <Widget>[
                Text(LocalizationHelper.of(context).localized(
                    'An unexpected error has occurred. Please login again to resolve the issue.')),
                Text(LocalizationHelper.of(context).localized('We apologize for the inconvenience.')),
                FlatButton(
                  color: Colors.blueAccent,
                  child: Text(LocalizationHelper.of(context).localized('Logout').toUpperCase(), style: TextStyle(color: Colors.white),),
                  onPressed: () async {
                    final String token = (await SharedPreferences.getInstance()).getString("fcmToken");
                    final FirebaseUser user = (await UserHelper.getUser());
                    await TokenHelper.deleteToken(token, user.uid);
                    await UserHelper.logout(token);
                    model.setUser(null);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', (Route<dynamic> route) => false);
                  },
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return ErrorWidget(error.exception);
    }
  };
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
        model: model,
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
            homePageRouteObserver
          ],
          localizationsDelegates: [LocalizationDelegate()],
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
