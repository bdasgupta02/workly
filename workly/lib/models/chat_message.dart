import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String name;
  final String user;
  final String message;
  final String time;
  final bool event;
  final String chatId;
  final Timestamp timesort;
  
  ChatMessage({
    @required this.name,
    @required this.user,
    @required this.message,
    @required this.time,
    @required this.event,
    @required this.chatId,
    @required this.timesort,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String user = data['user'];
    final String message = data['message'];
    final String time = data['time'].toString();
    final Timestamp timesort = data['timesort'];
    final bool event = data['event'];
    final String chatId = data['chatId'];

    DateTime date = DateTime.parse(timesort.toDate().toString());
    // String _dd = date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    // String _mm = date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    // String _yyyy = date.year.toString();
    String _hr = date.hour < 10 ? "0" + date.hour.toString() : date.hour.toString();
    String _min = date.minute < 10 ? "0" + date.minute.toString() : date.minute.toString();
    // String formattedDateTime = _dd + "/" + _mm + "/" + _yyyy + "    " + _hr + ":" + _min;
    String formattedTime = _hr + ":" + _min;
    return ChatMessage(name: name, user: user, message: message, time: formattedTime, event: event, timesort: timesort, chatId: chatId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'user': user,
      'message': message,
      'time': time, 
      'timesort': timesort,
      'event': event,
      'chatId': chatId,
    };
  }
}