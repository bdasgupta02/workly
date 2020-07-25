import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/chat_message.dart';
import 'package:workly/models/idea.dart';
import 'package:workly/models/idea_comment.dart';
import 'package:workly/models/log.dart';
import 'package:workly/models/meeting_alt.dart';
import 'package:workly/models/meeting_model.dart';
import 'package:workly/models/task_model.dart';

abstract class ProjectDatabase {
  Future<void> createIdea(String ideaId, Map<String, dynamic> ideaData);
  Future<void> createTask(String taskId, Map<String, dynamic> taskData);
  Future<void> createMeeting(String meetingId, Map<String, dynamic> meetingData);
  Future<void> createNewMessage(String message);
  Future<void> createIdeaComment(String ideaTitle, String ideaId, String commentId, Map<String, dynamic> taskData);
  Future<void> createMeetingAlt(String meetingTitle, String meetingId, String meetingAltId, Map<String, dynamic> meetingAltData);
  Future<void> updateIdeaDetails(String ideaId, String ideaName, String ideaDescription);
  Future<void> updateTaskDetails(String taskId, Map<String, dynamic> taskData);
  Future<void> updateMeetingDetails(String meetingId, Map<String, dynamic> meetingData);
  Future<void> updateMeetingAttending(int state, int oldState, String title, String meetingId);
  Future<void> updateAltMeetingDetails(String altMeetingId, String title, String meetingId, Map<String, dynamic> altMeetingData);
  Future<void> acceptAltMeetingDetails(String altMeetingId, String title, String meetingId, Map<String, dynamic> meetingData);
  Future<void> updateAltMeetingVotes(String altMeetingId, String date, String time, String title, String meetingId);
  Future<void> updateVotes(String ideaId);
  Future<void> updateAdminUser(List admin);
  Future<void> deleteProject();
  Future<void> exitProject(String id, String name, bool leave);
  Future<void> deleteChatMessage(String chatId);
  Future<void> deleteIdea(String ideaTitle, String ideaId);
  Future<void> deleteIdeaComment(String comment, String ideaTitle, String ideaId, String commentId);
  Future<void> deleteMeetingAlt(String meetingTitle, String meetingId, String meetingAltId, String date, String time);
  Future<void> deleteTask(String taskName, String taskId);
  Future<void> deleteMeeting(String meetingName, String meetingId);
  Future<Map> getUserList();
  Future<List> getAdminUserList();
  Future<String> getProjectDescription();
  Future<List<MeetingAlt>> meetingAltList(String meetingId);
  Stream<List<ChatMessage>> chatStream();
  Stream<List<Idea>> ideaStream();
  Stream<List<IdeaComment>> ideaCommentStream(String ideaId);
  Stream<List<TaskModel>> taskStream();
  Stream<List<TaskModel>> myTaskStream();
  Stream<List<MeetingModel>> meetingStream();
  Stream<List<Log>> logStream();
  Stream<List<Log>> myLogStream();
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
    String logDescription = '$userName created new Idea \'${ideaData['title']}\'';
    createNewLog(logDescription, false);   
    sendSystemMsg(uid, userName, logDescription);
  }

  @override
  Future<void> createTask(String taskId, Map<String, dynamic> taskData) async {
    await _setData('projects/$projectId/task/$taskId', taskData);
    String logDescription = '$userName created new Task \'${taskData['title']}\'';
    createNewLog(logDescription, true);
    sendSystemMsg(uid, userName, logDescription);
  }

  @override
  Future<void> createMeeting(String meetingId, Map<String, dynamic> meetingData) async {
    await _setData('projects/$projectId/meeting/$meetingId', meetingData);
    String logDescription = '$userName created new Meeting \'${meetingData['title']}\'';
    createNewLog(logDescription, false);
    String systemMsg = '$userName created new Meeting \'${meetingData['title']}\' on ${meetingData['date']} at ${meetingData['time']}';
    sendSystemMsg(uid, userName, systemMsg);
    Map<String, dynamic> meetingLoc = {
      "projectId": projectId,
      "meetingId": meetingId,
    };
    List currentMeetingList = new List();
    for (var ele in userUidList) {
      await Firestore.instance.collection('users').document(ele).get().then((value) {
        if (value.data != null) { 
          if (value.data['meeting'] != null) {
            currentMeetingList = value.data['meeting'];
          }
        }
      });
      currentMeetingList.add(meetingLoc);
      await Firestore.instance.collection('users').document(ele).updateData({'meeting': currentMeetingList});
    }
  }

  @override
  Future<void> createNewMessage(String message) async {
    String _time = DateTime.now().toString();
    String _name;
    await Firestore.instance.collection('users').document(uid).get().then((value) {
      _name = value.data['name'];
    });
    await _setData('projects/$projectId/chat/$_time', {
      'name': _name,
      'message': message,
      'timesort': FieldValue.serverTimestamp(),
      'time': FieldValue.serverTimestamp(),
      'chatId': _time,
      'user': uid,
      'event': false,      
    });
  }

  @override
  Future<void> createIdeaComment(String ideaTitle, String ideaId, String commentId, Map<String, dynamic> commentData) async {
    await _setData('projects/$projectId/idea/$ideaId/comment/$commentId', commentData);
    String logDescription = '$userName commented \'${commentData['comment']}\' on $ideaTitle';
    createNewLog(logDescription, false);
    String systemMsg = '$userName commented on $ideaTitle';
    sendSystemMsg(uid, userName, systemMsg);
  }

  @override
  Future<void> createMeetingAlt(String meetingTitle, String meetingId, String meetingAltId, Map<String, dynamic> meetingAltData) async {
    await _setData('projects/$projectId/meeting/$meetingId/alternative/$meetingAltId', meetingAltData);
    String logDescription = '$userName proposed an alternative meeting date and time  [${meetingAltData['date']}, ${meetingAltData['time']}] for $meetingTitle';
    createNewLog(logDescription, false);
    sendSystemMsg(uid, userName, logDescription);
  }

  Future<void> createNewLog(String description, bool task) async {
    String _time = DateTime.now().toString();
    await _setData('projects/$projectId/log/$_time', {
      'name': userName,
      'user': uid,
      'description': description,
      'date': FieldValue.serverTimestamp(),
      'task': task,    
    });
  }

  @override
  Future<void> updateIdeaDetails(String ideaId, String ideaName, String ideaDescription) async {
    String _title;
    String _description;
    String logDescription;
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).get().then((value) {
      _title = value.data['title'];
      _description = value.data['description'];
    });
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
      'title': ideaName,
      'description': ideaDescription,
    });
    if (_title != ideaName) {
      if (_description != ideaDescription) {
        logDescription = '$userName updated title and description of \'$_title\' to \nTitle: \'$ideaName\' \nDescription: \'$ideaDescription\'';
      } else {
        logDescription = '$userName updated title of \'$_title\' to \nTitle: \'$ideaName\'';
      }
    } else {
      logDescription = '$userName updated description of \'$_title\' to \nDescription: \'$ideaDescription\'';
    }
    createNewLog(logDescription, false);
  }

  @override
  Future<void> updateTaskDetails(String taskId, Map<String, dynamic> taskData) async {
    List<String> _priorityList = <String>['Low', 'Medium', 'High'];
    List<String> _stateList = <String>[
      'To do',
      'In progress',
      'To review',
      'Completed'
    ];
    // List _assignedUid;
    String _title;
    String _description;
    int _priority;
    int _state;
    Timestamp _deadline;
    List<String> listLog = List();
    String logDescription;
    bool runLoop = false;
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).get().then((value) {
      // _assignedUid = value.data['assignedUid'];
      _title = value.data['title'];
      _description = value.data['description'];
      _priority = value.data['priority'];
      _state = value.data['state'];
      _deadline = value.data['deadline'];
    });
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).updateData(taskData);
    if (taskData['title'] != null && _title != taskData['title']) {
      listLog.add('\nTitle was updated from \'$_title\' to \'${taskData['title']}\'');
      runLoop = true;
      _title = taskData['title'];
    }
    if (taskData['description'] != null && _description != taskData['description']) {
      listLog.add('\nDescription was updated from \'$_description\' to \'${taskData['description']}\'');
      runLoop = true;
      _description = taskData['description'];
    }
    if (taskData['priority'] != null && _priority != taskData['priority']) {
      listLog.add('\nPriority was updated from \'${_priorityList[_priority - 1]}\' to \'${_priorityList[taskData['priority'] - 1]}\'');
      runLoop = true;
      _priority = taskData['priority'];
    }
    if (taskData['state'] != null && _state != taskData['state']) {
      logDescription = '$userName updated the Task State from \'${_stateList[_state - 1]}\' to \'${_stateList[taskData['state'] - 1]}\'';
      _state = taskData['state'];
    }
    if (taskData['deadline'] != null && convertTimeStampToStringDate(_deadline) != convertTimeStampToStringDate(taskData['deadline'])) {
      listLog.add('\nDeadline was updated from \'${convertTimeStampToStringDate(_deadline)}\' to \'${convertTimeStampToStringDate(taskData['deadline'])}\'');
      runLoop = true;
      _deadline = taskData['deadline'];
    }
    if (taskData['assignedUid'] != null) {
      bool _assigned = taskData['assignedUid'].contains(uid);
      String _action = _assigned ? 'self-assigned to' : 'self-removed from';
      addTaskToUser(_assigned, taskId, _title, _deadline, _stateList[_state - 1], _priorityList[_priority - 1]);
      logDescription = '$userName $_action \'$_title\'';
    }
    if (runLoop) {
      updateTaskToUser(taskId, _title, _deadline, _stateList[_state - 1], _priorityList[_priority - 1]);
      logDescription = '$userName have updated the following details of Task \'$_title\':';
      for (var ele in listLog) {
        logDescription += ele;
      }
    }
    createNewLog(logDescription, true);  
  }

  @override
  Future<void> updateMeetingDetails(String meetingId, Map<String, dynamic> meetingData) async {
    String _title;
    String _description;
    String _location;
    String _date;
    String _time;
    List<String> listLog = List();
    String logDescription;
    bool runLoop = false;
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).get().then((value) {
      // _assignedUid = value.data['assignedUid'];
      _title = value.data['title'];
      _description = value.data['description'];
      _location = value.data['location'];
      _date = value.data['date'];
      _time = value.data['time'];
    });
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).updateData(meetingData);
    if (meetingData['title'] != null && _title != meetingData['title']) {
      listLog.add('\nTitle was updated from \'$_title\' to \'${meetingData['title']}\'');
      runLoop = true;
      _title = meetingData['title'];
    }
    if (meetingData['description'] != null && _description != meetingData['description']) {
      listLog.add('\nDescription was updated from \'$_description\' to \'${meetingData['description']}\'');
      runLoop = true;
      _description = meetingData['description'];
    }
    if (meetingData['location'] != null && _location != meetingData['location']) {
      listLog.add('\nLocation was updated from \'$_location\' to \'${meetingData['location']}\'');
      runLoop = true;
      _description = meetingData['location'];
    }
    if (meetingData['date'] != null && _date != meetingData['date']) {
      listLog.add('\nDate was updated from \'$_date\' to \'${meetingData['date']}\'');
      runLoop = true;
      _description = meetingData['date'];
    }
    if (meetingData['time'] != null && _time != meetingData['time']) {
      listLog.add('\nTime was updated from \'$_time\' to \'${meetingData['time']}\'');
      runLoop = true;
      _description = meetingData['time'];
    }
    if (runLoop) {
      logDescription = '$userName have updated the following details of Meeting \'$_title\':';
      for (var ele in listLog) {
        logDescription += ele;
      }
    }
    createNewLog(logDescription, false);  
  }

  @override
  Future<void> updateMeetingAttending(int state, int oldState, String title, String meetingId) async {
  // static const ATTENDING = 1;
  // static const NOT_ATTENDING = 2;
  // static const MAYBE = 3;
  // static const UNSELECTED = 0;
    String newStateString = state == 0 ? "unselected" : (state == 1 ? "attending" : (state == 2 ? "not attending" : "maybe"));
    String oldStateString = oldState == 0 ? "unselected" : (oldState == 1 ? "attending" : (oldState == 2 ? "not attending" : "maybe"));
    List _attending;
    List _maybe;
    List _notAttending;
    String logDescription;
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).get().then((value) {
      _attending = value.data['attending'];
      _maybe = value.data['maybe'];
      _notAttending = value.data['notAttending'];
    });
    if (oldState == 0) {
      logDescription = '$userName has indicated meeting status as \'$newStateString\' for Meeting \'$title\'';
      state == 1 ? _attending.add(uid) : state == 2 ? _notAttending.add(uid) : _maybe.add(uid);
    } else {
      if (state == 0 || state == oldState) {
        logDescription = '$userName has removed meeting status indication for Meeting \'$title\'';
      } else {
        logDescription = '$userName has changed meeting status indication from \'$oldStateString\' to \'$newStateString\' for Meeting \'$title\'';
        state == 1 ? _attending.add(uid) : state == 2 ? _notAttending.add(uid) : _maybe.add(uid);
      }
      oldState == 1 ? _attending.remove(uid) : oldState == 2 ? _notAttending.remove(uid) : _maybe.remove(uid);
    }
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).updateData({
      'attending': _attending,
      'maybe': _maybe,
      'notAttending': _notAttending,
    });
    createNewLog(logDescription, false);
  }

  @override
  Future<void> updateAltMeetingDetails(String altMeetingId, String title, String meetingId, Map<String, dynamic> altMeetingData) async {
    String verb = altMeetingData['acceptState'] == 1 ? "accepted" : "rejected"; 
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(altMeetingId).updateData(altMeetingData);
    String logDescription = '$userName $verb the alternative meeting date and time [${altMeetingData['date']}, ${altMeetingData['time']}] for Meeting \'$title\'';
    createNewLog(logDescription, false);
    sendSystemMsg(uid, userName, logDescription);
  }

  @override
  Future<void> acceptAltMeetingDetails(String altMeetingId, String title, String meetingId, Map<String, dynamic> meetingData) async {
    List _votes;
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(altMeetingId).get().then((value) {
      _votes = value.data['votes'];
    });
    Map<String, dynamic> newMeetingData = {
      'date': meetingData['date'],
      'time': meetingData['time'],
      'attending': _votes,
      'maybe': [],
      'notAttending': [],
      'dateSort': meetingData['dateSort'],
    };
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).updateData(newMeetingData);
  }

  @override
  Future<void> updateAltMeetingVotes(String altMeetingId, String date, String time, String title, String meetingId) async {
    bool _containUser;
    List _votes;
    int _voteCount;
    String _voted;
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(altMeetingId).get().then((value) {
      _votes = value.data['votes'];
      _voteCount = value.data['votesCount'];
      _containUser = _votes.contains(uid);
    });
    if (_containUser) {
      print('CONTAINS');
      _votes.remove(uid);
      _voteCount = _voteCount - 1;
      _voted = 'unvoted';
    } else {
      print('DOES NOT CONTAINS');
      _votes.add(uid);
      _voteCount = _voteCount + 1;
      _voted = 'voted for';
    }
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(altMeetingId).updateData({
      'votes': _votes,
      'votesCount': _voteCount,
    });
    String logDescription = '$userName $_voted alternative meeting date and time [$date, $time] for Meeting \'$title\'';
    createNewLog(logDescription, false);
  } 

  Future<void> addTaskToUser(bool add, String taskId, String title, var deadline, String state, String priority) async {
    if (add) {
      _setData('users/$uid/task/$taskId', {
        'taskId': taskId,
        'title': title,
        'deadline': deadline,
        'projectName': projectName, 
        'state': state,
        'priority': priority,
      });
      Map<String, dynamic> taskLoc = {
        "projectId": projectId,
        "taskId": taskId,
      };
      List currentTaskList = new List();
      await Firestore.instance.collection('users').document(uid).get().then((value) {
        if (value.data != null) { 
          if (value.data['task'] != null) {
            currentTaskList = value.data['task'];
          }
        }
      });
      currentTaskList.add(taskLoc);
      await Firestore.instance.collection('users').document(uid).updateData({'task': currentTaskList});
    } else {
      Firestore.instance.collection('users').document(uid).collection('task').document(taskId).delete();
      List currentTaskList = new List();
      await Firestore.instance.collection('users').document(uid).get().then((value) {
        if (value.data != null) { 
          if (value.data['task'] != null) {
            currentTaskList = value.data['task'];
          }
        }
      });
      for (var taskLocEle in currentTaskList) {
        if (taskLocEle['taskId'] == taskId) {
          currentTaskList.remove(taskLocEle);
          break;
        }
      }
      await Firestore.instance.collection('users').document(uid).updateData({'task': currentTaskList});
    }
  }

  Future<void> updateTaskToUser(String taskId, String title, var deadline, String state, String priority) async {
    bool valid = false;
    await Firestore.instance.collection('users').document(uid).collection('task').document(taskId).get().then((value) {
      if (value.data != null) { 
        valid = true;
      }
    });
    if (valid) {
      await Firestore.instance.collection('users').document(uid).collection('task').document(taskId).updateData({
        'taskId': taskId,
        'title': title,
        'deadline': deadline,
        'projectName': projectName, 
        'state': state,
        'priority': priority,
      });
    }
  }

  @override
  Future<void> updateVotes(String ideaId) async {
    print('CALL UPDATE');
    bool _containUser;
    List _votes;
    int _voteCount;
    String _voted;
    String _ideaTitle;
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).get().then((value) {
      _ideaTitle = value.data['title'];
      _votes = value.data['votes'];
      _voteCount = value.data['voteCount'];
      _containUser = _votes.contains(uid);
    });
    if (_containUser) {
      print('CONTAINS');
      _votes.remove(uid);
      _voteCount = _voteCount - 1;
      _voted = 'unvoted';
    } else {
      print('DOES NOT CONTAINS');
      _votes.add(uid);
      _voteCount = _voteCount + 1;
      _voted = 'voted for';
    }
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
      'votes': _votes,
      'voteCount': _voteCount,
    });
    String logDescription = '$userName $_voted \'$_ideaTitle\'';
    createNewLog(logDescription, false);
  }

  @override
  Future<void> updateAdminUser(List admin) async {
    await Firestore.instance.collection('projects').document(projectId).updateData({
      'admin': admin,
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
    List userUidList;
    List userNameList;
    List userImageList;
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      if (value.data != null) { 
        userUidList = value.data['userUid'];
        userNameList = value.data['userName'];
        userImageList = value.data['userImageUrl'];
      }
    });
    int uidIdx = userUidList.indexOf(_uid);
    userUidList.removeAt(uidIdx);
    userNameList.removeAt(uidIdx);
    userImageList.removeAt(uidIdx);
    await Firestore.instance.collection('projects').document(projectId).updateData({
      'userUid': userUidList,
      'userName': userNameList,
      'userImageUrl': userImageList,
    });
    await Firestore.instance.collection('projects').document(projectId).collection('users').document(_uid).delete();
    await Firestore.instance.collection('users').document(_uid).collection('projects').document(projectId).delete();
    String msg = leave ? '$_name has left this project group' : '$_name has been removed from this project group';
    sendSystemMsg(_uid, _name, msg);
    removeTaskAssignment(_uid, _name);
    removeIdeasVoting(_uid, _name);
    removeMeetingAttendance(_uid, _name);
    removeMeetingAlt(_uid, _name);
    removeProjectRelatedFields(_uid, _name);
  }

  @override
  Future<void> deleteChatMessage(String chatId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('chat').document(chatId).delete();
  }

  @override
  Future<void> deleteIdea(String ideaTitle, String ideaId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).delete();
    String logDescription = '$userName deleted Idea \'$ideaTitle\'';
    createNewLog(logDescription, false);
  }

  @override
  Future<void> deleteIdeaComment(String comment, String ideaTitle, String ideaId, String commentId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).collection('comment').document(commentId).delete();
    String logDescription = '$userName deleted comment \'$comment\' from Idea $ideaTitle';
    createNewLog(logDescription, false);  
  }

  @override
  Future<void> deleteTask(String taskName, String taskId) async {
    List assignedUid;
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).get().then((value) {
      if (value.data != null) { 
        assignedUid = value.data['assignedUid'];
      }
    });
    await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).delete();
    String logDescription = '$userName deleted Task \'$taskName\'';
    createNewLog(logDescription, true);
    if (assignedUid != null) {
      for (var ele in assignedUid) {
        Firestore.instance.collection('users').document(ele).collection('task').document(taskId).delete();
        List currentTaskList = new List();
        await Firestore.instance.collection('users').document(ele).get().then((value) {
          if (value.data != null) { 
            if (value.data['task'] != null) {
              currentTaskList = value.data['task'];
            }
          }
        });
        for (var taskLocEle in currentTaskList) {
          if (taskLocEle['taskId'] == taskId) {
            currentTaskList.remove(taskLocEle);
            break;
          }
        }
        await Firestore.instance.collection('users').document(ele).updateData({'task': currentTaskList});
      }
    }
  }

  @override
  Future<void> deleteMeeting(String meetingTitle, String meetingId) async {
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).delete();
    String logDescription = '$userName deleted Meeting \'$meetingTitle\'';
    createNewLog(logDescription, false);
    List currentMeetingList = new List();
    for (var ele in userUidList) {
      await Firestore.instance.collection('users').document(ele).get().then((value) {
        if (value.data != null) { 
          if (value.data['meeting'] != null) {
            currentMeetingList = value.data['meeting'];
          }
        }
      });
      for (var meetingLocEle in currentMeetingList) {
        if (meetingLocEle['meetingId'] == meetingId) {
          currentMeetingList.remove(meetingLocEle);
          break;
        }
      }
      await Firestore.instance.collection('users').document(ele).updateData({'meeting': currentMeetingList});
    }
  }

  @override
  Future<void> deleteMeetingAlt(String meetingTitle, String meetingId, String meetingAltId, String date, String time) async {
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(meetingAltId).delete();
    String logDescription = '$userName deleted proposed alternative meeting schedule at [$date, $time] from Meeting $meetingTitle';
    createNewLog(logDescription, false);  
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
    String description = '';
    await Firestore.instance.collection('projects').document(projectId).get().then((value) {
      description = value.data['description'];
    });
    return description;
  }
  
  Future<void> removeTaskAssignment(String id, String name) async {
    List assignListId = List();
    // List assignListName = List();
    String taskId = '';
    var results = await Firestore.instance.collection('projects').document(projectId).collection('task').where('assignedUid', arrayContains: id)
    .getDocuments();
    results.documents.forEach((element) async {
      assignListId = element.data['assignedUid'];
      // assignListName = element.data['assignedName'];
      taskId = element.data['taskId'];
      int idIdx = assignListId.indexOf(id);
      assignListId.removeAt(idIdx);
      // assignListName.removeAt(idIdx);
      await Firestore.instance.collection('projects').document(projectId).collection('task').document(taskId).updateData({
        // 'assignedName': assignListName,
        'assignedUid': assignListId,
      });
      assignListId = List();
      // assignListName = List();
      taskId = '';      
    });
    Firestore.instance.collection('users').document(id).collection('task').document(taskId).delete();
  }

  Future<void> removeIdeasVoting(String id, String name) async {
    List votesListId = List();
    int voteCount = 0;
    String ideaId = '';
    var results = await Firestore.instance.collection('projects').document(projectId).collection('idea').where('votes', arrayContains: id)
    .getDocuments();
    results.documents.forEach((element) async {
      votesListId = element.data['votes'];
      voteCount = element.data['voteCount'];
      ideaId = element.data['ideaId'];
      votesListId.remove(id);
      voteCount  = voteCount - 1;
      await Firestore.instance.collection('projects').document(projectId).collection('idea').document(ideaId).updateData({
        'voteCount': voteCount,
        'votes': votesListId,
      });
      votesListId = List();
      voteCount = 0;
      ideaId = '';      
    });    
  }

  Future<void> removeMeetingAttendance(String id, String name) async {
    List _attending = new List();
    List _maybe = new List();
    List _notAttending = new List();
    String _meetingId = "";
    var resultsA = await Firestore.instance.collection('projects').document(projectId).collection('meeting').where('attending', arrayContains: id)
    .getDocuments();
    resultsA.documents.forEach((element) async {
      _attending = element.data['attending'];
      _meetingId = element.data['meetingId'];
      _attending.remove(id);
      await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(_meetingId).updateData({
        'attending': _attending,
      });
      _attending = List();
      _meetingId = '';      
    });
    var resultsM = await Firestore.instance.collection('projects').document(projectId).collection('meeting').where('maybe', arrayContains: id)
    .getDocuments();
    resultsM.documents.forEach((element) async {
      _maybe = element.data['maybe'];
      _meetingId = element.data['meetingId'];
      _maybe.remove(id);
      await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(_meetingId).updateData({
        'maybe': _maybe,
      });
      _maybe = List();
      _meetingId = '';      
    });
    var resultsNA = await Firestore.instance.collection('projects').document(projectId).collection('meeting').where('notAttending', arrayContains: id)
    .getDocuments();
    resultsNA.documents.forEach((element) async {
      _notAttending = element.data['notAttending'];
      _meetingId = element.data['meetingId'];
      _notAttending.remove(id);
      await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(_meetingId).updateData({
        'notAttending': _notAttending,
      });
      _notAttending = List();
      _meetingId = '';      
    });
  }

  Future<void> removeMeetingAlt(String id, String name) async {
    String meetingId = '';
    String meetingAltId = '';
    var results = await Firestore.instance.collection('projects').document(projectId).collection('meeting')
    .getDocuments();
    results.documents.forEach((element) async {
      meetingId = element.data['meetingId'];
      var resultsAlt = await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').where('user', isEqualTo: id)
        .getDocuments();
      resultsAlt.documents.forEach((element) async {
        meetingAltId = element.data['meetingAltId'];
        await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').document(meetingAltId).delete();
      });  
    });    
  }

  Future<void> removeProjectRelatedFields(String id, String name) async {
    List currentTaskList = new List();
    List currentMeetingList = new List();
    await Firestore.instance.collection('users').document(id).get().then((value) {
      if (value.data != null) { 
        if (value.data['task'] != null) {
          currentTaskList = value.data['task'];
          for (var taskLocEle in List.of(currentTaskList)) {
            if (taskLocEle['projectId'] == projectId) {
              currentTaskList.remove(taskLocEle);
            }
          }
        }
        if (value.data['meeting'] != null) {
          currentMeetingList = value.data['meeting'];
          for (var meetingLocEle in List.of(currentMeetingList)) {
            if (meetingLocEle['projectId'] == projectId) {
              currentMeetingList.remove(meetingLocEle);
            }
          }
        }
      }
    });
    await Firestore.instance.collection('users').document(id).updateData({
      'task': currentTaskList,
      'meeting': currentMeetingList,
    });
  }

  Future<void> sendSystemMsg(String id, String name, String msg) async {
    String _time = DateTime.now().toString();
    await _setData('projects/$projectId/chat/$_time', {
      'name': name,
      'message': msg,
      'timesort': FieldValue.serverTimestamp(),
      'time': FieldValue.serverTimestamp(),
      'chatId': _time,
      'user': id,
      'event': true,
    });
  }

  @override
  Future<List<MeetingAlt>> meetingAltList(String meetingId) async {
    List<MeetingAlt> meetingAltList = new List();
    await Firestore.instance.collection('projects').document(projectId).collection('meeting').document(meetingId).collection('alternative').getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        MeetingAlt alt = MeetingAlt(
          meetingAltId: result.data['meetingAltId'], 
          user: result.data['user'], 
          isMeetingCreator: result.data['isMeetingCreator'], 
          votes: result.data['votes'], 
          votesCount: result.data['votesCount'], 
          date: result.data['date'], 
          time: result.data['time'],
          acceptState: result.data['acceptState'],
        );
        meetingAltList.add(alt);
      });
    });
    return meetingAltList;
  }

  @override
  Stream<List<ChatMessage>> chatStream() {
    return _collectionStream(
      path: 'projects/$projectId/chat', 
      builder: (data) => ChatMessage.fromMap(data),
      orderBy: 'timesort',
      descending: false,
    );
  }

  @override
  Stream<List<Idea>> ideaStream() {
    return _collectionStream(
      path: 'projects/$projectId/idea', 
      builder: (data) => Idea.fromMap(data),
      orderBy: 'voteCount',
      descending: true,
    );
  }

  @override
  Stream<List<IdeaComment>> ideaCommentStream(String ideaId) {
    return _collectionStream(
      path: 'projects/$projectId/idea/$ideaId/comment', 
      builder: (data) => IdeaComment.fromMap(data),
      orderBy: 'time',
      descending: false,
    );
  }

  @override
  Stream<List<TaskModel>> taskStream() {
    return _collectionStream(
      path: 'projects/$projectId/task', 
      builder: (data) => TaskModel.fromMap(data),
      orderBy: 'deadline',
      descending: false,
    );
  }

  @override
  Stream<List<TaskModel>> myTaskStream() {
    return _collectionStreamFilter(
      path: 'projects/$projectId/task', 
      builder: (data) => TaskModel.fromMap(data),
      filterBy: 'assignedUid',
      filterValue: uid,
    );
  } 

  @override
  Stream<List<MeetingModel>> meetingStream() {
    return _collectionStream(
      path: 'projects/$projectId/meeting', 
      builder: (data) => MeetingModel.fromMap(data),
      orderBy: 'dateSort',
      descending: false,
    );
  }

  @override
  Stream<List<Log>> logStream() {
    return _collectionStream(
      path: 'projects/$projectId/log', 
      builder: (data) => Log.fromMap(data),
      orderBy: 'date',
      descending: true,
    );
  }

  @override
  Stream<List<Log>> myLogStream() {
    return _collectionStreamFilterOrder(
      path: 'projects/$projectId/log', 
      builder: (data) => Log.fromMap(data),
      filterBy: 'user',
      filterValue: uid,
      orderBy: 'date',
      descending: true,    
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

  Stream<List<T>> _collectionStreamFilterOrder<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
    String filterBy,
    String filterValue,
    String orderBy,
    bool descending,
  }) {
    final reference = Firestore.instance.collection(path).where(filterBy, isEqualTo: filterValue).orderBy(orderBy, descending: descending);
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

class ChatStreamPagination {
  final String projectId;

  ChatStreamPagination({@required this.projectId});

  // static final CollectionReference _chatCollectionReference =
      // Firestore.instance.collection('projects/$projectId/chat');//aW9Ti7

  final StreamController<List<ChatMessage>> _chatController =
      StreamController<List<ChatMessage>>.broadcast();

  List<List<ChatMessage>> _allPagedResults = List<List<ChatMessage>>();

  static const int chatLimit = 10;
  DocumentSnapshot _lastDocument;
  bool _hasMoreData = true;

  Stream listenToChatsRealTime() {
    print('LISTEN TO CHAT');
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
          print('PRINT CHAT');
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