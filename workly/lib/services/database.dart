import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/user_projects.dart';

abstract class Database {
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData);
  Future<void> joinProject(String projectId);
  Stream<List<UserProjects>> userProjectsStream();
  Future<bool> checkCode(String code);
}

class FirestoreDatabase implements Database {
  final String uid;

  FirestoreDatabase({
    @required this.uid,
  }) : assert(uid != null);

  @override
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData) async {
    await _setData('users/$uid/projects/$projectId', projectData);
    await _setData('projects/$projectId', projectData);
    addUserToProject(projectId); 
  }

  @override
  Future<void> joinProject(String projectId) async {
    String _code;
    String _title;
    String _description;
    String _deadline;
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      _code = value.data['code'];
      _title = value.data['title'];
      _description = value.data['description'];
      _deadline = value.data['deadline'];
    });
    await _setData('users/$uid/projects/$projectId', {
      "title": _title,
      "code": _code,
      "description": _description,
      "deadline": _deadline,
    });
    addUserToProject(projectId);
  }

  Future<void> addUserToProject(String projectId) async {
    String _uid;
    String _name;
    String _email;
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
  }

  @override
  Stream<List<UserProjects>> userProjectsStream() {
    return _collectionStream(
      path: 'users/$uid/projects', 
      builder: (data) => UserProjects.fromMap(data),
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
  }) {
    final reference = Firestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.documents.map((snapshot) => builder(snapshot.data)).toList());
  }
}