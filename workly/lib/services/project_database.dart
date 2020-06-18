import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/chat_message.dart';
import 'package:workly/models/idea.dart';

abstract class ProjectDatabase {
  Future<void> createIdea(String ideaId, Map<String, dynamic> ideaData);
  Future<void> createNewMessage(String message);
  Future<void> updateIdeaDetails(String ideaId, String ideaName, String ideaDescription);
  Future<void> updateVotes(String ideaId);
  Future<void> deleteIdea(String ideaId);
  Stream<List<ChatMessage>> chatStream();
  Stream<List<Idea>> ideaStream();
  String getUid();
  String getUserName();
  String getProjectName();
  String getProjectId();
}

class FirestoreProjectDatabase implements ProjectDatabase {
  final String uid;
  final String userName;
  final String projectId;
  final String projectName;

  FirestoreProjectDatabase({
    @required this.uid,
    @required this.userName,
    @required this.projectId,
    @required this.projectName,
  }) : assert(uid != null), assert(userName != null), assert(projectId != null), assert(projectName != null);

  @override
  String getUid() {
    return uid;
  }

  @override
  String getUserName() {
    return userName;
  }

  @override
  String getProjectName() {
    return projectName;
  }

  @override
  String getProjectId() {
    return projectId;
  }

  @override
  Future<void> createIdea(String ideaId, Map<String, dynamic> ideaData) async {
    await _setData('projects/$projectId/idea/$ideaId', ideaData);
  }

  @override
  Future<void> createNewMessage(String message) async {
    String _time = DateTime.now().toString();
    String _name;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _name = value.data['name'];
    });
    await _setData('projects/$projectId/chat/$_time', {
      "name": _name,
      "message": message,
      "timesort": FieldValue.serverTimestamp(),
      "time": FieldValue.serverTimestamp(),
      "chatId": _time,
      "user": uid,
      "event": false,      
    });
  }

  @override
  Future<void> updateIdeaDetails(String ideaId, String ideaName, String ideaDescription) async {
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
      "title": ideaName,
      "description": ideaDescription,
    });
  }

  @override
  Future<void> updateVotes(String ideaId) async {
    print("CALL UPDATE");
    bool _containUser;
    List _votes;
    int _voteCount;
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).get().then((value) {
      _votes = value.data['votes'];
      _voteCount = value.data['voteCount'];
      _containUser = _votes.contains(uid);
    });
    if (_containUser) {
      print('CONTAINS');
      _votes.remove(uid);
      _voteCount = _voteCount - 1;
    } else {
      print("DOES NOT CONTAINS");
      _votes.add(uid);
      _voteCount = _voteCount + 1;
    }
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
      "votes": _votes,
      "voteCount": _voteCount,
    });
  }

  @override
  Future<void> deleteIdea(String ideaId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).delete();
  }

  // Future<void> addUserToProject(String projectId) async {
  //   String _uid;
  //   String _name;
  //   String _email;
  //   String _time = DateTime.now().toString();
  //   await Firestore.instance.collection('users').document(uid).get().then((value) {
  //     _uid = value.data['uid'];
  //     _name = value.data['name'];
  //     _email = value.data['email'];
  //   });
  //   await _setData('projects/$projectId/users/$uid', {
  //     "uid": _uid,
  //     "name": _name,
  //     "email": _email,
  //   });
  //   await _setData('projects/$projectId/chat/$_time', {
  //     "name": _name,
  //     "message": "$_name has joined this group",
  //     "time": FieldValue.serverTimestamp(),
  //     "user": _uid,
  //     "event": true,
  //   });
  // }

  // @override
  // Stream<List<UserProjects>> userProjectsStream() {
  //   return _collectionStream(
  //     path: 'users/$uid/projects', 
  //     builder: (data) => UserProjects.fromMap(data),
  //     orderBy: "deadline",
  //     descending: false,
  //   );
  // }

  @override
  Stream<List<ChatMessage>> chatStream() {
    return _collectionStream(
      path: 'projects/$projectId/chat', 
      builder: (data) => ChatMessage.fromMap(data),
      orderBy: "timesort",
      descending: false,
    );
  }

  @override
  Stream<List<Idea>> ideaStream() {
    return _collectionStream(
      path: 'projects/$projectId/idea', 
      builder: (data) => Idea.fromMap(data),
      orderBy: "voteCount",
      descending: true,
    );
  }
  
  // @override
  // Future<bool> checkCode(String code) async {
  //   var lenCode;
  //   await Firestore.instance.collection('codes').where("code", isEqualTo: code).getDocuments().then((value) {
  //     lenCode = value.documents.toList().length;
  //     print(value.documents.toList().length);
  //   });
  //   if (lenCode == 0) {
  //     _addCode({'code': code}, code);
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  // Future<void> _addCode(Map<String, dynamic> data, String code) async {
  //   await _setData('codes/$code', data);
  // }

  Future<void> _setData(String path, Map<String, dynamic> data) async {
    final reference = Firestore.instance.document(path);
    print('$path: $data');
    await reference.setData(data);
  }

  Stream<List<T>> _collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
    String orderBy,
    bool descending,
  }) {
    final reference = Firestore.instance.collection(path).orderBy(orderBy, descending: descending);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.documents.map((snapshot) => builder(snapshot.data)).toList());
  }
}