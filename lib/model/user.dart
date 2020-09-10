import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/model/searchable.dart';

class User implements Searchable {
  User(
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.room,
    this.role,
  );

  User.fromMap(DocumentSnapshot data)
      : this(
          data.id,
          data.data()["email"],
          data.data()["firstName"],
          data.data()["lastName"],
          data.data()["phone"],
          data.data()["room"],
          data.data()["associatedSchools"][
              (data.data()["associatedSchools"] as Map<String, dynamic>)
                  .keys
                  .first]["role"],
        );

  User.fromMapAndSchool(DocumentSnapshot data, String schoolId)
      : this(
    data.id,
    data.data()["email"],
    data.data()["firstName"],
    data.data()["lastName"],
    data.data()["phone"],
    data.data()["room"],
    data.data()["associatedSchools"][schoolId]["role"],
  );

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String room;
  final String role;

  String get name => "$firstName $lastName";

  @override
  String display() => name;

  @override
  bool filter(String input) => name.toLowerCase().contains(input.toLowerCase());

  @override
  bool operator ==(Object other) {
    return identical(this, other) || ((other is User) && this.id == other.id);
  }

  @override
  int get hashCode => this.id.hashCode;
}
