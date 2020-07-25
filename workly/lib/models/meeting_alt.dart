import 'package:flutter/material.dart';

class MeetingAlt {
  final String meetingAltId;
  final String user;
  final bool isMeetingCreator;
  final List votes;
  final int votesCount;
  final String date;
  final String time;
  final int acceptState;

  MeetingAlt({
    @required this.meetingAltId,
    @required this.user,
    @required this.isMeetingCreator,
    @required this.votes,
    @required this.votesCount,
    @required this.date,
    @required this.time,
    @required this.acceptState,
  });

  factory MeetingAlt.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String meetingAltId = data['meetingAltId'];
    final String user = data['user'];
    final bool isMeetingCreator = data['isMeetingCreator'];
    final List votes = data['votes'];
    final int votesCount = data['votesCount'];
    final String date = data['date'];
    final String time = data['time'];
    final int acceptState = data['acceptState'];

    return MeetingAlt(meetingAltId: meetingAltId, user: user, isMeetingCreator: isMeetingCreator, votes: votes, votesCount: votesCount, date: date, time: time, acceptState: acceptState);
  }

  Map<String, dynamic> toMap() {
    return {
      'meetingAltId': meetingAltId,
      'user': user,
      'isMeetingCreator': isMeetingCreator,
      'votes': votes, 
      'votesCount': votesCount,
      'date': date,
      'time': time,
      'acceptState': acceptState,
    };
  }
}