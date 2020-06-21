import 'package:flutter/material.dart';

class Idea {
  final String name;
  final String user;
  final String title;
  final String description;
  final String ideaId;
  final List votes;
  final int voteCount;
  
  Idea({
    @required this.name,
    @required this.user,
    @required this.title,
    @required this.description,
    @required this.ideaId,
    @required this.votes,
    @required this.voteCount,
  });

  factory Idea.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String user = data['user'];
    final String title = data['title'];
    final String description = data['description'];
    final String ideaId = data['ideaId'];
    final List votes = data['votes'];
    final int voteCount = data['voteCount'];
    final String newTitle = title + " [" + name + "]";
    return Idea(name: name, user: user, title: newTitle, description: description, ideaId: ideaId, votes: votes, voteCount: voteCount);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'user': user,
      'title': title,
      'description': description, 
      'ideaId': ideaId,
      'votes': votes,
      'voteCount': voteCount,
    };
  }
}