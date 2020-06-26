import 'package:flutter/material.dart';

class Deadline {
  final String id;
  final String description;
  final DateTime date;

  Deadline({
    @required this.id,
    @required this.description,
    @required this.date,
  });

  factory Deadline.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return Deadline(
      id: data['id'],
      description: data['description'],
      date: data['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'description' : description,
      'date' : date,
    };
  }
}
