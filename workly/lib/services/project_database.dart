import 'dart:async';

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
  Future<void> updateAdminUser(List admin);
  Future<void> deleteProject();
  Future<void> exitProject(String id, String name, bool leave);
  Future<void> deleteIdea(String ideaId);
  Future<void> deleteTask(String taskId);
  Future<Map> getUserList();
  Future<List> getAdminUserList();
  Future<String> getProjectDescription();
  Stream<List<ChatMessage>> chatStream();
  Stream<List<Idea>> ideaStream();
  Stream<List<TaskModel>> taskStream();
  Stream<List<TaskModel>> myTaskStream();
  String getUid();
  String getUserName();
  String getProjectName();
  String getProjectId();
  String getImageUrl();
  List getUserUidList();
  List getUserNameList();
  List getUserImageList();
}

class FirestoreProjectDatabase implements ProjectDatabase {
  final String uid;
  final String userName;
  final String projectId;
  final String projectName;
  var imageUrl;
  List userUidList;
  List userNameList;
  List userImageList;

  FirestoreProjectDatabase({
    @required this.uid,
    @required this.userName,
    @required this.projectId,
    @required this.projectName,
    @required this.imageUrl,
    @required this.userUidList,
    @required this.userNameList,
    @required this.userImageList,
  }) : assert(uid != null), assert(userName != null), assert(projectId != null), assert(projectName != null), assert(userUidList != null), assert(userNameList != null), assert(userImageList != null);

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
  String getImageUrl() {
    return imageUrl;
  }

  @override
  List getUserUidList() {
    return userUidList;
  }
  
  @override
  List getUserNameList() {
    return userNameList;
  }

  @override
  List getUserImageList() {
    return userImageList;
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
  Future<void> updateAdminUser(List admin) async {
    await Firestore.instance.collection('projects').document(projectId).updateData({
      "admin": admin,
    });
  }

  @override
  Future<void> deleteProject() async {
    await exitProject(null, null, true);
    await Firestore.instance.collection('projects').document(projectId).delete();
  }

  @override
  Future<void> exitProject(String id, String name, bool leave) async {
    String _uid = id == null ? uid : id;
    String _name = name == null ? userName : name;
    await Firestore.instance.collection('projects').document(projectId).collection('users').document(_uid).delete();
    await Firestore.instance.collection('users').document(_uid).collection('projects').document(projectId).delete();
    sendLeaveMsg(_uid, _name, leave);
    removeTaskAssignment(_uid, _name);
    removeIdeasVoting(_uid, _name);
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
  Future<Map> getUserList() async {
    Map userList = new Map();

    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      if (value.data != null) { 
        userList['userUidList'] = value.data['userUid'];
        userList['userNameList'] = value.data['userName'];
        userList['userImageUrlList'] = value.data['userImageUrl'];
      }
    });
    return userList;
  }

  @override
  Future<List> getAdminUserList() async {
    List userList = List();
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      userList = value.data['admin'];
    });
    return userList;
  }

  @override
  Future<String> getProjectDescription() async {
    String description = "";
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      description = value.data['description'];
    });
    return description;
  }
  
  Future<void> removeTaskAssignment(String id, String name) async {
    List assignListId = List();
    List assignListName = List();
    String taskId = "";
    var results = await Firestore.instance.collection('projects').document(projectId).collection('task').where("assignedUid", arrayContains: id)
    .getDocuments();
    results.documents.forEach((element) async {
      assignListId = element.data['assignedUid'];
      assignListName = element.data['assignedName'];
      taskId = element.data['taskId'];
      int idIdx = assignListId.indexOf(id);
      assignListId.removeAt(idIdx);
      assignListName.removeAt(idIdx);
      await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).updateData({
        "assignedName": assignListName,
        "assignedUid": assignListId,
      });
      assignListId = List();
      assignListName = List();
      taskId = "";      
    });
  }

  Future<void> removeIdeasVoting(String id, String name) async {
    List votesListId = List();
    int voteCount = 0;
    String ideaId = "";
    var results = await Firestore.instance.collection('projects').document(projectId).collection('idea').where("votes", arrayContains: id)
    .getDocuments();
    results.documents.forEach((element) async {
      votesListId = element.data['votes'];
      voteCount = element.data['voteCount'];
      ideaId = element.data['ideaId'];
      votesListId.remove(id);
      voteCount  = voteCount - 1;
      await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
        "voteCount": voteCount,
        "votes": votesListId,
      });
      votesListId = List();
      voteCount = 0;
      ideaId = "";      
    });    
  }

  Future<void> sendLeaveMsg(String id, String name, bool leave) async {
    String _time = DateTime.now().toString();
    String _msg = leave ? "$name has left this project group" : "$name has been removed from this project group";
    await _setData('projects/$projectId/chat/$_time', {
      "name": name,
      "message": _msg,
      "timesort": FieldValue.serverTimestamp(),
      "time": FieldValue.serverTimestamp().toString(),
      "chatId": _time,
      "user": id,
      "event": true,
    });
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
    final reference = Firestore.instance.collection(path).where(filterBy, arrayContains: filterValue);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.documents.map((snapshot) => builder(snapshot.data)).toList());
  }
}

class ChatStreamPagination {
  final String projectId;

  ChatStreamPagination({@required this.projectId});

  // static final CollectionReference _chatCollectionReference =
      // Firestore.instance.collection('projects/$projectId/chat');//aW9Ti7

  final StreamController<List<ChatMessage>> _chatController =
      StreamController<List<ChatMessage>>.broadcast();

  List<List<ChatMessage>> _allPagedResults = List<List<ChatMessage>>();

  static const int chatLimit = 5;
  DocumentSnapshot _lastDocument;
  bool _hasMoreData = true;

  Stream listenToChatsRealTime() {
    print("LISTEN TO CHAT");
    _requestChats();
    return _chatController.stream;
  }

  void _requestChats() {
    var pagechatQuery = Firestore.instance.collection('projects/$projectId/chat')
        .orderBy('timesort', descending: true)
        .limit(chatLimit);
    print(pagechatQuery);
    if (_lastDocument != null) {
      pagechatQuery =
          pagechatQuery.startAfterDocument(_lastDocument);
    }

    if (!_hasMoreData) return;

    var currentRequestIndex = _allPagedResults.length;

    pagechatQuery.snapshots().listen(
      (snapshot) {
        if (snapshot.documents.isNotEmpty) {
          var generalChats = snapshot.documents
              .map((snapshot) => ChatMessage.fromMap(snapshot.data))
              .toList();
          generalChats.sort((x,y) => x.timesort.compareTo(y.timesort));
          print("PRINT CHAT");
          print(generalChats);
          var pageExists = currentRequestIndex < _allPagedResults.length;

          if (pageExists) {
            _allPagedResults[currentRequestIndex] = generalChats;
          } else {
            _allPagedResults.add(generalChats);
          }

          var allChats = _allPagedResults.fold<List<ChatMessage>>(
              List<ChatMessage>(),
              // (initialValue, pageItems) => initialValue..addAll(pageItems));
              (initialValue, pageItems) => initialValue..insertAll(0, pageItems));

          _chatController.add(allChats);

          if (currentRequestIndex == _allPagedResults.length - 1) {
            _lastDocument = snapshot.documents.last;
          }

          _hasMoreData = generalChats.length == chatLimit;
        }
      },
    );
  }

  void requestMoreData() => _requestChats();
}