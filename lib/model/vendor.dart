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

  Vendor.fromMap(Map<String, dynamic> data)
      : this(
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

  Vendor.fromDocument(DocumentSnapshot document)
      : this(
          id: document.id,
          name: document['name'],
          businessPhone: document['business_phone'],
          contactName: document['contact_name'],
          contactPhone: document['contact_phone'],
          contactTitle: document['contact_title'],
          address: document['address'],
          about: document['about'],
          url: document['url'],
          coverPhotoUrl: document['cover_url'],
          email: document['email'],
          deleted: document['deleted'],
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

  Vendor copyWith({
    String id,
    String name,
    String businessPhone,
    String contactName,
    String contactPhone,
    String contactTitle,
    String address,
    String about,
    String url,
    String coverPhotoUrl,
    String email,
    bool deleted,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      businessPhone: businessPhone ?? this.businessPhone,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactTitle: contactTitle ?? this.contactTitle,
      address: address ?? this.address,
      about: about ?? this.about,
      url: url ?? this.url,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      email: email ?? this.email,
      deleted: deleted ?? this.deleted,
    );
  }
}
