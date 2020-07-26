import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:workly/models/user_projects.dart';
// import 'package:workly/models/user_tasks.dart';

abstract class Database {
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData);
  Future<void> updateUserToken(Map<String, dynamic> userToken);
  Future<int> joinProject(String projectId);
  Future<void> updateUserDetails(String name, String imgUrl);
  Future<void> createNewMessage(String projectId, String message);
  Future<List<Map>> userProjectDocuments();
  Future<List<Map>> userTaskDocuments();
  Future<List<Map>> userMeetingDocuments();
  // Stream<List<UserProjects>> userProjectsStream();
  // Stream<List<UserTasks>> userTasksStream();
  Future<bool> checkCode(String code);
  String getUid();
  Future<String> getName();
  Future<String> getImageUrl();
  List getUserUidList();
  List getUserNameList();
  List getUserImageUrlList();
  Future<bool> runListQuery(String projectId);
}

class FirestoreDatabase implements Database {
  final String uid;
  List userUidList;
  List userNameList;
  List userImageUrlList;

  FirestoreDatabase({
    @required this.uid,
  }) : assert(uid != null);

  @override
  String getUid() {
    return uid;
  }

  @override
  Future<String> getName() async {
    String _name;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _name = value.data['name'];
    });
    return _name;
  }

  @override
  Future<String> getImageUrl() async {
    String _url;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _url = value.data['imageUrl'];
    });
    return _url;
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
  List getUserImageUrlList() {
    return userImageUrlList;
  }

  @override
  Future<bool> runListQuery(String projectId) async {
    List _userUid;
    List _userName;
    List _userImageUrl;
    bool _valid = false;
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      if (value.data != null) { 
        _userUid = value.data['userUid'];
        _userName = value.data['userName'];
        _userImageUrl = value.data['userImageUrl'];
        _valid = true;
      }
    });
    if (_valid) {
      userUidList = _userUid;
      userNameList = _userName;
      userImageUrlList = _userImageUrl;
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> updateUserToken(Map<String, dynamic> userToken) async {
    try {
      await Firestore.instance.collection('users').document(uid).updateData(userToken);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<void> createUserProject(String projectId, Map<String, dynamic> projectData) async {
    // await _setData('users/$uid/projects/$projectId', projectData);
    await _setData('projects/$projectId', projectData);
    addProjectToUser(projectId);
    String _name = await getName();
    await _sendJoinEventMessage(projectId, _name, uid);
    // addUserToProject(projectId); 
  }

  @override
  Future<int> joinProject(String projectId) async {
    var _isUserPresent = await Firestore.instance.collection('users').document(uid).get();
    if (!_isUserPresent.data['project'].contains(projectId)) {
      print("ADDING NEW USER TO PROJECT");
      String _code;
      String _title;
      String _description;
      Timestamp _deadline;
      bool _valid = false;
      await Firestore.instance.collection('projects').document(projectId).get().then((value) {
        if (value.data != null) { 
          _code = value.data['code'];
          _title = value.data['title'];
          _description = value.data['description'];
          _deadline = value.data['deadline'];
          _valid = true;
        }
      });
      if (_valid) {
        // await _setData('users/$uid/projects/$projectId', {
        //   "title": _title,
        //   "code": _code,
        //   "description": _description,
        //   "deadline": _deadline,
        // });
        addProjectToUser(projectId);
        addUserToProject(projectId);
        addMeetingsToUser(projectId);
        return 1;
      }
    } else {
      print("USER ALREADY EXIST");
      return 2;
    }
    return 3;
  }

  Future<void> addProjectToUser(String projectId) async {
    List currentProjectList = new List();
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      if (value.data != null) { 
        if (value.data['project'] != null) {
          currentProjectList = value.data['project'];
        }
      }
    });
    currentProjectList.add(projectId);
    await Firestore.instance.collection('users').document(uid).updateData({'project': currentProjectList});
  }

  @override
  Future<void> updateUserDetails(String name, String imgUrl) async {
    String projectId = "";
    List userUid = new List();
    List userName = new List();
    List userImage = new List();
    var results = await Firestore.instance.collection('projects').where('userUid', arrayContains: uid)
    .getDocuments();
    results.documents.forEach((element) async {
      userUid = element.data['userUid'];
      userName = element.data['userName'];
      userImage = element.data['userImageUrl'];
      projectId = element.data['code'];
      int idIdx = userUid.indexOf(uid);
      userName[idIdx] = name;
      print(userImage);
      if (imgUrl != null) {
        userImage[idIdx] = imgUrl;
      }
      await Firestore.instance.collection('projects').document(projectId).updateData({
        'userUid': userUid,
        'userName': userName,
        'userImageUrl': userImage,
      });
      userUid = new List();
      userName = new List();
      userImage = new List();
      projectId = '';      
    });
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
    // String _email;
    var _imageUrl;
    List _userUid;
    List _userName;
    List _userImageUrl;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _uid = value.data['uid'];
      _name = value.data['name'];
      // _email = value.data['email'];
      _imageUrl = value.data['imageUrl'];
    });
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      _userUid = value.data['userUid'];
      _userName = value.data['userName'];
      _userImageUrl = value.data['userImageUrl'];
    });
    // await _setData('projects/$projectId/users/$uid', {
    //   "uid": _uid,
    //   "name": _name,
    //   "email": _email,
    //   "imageUrl": _imageUrl,
    // });
    _userUid.add(_uid);
    _userName.add(_name);
    _userImageUrl.add(_imageUrl);
    await Firestore.instance.collection('projects').document(projectId).updateData({
      "userUid": _userUid,
      "userName": _userName,
      "userImageUrl": _userImageUrl,
    });
    _sendJoinEventMessage(projectId, _name, _uid);
  }

  Future<void> addMeetingsToUser(String projectId) async {
    List currentMeetingList = new List();
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      if (value.data != null) { 
        if (value.data['meeting'] != null) {
          currentMeetingList = value.data['meeting'];
        }
      }
    });
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        Map<String, dynamic> meetingLoc = {
          "projectId": projectId,
          "meetingId": result.data['meetingId'],
        };
        currentMeetingList.add(meetingLoc);
      });
    });
    await Firestore.instance.collection('users').document(uid).updateData({
      'meeting': currentMeetingList,
    });
  }

  Future<void> _sendJoinEventMessage(String projectId, String name, String uid) async {
    String _time = DateTime.now().toString();
    await _setData('projects/$projectId/chat/$_time', {
      "name": name,
      "message": "$name has joined this project group",
      "timesort": FieldValue.serverTimestamp(),
      "time": FieldValue.serverTimestamp(),
      "chatId": _time,
      "user": uid,
      "event": true,
    });
  }

  @override
  Future<List<Map>> userProjectDocuments() async {
    List projectList = new List();
    List<Map> newProjectList = new List();
    Map projectMap = new Map();
    await Firestore.instance.collection('users').document(uid).get().then((value) async {
      if (value.data != null) { 
        if (value.data['project'] != null) {
          projectList = value.data['project'];
          for (var ele in projectList) {
            await Firestore.instance.collection('projects').document(ele).get().then((valueP) {
              if (valueP.data != null) { 
                projectMap['projectId'] = valueP.data['code'];
                projectMap['projectTitle'] = valueP.data['title'];
                projectMap['projectDesc'] = valueP.data['description'];
                projectMap['projectDeadline'] = convertTimeStampToStringDate(valueP.data['deadline']);
              }
            });
            newProjectList.add(projectMap);
            projectMap = new Map(); 
            projectList = new List();
          }
        }
      }
    });
    return newProjectList;
  }

  @override
  Future<List<Map>> userTaskDocuments() async {
    List taskList = new List();
    List<Map> newTaskList = new List();
    Map taskMap = new Map();
    await Firestore.instance.collection('users').document(uid).get().then((value) async {
      if (value.data != null && value.data['task'] != null) { 
        taskList = value.data['task'];
        for (var ele in taskList) {
          await Firestore.instance.collection('projects').document(ele['projectId']).get().then((valueP) {
            if (valueP.data != null) { 
              taskMap['projectId'] = valueP.data['code'];
              taskMap['projectTitle'] = valueP.data['title'];
            }
          });
          await Firestore.instance.collection('projects').document(ele['projectId']).collection('task').document(ele['taskId']).get().then((valueT) {
            if (valueT.data != null) { 
              taskMap['taskId'] = valueT.data['taskId'];
              taskMap['taskTitle'] = valueT.data['title'];
              taskMap['taskDeadline'] = convertTimeStampToStringDate(valueT.data['deadline']);
            }
          });
          newTaskList.add(taskMap);
          taskMap = new Map(); 
          taskList = new List();
        }
      }
    });
    return newTaskList;
  }

  @override
  Future<List<Map>> userMeetingDocuments() async {
    List meetingList = new List();
    List<Map> newMeetingList = new List();
    Map meetingMap = new Map();
    await Firestore.instance.collection('users').document(uid).get().then((value) async {
      if (value.data != null && value.data['meeting'] != null) { 
        meetingList = value.data['meeting'];
        for (var ele in meetingList) {
          await Firestore.instance.collection('projects').document(ele['projectId']).get().then((valueP) {
            if (valueP.data != null) { 
              meetingMap['projectId'] = valueP.data['code'];
              meetingMap['projectTitle'] = valueP.data['title'];
            }
          });
          await Firestore.instance.collection('projects').document(ele['projectId']).collection('meeting').document(ele['meetingId']).get().then((valueM) {
            if (valueM.data != null) { 
              meetingMap['meetingId'] = valueM.data['meetingId'];
              meetingMap['meetingTitle'] = valueM.data['title'];
              meetingMap['meetingDate'] = convertTimeStampToStringDate(valueM.data['dateSort']);
              meetingMap['meetingTime'] = valueM.data['time'];
              if (valueM.data['attending'].contains(uid)) {
                meetingMap['attendance'] = "attending";
              } else if (valueM.data['maybe'].contains(uid)) {
                meetingMap['attendance'] = "maybe";
              } else if (valueM.data['notAttending'].contains(uid)) {
                meetingMap['attendance'] = "notAttending";
              } else {
                meetingMap['attendance'] = 'not indicated';
              }
            }
          });
          newMeetingList.add(meetingMap);
          meetingMap = new Map(); 
          meetingList = new List();
        }
      }
    });
    return newMeetingList;
  }

  // @override
  // Stream<List<UserProjects>> userProjectsStream() {
  //   return _collectionStream(
  //     path: 'users/$uid/projects', 
  //     builder: (data) => UserProjects.fromMap(data),
  //     orderBy: "deadline",
  //     descending: false,
  //   );
  // }

  // @override
  // Stream<List<UserTasks>> userTasksStream() {
  //   return _collectionStream(
  //     path: 'users/$uid/task', 
  //     builder: (data) => UserTasks.fromMap(data),
  //     orderBy: "deadline",
  //     descending: false,
  //   );
  // }
  
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
  
  String convertTimeStampToStringDate(Timestamp deadline) {
    DateTime date = DateTime.parse(deadline.toDate().toString());
    String _dd = date.day < 10 ? '0' + date.day.toString() : date.day.toString();
    String _mm = date.month < 10 ? '0' + date.month.toString() : date.month.toString();
    String _yyyy = date.year.toString();
    String formattedDeadline = _dd + '/' + _mm + '/' + _yyyy;
    return formattedDeadline;
  }
}