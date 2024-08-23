import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String profilePicture;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.profilePicture,
  });

  // Convert from Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      profilePicture: data['profilePicture'],
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
    };
  }
}
