import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProjects {
  final String title;
  final String description;
  final String deadline;
  final String code;
  final List admin;

  UserProjects({
    @required this.title,
    @required this.description,
    @required this.deadline,
    @required this.code,
    @required this.admin,
  });

  factory UserProjects.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String title = data['title'];
    final String description = data['description'];
    final Timestamp deadline = data['deadline'];
    final String code = data['code'];
    final List admin = data['admin'];
    
    // String date = deadline.toDate().toString().substring(0,10);
    // int indexOfSlash = date.indexOf("-");
    // String _yyyy = date.substring(0,indexOfSlash);
    // int indexOfSecondSlash = date.substring(indexOfSlash+1).indexOf("-");
    // String _mm = date.substring(indexOfSlash+1).substring(0, indexOfSecondSlash);
    // String _dd = date.substring(indexOfSlash+1).substring(indexOfSecondSlash+1);
    // String formattedDeadline =  _dd + "/" + _mm + "/" + _yyyy;

    DateTime date = DateTime.parse(deadline.toDate().toString());
    String _dd = date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    String _mm = date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    String _yyyy = date.year.toString();
    String formattedDeadline = _dd + "/" + _mm + "/" + _yyyy;

    return UserProjects(title: title, description: description, deadline: formattedDeadline, code: code, admin: admin);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'code': code,
      'admin': admin,
    };
  }
}