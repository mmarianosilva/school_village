import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:school_village/util/common_extensions.dart';

@immutable
class VendorCategory {
  const VendorCategory({
    this.id,
    this.name,
    this.icon,
    this.deleted,
  });

  VendorCategory.fromMap({Map<String, dynamic> data})
      : this(
          id: data['id'] as String,
          name: (data['name'] as String).capitalize,
          icon: data['icon'] as String,
          deleted: (data['deleted'] as bool) ?? false,
        );

  VendorCategory.fromDocument({DocumentSnapshot<Map<String,dynamic>> document})
      : this(
          id: document.id,
          name: (document.data()['name'] as String).capitalize,
          icon: document.data()['icon'] as String,
          deleted: (((document.data()['deleted']??null))!=null) ?? false,
        );

  final String id;
  final String name;
  final String icon;
  final bool deleted;
}
