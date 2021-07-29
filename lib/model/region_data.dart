import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class RegionData {
  final List<String> regions;
  final List<String> harbors;
  final List<QueryDocumentSnapshot> harborObjects;

  RegionData({
    this.regions,
    this.harbors,
    this.harborObjects,
  });
}
