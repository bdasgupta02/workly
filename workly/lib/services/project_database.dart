import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/chat_message.dart';
import 'package:workly/models/idea.dart';
import 'package:workly/models/task_model.dart';

abstract class ProjectDatabase {
  Future<void> createIdea(String ideaId, Map<String, dynamic> ideaData);
  Future<void> createTask(String taskId, Map<String, dynamic> taskData);
  Future<void> createNewMessage(String message);
  Future<void> updateIdeaDetails(String ideaId, String ideaName, String ideaDescription);
  Future<void> updateTaskDetails(String taskId, Map<String, dynamic> taskData);
  Future<void> updateVotes(String ideaId);
  Future<void> deleteIdea(String ideaId);
  Future<void> deleteTask(String taskId);
  Future<List<Map<String, String>>> getUserList();
  Stream<List<ChatMessage>> chatStream();
  Stream<List<Idea>> ideaStream();
  Stream<List<TaskModel>> taskStream();
  Stream<List<TaskModel>> myTaskStream();
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
  Future<void> createTask(String taskId, Map<String, dynamic> taskData) async {
    await _setData('projects/$projectId/task/$taskId', taskData);
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
  Future<void> updateTaskDetails(String taskId, Map<String, dynamic> taskData) async {
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).updateData(taskData);
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

  @override
  Future<void> deleteTask(String taskId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).delete();
  }

  @override
  Future<List<Map<String, String>>> getUserList() async {
    List<Map<String, String>> userList = List<Map<String, String>>();
    var results = await Firestore.instance.collection('projects').document(projectId).collection('users').getDocuments();
    results.documents.forEach((value) {
      Map<String, String> userMap = {
        "name": value.data['name'],
        "uid": value.data['uid'],
      };
      userList.add(userMap);
    });
    return userList;
  }

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

  @override
  Stream<List<TaskModel>> taskStream() {
    return _collectionStream(
      path: 'projects/$projectId/task', 
      builder: (data) => TaskModel.fromMap(data),
      orderBy: "deadline",
      descending: false,
    );
  }

  @override
  Stream<List<TaskModel>> myTaskStream() {
    return _collectionStreamFilter(
      path: 'projects/$projectId/task', 
      builder: (data) => TaskModel.fromMap(data),
      filterBy: "assignedUid",
      filterValue: uid,
    );
  } 

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

  Stream<List<T>> _collectionStreamFilter<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
    String filterBy,
    String filterValue,
  }) {
    final reference = Firestore.instance.collection(path).where(filterBy, isEqualTo: filterValue);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.documents.map((snapshot) => builder(snapshot.data)).toList());
  }
}