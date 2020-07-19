import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTasks {
  final String deadline;
  final String priority;
  final String projectName;
  final String state;
  final String taskId;
  final String title;


  UserTasks({
    @required this.deadline,
    @required this.priority,
    @required this.projectName,
    @required this.state,
    @required this.taskId,
    @required this.title,
  });

  factory UserTasks.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final Timestamp deadline = data['deadline'];
    final String priority = data['priority'];
    final String projectName = data['projectName'];
    final String state = data['state'];
    final String taskId = data['taskId'];
    final String title = data['title'];

    DateTime date = DateTime.parse(deadline.toDate().toString());
    String _dd = date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    String _mm = date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    String _yyyy = date.year.toString();
    String formattedDeadline = _dd + "/" + _mm + "/" + _yyyy;

    return UserTasks(deadline: formattedDeadline, priority: priority, projectName: projectName, state: state, taskId: taskId, title: title);
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'deadline': deadline,
      'projectName': projectName, 
      'state': state,
      'priority': priority,
    };
  }
}