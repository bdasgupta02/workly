import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskModel {
  final String name;
  final String uid;
  final List assignedUid;
  final List assignedName;
  final String title;
  final String description;
  final String taskId;
  final int priority;
  final int state;
  final String deadline;
  final Timestamp deadlineTS;
 
  TaskModel({
    @required this.name,
    @required this.uid,
    @required this.assignedUid,
    @required this.assignedName,
    @required this.title,
    @required this.description,
    @required this.taskId,
    @required this.priority,
    @required this.state,
    @required this.deadline,
    @required this.deadlineTS,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String uid = data['uid'];
    final List assignedUid = data['assignedUid'];
    final List assignedName = data['assignedName'];
    final String title = data['title'];
    final String description = data['description'];
    final String taskId = data['taskId'];
    final int priority = data['priority'];
    final int state = data['state'];
    final Timestamp deadline = data['deadline'];
    
    DateTime date = DateTime.parse(deadline.toDate().toString());
    String _dd = date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    String _mm = date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    String _yyyy = date.year.toString();
    String formattedDeadline = _dd + "/" + _mm + "/" + _yyyy;
   
    return TaskModel(name: name, uid: uid, assignedUid: assignedUid, assignedName: assignedName, title: title, description: description, taskId: taskId, priority: priority, state: state, deadline: formattedDeadline, deadlineTS: deadline);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'assignedUid': assignedUid,
      'assignedName': assignedName,
      'title': title,
      'description': description, 
      'taskId': taskId,
      'priority': priority,
      'state': state,
      'deadline': deadline,
      'deadlineTS': deadline,
    };
  }
}