import 'package:flutter/material.dart';

class IdeaComment {
  final String name;
  final String user;
  final String comment;
  final String commentId;

  
  IdeaComment({
    @required this.name,
    @required this.user,
    @required this.comment,
    @required this.commentId,
  });

  factory IdeaComment.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String user = data['user'];
    final String comment = data['comment'];
    final String commentId = data['commentId'];

    return IdeaComment(name: name, user: user, comment: comment, commentId: commentId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'user': user,
      'comment': comment, 
      'commentId': commentId,
    };
  }
}