import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  Rating({
    this.id,
    this.stars,
    this.title,
    this.description,
    this.ratingPhoto,
    this.userPhoto,
    this.userDisplayName,
  });

  Rating.fromDocument(DocumentSnapshot snapshot)
      : this(
          id: snapshot.id,
          stars: snapshot.data()['stars'],
          title: snapshot.data()['title'],
          description: snapshot.data()['description'],
          ratingPhoto: snapshot.data()['ratingPhoto'],
          userPhoto: snapshot.data()['userPhoto'],
          userDisplayName: snapshot.data()['userDisplayName'],
        );

  final String id;
  final int stars;
  final String title;
  final String description;
  final String ratingPhoto;
  final String userPhoto;
  final String userDisplayName;

  Map<String, dynamic> get map => <String, dynamic>{
        'stars': this.stars,
        'title': this.title,
        'description': this.description,
        'ratingPhoto': this.ratingPhoto,
        'userPhoto': this.userPhoto,
        'userDisplayName': this.userDisplayName,
      };

  Rating copyWith({
    String id,
    int stars,
    String title,
    String description,
    String ratingPhoto,
    String userPhoto,
    String userDisplayName,
  }) {
    return Rating(
      id: id ?? this.id,
      stars: stars ?? this.stars,
      title: title ?? this.title,
      description: description ?? this.description,
      ratingPhoto: ratingPhoto ?? this.ratingPhoto,
      userPhoto: userPhoto ?? this.userPhoto,
      userDisplayName: userDisplayName ?? this.userDisplayName,
    );
  }
}
