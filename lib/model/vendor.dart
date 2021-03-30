import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Vendor {
  Vendor({
    this.id,
    this.name,
    this.businessPhone,
    this.contactName,
    this.contactPhone,
    this.contactTitle,
    this.address,
    this.about,
    this.url,
    this.coverPhotoUrl,
    this.email,
    this.deleted,
  });

  Vendor.fromMap(Map<String, dynamic> data) : this(
    name: data['name'],
    businessPhone: data['business_phone'],
    contactName: data['contact_name'],
    contactPhone: data['contact_phone'],
    contactTitle: data['contact_title'],
    address: data['address'],
    about: data['about'],
    url: data['url'],
    coverPhotoUrl: data['cover_url'],
    email: data['email'],
    deleted: data['deleted'],
  );

  Vendor.fromDocument(DocumentSnapshot document) : this(
    id: document.id,
    name: document.data()['name'],
    businessPhone: document.data()['business_phone'],
    contactName: document.data()['contact_name'],
    contactPhone: document.data()['contact_phone'],
    contactTitle: document.data()['contact_title'],
    address: document.data()['address'],
    about: document.data()['about'],
    url: document.data()['url'],
    coverPhotoUrl: document.data()['cover_url'],
    email: document.data()['email'],
    deleted: document.data()['deleted'],
  );

  final String id;
  final String name;
  final String businessPhone;
  final String contactName;
  final String contactPhone;
  final String contactTitle;
  final String address;
  final String about;
  final String url;
  final String coverPhotoUrl;
  final String email;
  final bool deleted;
}
