import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/user_projects.dart';

abstract class Database {
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData);
  Future<int> joinProject(String projectId);
  Future<void> createNewMessage(String projectId, String message);
  Stream<List<UserProjects>> userProjectsStream();
  Future<bool> checkCode(String code);
  String getUid();
  Future<String> getName();
}

class FirestoreDatabase implements Database {
  final String uid;

  FirestoreDatabase({
    @required this.uid,
  }) : assert(uid != null);

  @override
  String getUid() {
    return uid;
  }

  Future<String> getName() async {
    String _name;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _name = value.data['name'];
    });
    return _name;
  }

  @override
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData) async {
    await _setData('users/$uid/projects/$projectId', projectData);
    await _setData('projects/$projectId', projectData);
    addUserToProject(projectId); 
  }

  @override
  Future<int> joinProject(String projectId) async {
    var _isUserPresent = await Firestore.instance.collection('projects').document(projectId).collection('users').document(uid).get();
    if (_isUserPresent.data == null) {
      print("ADDING NEW USER TO PROJECT");
      String _code;
      String _title;
      String _description;
      Timestamp _deadline;
      List _admin;
      bool _valid = false;
      await Firestore.instance.collection('projects').document(projectId).get().then((value) {
        if (value.data != null) { 
          _code = value.data['code'];
          _title = value.data['title'];
          _description = value.data['description'];
          _deadline = value.data['deadline'];
          _admin = value.data['admin'];
          _valid = true;
        }
      });
      if (_valid) {
        await _setData('users/$uid/projects/$projectId', {
          "title": _title,
          "code": _code,
          "description": _description,
          "deadline": _deadline,
          "admin": _admin,
        });
        addUserToProject(projectId);
        return 1;
      }
    } else {
      print("USER ALREADY EXIST");
      return 2;
    }
    return 3;
  }

  @override
  Future<void> createNewMessage(String projectId, String message) async {
    String _time = DateTime.now().toString();
    String _name;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _name = value.data['name'];
    });
    await _setData('projects/$projectId/chat/$_time', {
      "name": _name,
      "message": message,
      "time": FieldValue.serverTimestamp(),
      "user": uid,
      "event": false,      
    });
  }

  Future<void> addUserToProject(String projectId) async {
    String _uid;
    String _name;
    String _email;
    String _time = DateTime.now().toString();
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _uid = value.data['uid'];
      _name = value.data['name'];
      _email = value.data['email'];
    });
    await _setData('projects/$projectId/users/$uid', {
      "uid": _uid,
      "name": _name,
      "email": _email,
    });
    await _setData('projects/$projectId/chat/$_time', {
      "name": _name,
      "message": "$_name has joined this project group",
      "timesort": FieldValue.serverTimestamp(),
      "time": FieldValue.serverTimestamp().toString(),
      "chatId": _time,
      "user": _uid,
      "event": true,
    });
  }

  @override
  Stream<List<UserProjects>> userProjectsStream() {
    return _collectionStream(
      path: 'users/$uid/projects', 
      builder: (data) => UserProjects.fromMap(data),
      orderBy: "deadline",
      descending: false,
    );
  }
  
  @override
  Future<bool> checkCode(String code) async {
    var lenCode;
    await Firestore.instance.collection('codes').where("code", isEqualTo: code).getDocuments().then((value) {
      lenCode = value.documents.toList().length;
      print(value.documents.toList().length);
    });
    if (lenCode == 0) {
      _addCode({'code': code}, code);
      return false;
    } else {
      return true;
    }
  }

  Future<void> _addCode(Map<String, dynamic> data, String code) async {
    await _setData('codes/$code', data);
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
}