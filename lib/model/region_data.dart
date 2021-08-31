import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class RegionData {
  final List<String> regions;
  final List<String> harbors;
  final List<QueryDocumentSnapshot> harborObjects;
  final List<QueryDocumentSnapshot> regionObjects;
  final DocumentSnapshot userSnapshot;
  RegionData({
    this.regions,
    this.harbors,
    this.harborObjects,
    this.regionObjects,
    this.userSnapshot,
  });
}
