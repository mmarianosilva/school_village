import 'package:flutter/material.dart';

class Constants {
  static const version = "1.3.31";
  static const sentry_dsn_dev = "https://6399c960b61240739ce844fa6caaeaee@o164999.ingest.sentry.io/5263326";
  static const sentry_dsn_prod = "https://babc462ab7dd49809c5ef1af185346c0@o164999.ingest.sentry.io/1236103";

  static const oneDay = 1000 * 60 * 60 * 24;
  static const hotLineBlue = const Color(0xFF0B92B4);
  static const messagesHorizontalMargin = const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0);
  static const pdftronLicenseKey = '';
  static const lastAmberAlertTimestampKey = 'lastAmberAlertTimestamp';
  static const privacyPolicyUrl = 'https://villagesafety.net/privacy_policy-vs';
  static const termsOfServiceUrl = 'https://villagesafety.net/termsConditions';

  static final emailRegEx = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
  static final phoneRegEx = RegExp(r"^(?:[+0][1-9]{1,3})?[0-9]{9,10}$");
}