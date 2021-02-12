import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Vendor {
  Vendor({
    this.id,
    this.name,
    this.contactName,
    this.contactPhone,
    this.address,
    this.about,
    this.url,
    this.coverPhotoUrl,
    this.email,
  });

  Vendor.fromMap(Map<String, dynamic> data) : this(
    name: data['name'],
    contactName: data['contact_name'],
    contactPhone: data['contact_phone'],
    address: data['address'],
    about: data['about'],
    url: data['url'],
    coverPhotoUrl: data['cover_url'],
    email: data['email'],
  );

  Vendor.fromDocument(DocumentSnapshot document) : this(
    id: document.id,
    name: document.data()['name'],
    contactName: document.data()['contact_name'],
    contactPhone: document.data()['contact_phone'],
    address: document.data()['address'],
    about: document.data()['about'],
    url: document.data()['url'],
    coverPhotoUrl: document.data()['cover_url'],
    email: document.data()['email'],
  );

  final String id;
  final String name;
  final String contactName;
  final String contactPhone;
  final String address;
  final String about;
  final String url;
  final String coverPhotoUrl;
  final String email;
}
