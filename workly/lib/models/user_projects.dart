import 'package:flutter/material.dart';

class UserProjects {
  final String name;
  
  UserProjects({
    @required this.name,
  });

  factory UserProjects.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    return UserProjects(name: name,);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}