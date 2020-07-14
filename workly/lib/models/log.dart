import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Log {
  final String name;
  final String user;
  final String description;
  final String date;
  final bool task;
  
  Log({
    @required this.name,
    @required this.user,
    @required this.description,
    @required this.date,
    @required this.task,
  });

  factory Log.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String user = data['user'];
    final String description = data['description'];
    final Timestamp date = data['date'];
    final bool task = data['task'];

    DateTime newDate = DateTime.parse(date.toDate().toString());
    String _dd = newDate.day < 10 ? "0" + newDate.day.toString() : newDate.day.toString();
    String _mm = newDate.month < 10 ? "0" + newDate.month.toString() : newDate.month.toString();
    String _yyyy = newDate.year.toString();
    String _hr = newDate.hour < 10 ? "0" + newDate.hour.toString() : newDate.hour.toString();
    String _min = newDate.minute < 10 ? "0" + newDate.minute.toString() : newDate.minute.toString();
    String formattedDateTime = _dd + "/" + _mm + "/" + _yyyy + "  -  [" + _hr +":"+_min + "]";
    return Log(name: name, user: user, description: description, date: formattedDateTime, task: task);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'user': user,
      'description': description,
      'date': date, 
      'task': task,
    };
  }
}