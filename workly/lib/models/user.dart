import 'package:flutter/material.dart';

class User {
  final String name;
  final String uid;
  final String email;
  var image; 
  
  User({
    @required this.name,
    @required this.uid,
    @required this.email,
    @required this.image,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String uid = data['uid'];
    final String email = data['email'];
    var image = data['imageUrl'];

    return User(name: name, uid: uid, email: email, image: image);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
      'image': image,
    };
  }
}