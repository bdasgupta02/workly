import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String from;
  final String uid;
  final String message;
  final String date;
  final String time;
  
  ChatMessage({
    @required this.from,
    @required this.uid,
    @required this.message,
    @required this.date,
    @required this.time,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String from = data['from'];
    final String uid = data['uid'];
    final Timestamp dateSent = data['date'];
    final String message = data['message'];
    
    String date = dateSent.toDate().toString().substring(0,10);
    int indexOfSlash = date.indexOf("-");
    String _yyyy = date.substring(0,indexOfSlash);
    int indexOfSecondSlash = date.substring(indexOfSlash+1).indexOf("-");
    String _mm = date.substring(indexOfSlash+1).substring(0, indexOfSecondSlash);
    String _dd = date.substring(indexOfSlash+1).substring(indexOfSecondSlash+1);
    String formattedDeadline =  _dd + "/" + _mm + "/" + _yyyy;
    return ChatMessage(from: from, uid: uid, message: message, date: formattedDeadline, time:"To be formatted");
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'uid': uid,
      'message': message,
      'date': date,
    };
  }
}