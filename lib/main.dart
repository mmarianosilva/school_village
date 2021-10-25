import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:sentry/sentry.dart';
import 'package:school_village/util/token_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/splash/splash.dart';
import 'package:school_village/widgets/home/home.dart';
import 'package:school_village/widgets/login/login.dart';
import 'package:school_village/util/analytics_helper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/localizations/localization.dart';

final RouteObserver<PageRoute> homePageRouteObserver =
RouteObserver<PageRoute>();

final model = MainModel();

Future<Null> internalMain(String sentryDsn) async {
  await Sentry.init(
        (options) {
      options.dsn = sentryDsn;
    },
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ErrorWidget.builder = (FlutterErrorDetails error) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Builder(
        builder: (context) => Scaffold(
          appBar: null,
          body: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              children: <Widget>[
                Text(LocalizationHelper.of(context).localized(
                    'An unexpected error has occurred. Please login again to resolve the issue.')),
                Text(LocalizationHelper.of(context)
                    .localized('We apologize for the inconvenience.')),
                FlatButton(
                  color: Colors.blueAccent,
                  child: Text(
                    LocalizationHelper.of(context)
                        .localized('Logout')
                        .toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final String token = (await SharedPreferences.getInstance())
                        .getString("fcmToken");
                    final  user = (await UserHelper.getUser());
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
  runZonedGuarded<Future<Null>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(ScopedModel<MainModel>(
        model: model,
        child: MaterialApp(
          home: Splash(),
          theme: ThemeData(
              primaryColor: Colors.grey.shade900,
              accentColor: Colors.blue,
              brightness: Brightness.light,
              primaryColorDark: Colors.white10,
              primaryColorLight: Colors.white),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => Home(),
            '/login': (BuildContext context) => Login(),
          },
          navigatorObservers: [
            FirebaseAnalyticsObserver(
                analytics: AnalyticsHelper.getAnalytics()),
            homePageRouteObserver
          ],
          localizationsDelegates: [LocalizationDelegate()],
        ),
      ));
    });
  }, (error, stackTrace) async {
    await Sentry.captureException(error, stackTrace: stackTrace);
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}


