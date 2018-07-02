import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();

  static getAnalytics() {
    return analytics;
  }

  static setUserId(userId) {
    analytics.setUserId(userId).then((result) {
      print("User Set");
    });
  }

  static setSchoolId(schoolId, schoolName, role) {
    analytics.setUserProperty(name: 'school_id', value: schoolId).then((result) {
      print("User Property Set");
    });
    analytics.setUserProperty(name: 'school_name', value: schoolName).then((result) {
      print("User Property Set");
    });
    analytics.setUserProperty(name: 'school_role', value: role).then((result) {
      print("User Property Set");
    });
  }

  static logAppOpen() {
    analytics.logAppOpen().then((result) {
      print("Logged Event");
    });
  }

  static logLogin() {
    analytics.logLogin().then((result) {
      print("Logged Event");
    });
  }

  static logPdfOpen(schoolId, schoolName,  pdfName) {
    analytics.logEvent(
      name: 'pdf_open',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName,
        'name': pdfName,
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static logUrlOpen(schoolId, schoolName,  url) {
    analytics.logEvent(
      name: 'url_open',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName,
        'url': url,
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static logAlertSent(schoolId, schoolName,  alertType) {
    analytics.logEvent(
      name: 'alert_sent',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName,
        'alertType': alertType,
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static logAlertDetailsViewed(schoolId, schoolName) {
    analytics.logEvent(
      name: 'alert_details_viewed',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static logSecurityMessageDetailsViewed(schoolId, schoolName) {
    analytics.logEvent(
      name: 'security_message_details_viewed',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static securityMessageSent(schoolId, schoolName,  isAdmin) {
    analytics.logEvent(
      name: 'security_message_sent',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName,
        'is_admin': isAdmin,
      },
    ).then((result) {
      print("Logged Event");
    });
  }

  static logBroadcastSent(schoolId, schoolName,  groups) {
    analytics.logEvent(
      name: 'broadcast_sent',
      parameters: <String, dynamic>{
        'school_id': schoolId,
        'school_name': schoolName,
        'group': groups,
      },
    ).then((result) {
      print("Logged Event");
    });
  }
}