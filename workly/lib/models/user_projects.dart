import 'package:flutter/material.dart';

class UserProjects {
  final String title;
  final String description;
  final String deadline;
  final String code;
  
  UserProjects({
    @required this.title,
    @required this.description,
    @required this.deadline,
    @required this.code,
  });

  factory UserProjects.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String title = data['title'];
    final String description = data['description'];
    final String deadline = data['deadline'];
    final String code = data['code'];
    return UserProjects(title: title, description: description, deadline: deadline, code: code);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'code': code,
    };
  }
}