import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:school_village/util/common_extensions.dart';

@immutable
class VendorCategory {
  const VendorCategory({this.id, this.name, this.icon});

  VendorCategory.fromMap({Map<String, dynamic> data})
      : this(
          id: data['id'] as String,
          name: (data['name'] as String).capitalize,
          icon: data['icon'] as String,
        );

  VendorCategory.fromDocument({DocumentSnapshot document})
      : this(
          id: document.id,
          name: (document['name'] as String).capitalize,
          icon: document['icon'] as String,
        );

  final String id;
  final String name;
  final String icon;
}
