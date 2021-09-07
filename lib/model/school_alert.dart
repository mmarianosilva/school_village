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

  SchoolAlert.fromMap(DocumentSnapshot firebaseModel) : this(
    firebaseModel.id,
    firebaseModel.reference.path,
    firebaseModel["title"],
    firebaseModel["body"],
    DateTime.fromMillisecondsSinceEpoch(firebaseModel["createdAt"]),
    firebaseModel["endedAt"] != null ? DateTime.fromMicrosecondsSinceEpoch(firebaseModel["endedAt"].microsecondsSinceEpoch) : null,
    firebaseModel["createdBy"],
    firebaseModel["createdById"],
    LocationData.fromMap(Map<String, double>.from(firebaseModel["location"])),
    firebaseModel["type"],
    firebaseModel["reportedByPhone"],
    firebaseModel["resolution"],
    resolved: firebaseModel["endedAt"] != null,
    resolvedBy: firebaseModel["resolvedBy"]);

  String get reportedByPhoneFormatted => reportedByPhone.length > 6 ? "${reportedByPhone.substring(0, 3)}-${reportedByPhone.substring(3, 6)}-${reportedByPhone.substring(6)}" : reportedByPhone;
}