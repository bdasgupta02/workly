import 'package:flutter/material.dart';

class MeetingModel {
  final String user;
  final String title;
  final String description;
  final String location;
  final String meetingId;
  final String date;
  final String time;
  final List attending;
  final List maybe;
  final List notAttending;

  MeetingModel({
    @required this.user,
    @required this.title,
    @required this.description,
    @required this.location,
    @required this.meetingId,
    @required this.date,
    @required this.time,
    @required this.attending,
    @required this.maybe,
    @required this.notAttending,
  });

  factory MeetingModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String user = data['user'];
    final String title = data['title'];
    final String description = data['description'];
    final String location = data['location'];
    final String meetingId = data['meetingId'];
    final String date = data['date'];
    final String time = data['time'];
    final List attending = data['attending'];
    final List maybe = data['maybe'];
    final List notAttending = data['notAttending'];
    // final String newTitle = title + " [" + name + "]";
    return MeetingModel(user: user, title: title, description: description, location: location, meetingId: meetingId, date: date, time: time, attending: attending, maybe: maybe, notAttending: notAttending);
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'title': title,
      'description': description, 
      'location': location,
      'meetingId': meetingId,
      'date': date,
      'time': time,
      'attending': attending,
      'maybe': maybe,
      'notAttending': notAttending,
    };
  }
}