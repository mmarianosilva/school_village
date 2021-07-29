import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class RegionData {
  final List<String> regions;
  final List<String> harbors;
  final List<QueryDocumentSnapshot> harborObjects;
  final List<QueryDocumentSnapshot> regionObjects;

  RegionData({
    this.regions,
    this.harbors,
    this.harborObjects,
    this.regionObjects,
  });
}
