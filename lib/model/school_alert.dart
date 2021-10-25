import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class SchoolAlert {
  final String id;
  final String firestorePath;
  final String title;
  final String body;
  final DateTime timestamp;
  final DateTime timestampEnded;
  final String createdBy;
  final String createdById;
  final LocationData location;
  final String type;
  final String reportedByPhone;
  final String resolution;
  final bool resolved;
  final String resolvedBy;

  SchoolAlert(this.id, this.firestorePath, this.title, this.body, this.timestamp, this.timestampEnded, this.createdBy, this.createdById, this.location, this.type, this.reportedByPhone, this.resolution, {this.resolved = true, this.resolvedBy});

  // SchoolAlert.fromMapOld(DocumentSnapshot firebaseModel) : this(
  //   firebaseModel.id,
  //   firebaseModel.reference.path,
  //   firebaseModel.data()["title"],
  //   firebaseModel.data()["body"],
  //   DateTime.fromMillisecondsSinceEpoch(firebaseModel.data()["createdAt"]),
  //   firebaseModel.data()["endedAt"] != null ? DateTime.fromMicrosecondsSinceEpoch(firebaseModel.data()["endedAt"].microsecondsSinceEpoch) : null,
  //   firebaseModel.data()["createdBy"],
  //   firebaseModel.data()["createdById"],
  //   LocationData.fromMap(Map<String, double>.from(firebaseModel.data()["location"])),
  //   firebaseModel.data()["type"],
  //   firebaseModel.data()["reportedByPhone"],
  //   firebaseModel.data()["resolution"],
  //   resolved: firebaseModel.data()["endedAt"] != null,
  //   resolvedBy: firebaseModel.data()["resolvedBy"]);
  SchoolAlert.fromMap(String id, String path, Map<String, dynamic> dataMap)
      : this(
      id,
      path,
      dataMap["title"],
      dataMap["body"],
      DateTime.fromMillisecondsSinceEpoch(dataMap["createdAt"]),
      (dataMap["endedAt"] ?? null) != null
          ? DateTime.fromMicrosecondsSinceEpoch(
          dataMap["endedAt"].microsecondsSinceEpoch)
          : null,
      dataMap["createdBy"],
      dataMap["createdById"],

      LocationData.fromMap(<String,double>{
        "accuracy":((dataMap["location"]??Map<String,dynamic>())['accuracy']).toDouble(),
        'altitude':(dataMap["location"]??Map<String,dynamic>())['altitude'],
        'latitude':(dataMap["location"]??Map<String,dynamic>())['latitude'],
        'longitude':(dataMap["location"]??Map<String,dynamic>())['longitude']
      }),
      dataMap["type"],
      dataMap["reportedByPhone"],
      dataMap["resolution"],
      resolved: (dataMap["endedAt"] ?? null) != null,
      resolvedBy: dataMap["resolvedBy"]);
  String get reportedByPhoneFormatted => reportedByPhone.length > 6 ? "${reportedByPhone.substring(0, 3)}-${reportedByPhone.substring(3, 6)}-${reportedByPhone.substring(6)}" : reportedByPhone;
}