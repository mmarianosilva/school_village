import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class SchoolAlert {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String createdBy;
  final String createdById;
  final LocationData location;
  final String type;
  final String reportedByPhone;
  final bool resolved;

  SchoolAlert(this.id, this.title, this.body, this.timestamp, this.createdBy, this.createdById, this.location, this.type, this.reportedByPhone, {this.resolved = true});

  SchoolAlert.fromMap(DocumentSnapshot firebaseModel) : this(
    firebaseModel.documentID,
    firebaseModel["title"],
    firebaseModel["body"],
    DateTime.fromMillisecondsSinceEpoch(firebaseModel["createdAt"]),
    firebaseModel["createdBy"],
    firebaseModel["createdById"],
    LocationData.fromMap(Map<String, double>.from(firebaseModel["location"])),
    firebaseModel["type"],
    firebaseModel["reportedByPhone"]);
}