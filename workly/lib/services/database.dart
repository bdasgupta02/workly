import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/user_projects.dart';

abstract class Database {
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData);
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
    //await _setData('users/$uid', projectData);  
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