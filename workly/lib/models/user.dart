import 'package:flutter/material.dart';

class User {
  final String name;
  final String uid;
  final String email;
  
  User({
    @required this.name,
    @required this.uid,
    @required this.email,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String uid = data['uid'];
    final String email = data['email'];

    return User(name: name, uid: uid, email: email);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
    };
  }
}