import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/screens/projectscreen_list.dart';
import 'package:workly/services/database.dart';
import 'package:workly/services/project_database.dart';
import 'dart:collection';
import 'package:workly/wrappers/navbar_wrapper.dart';
import 'package:workly/wrappers/project_tabbar_wrapper.dart';

_ProjectSwitchboardState projectSwitchboardState;
//[Note] Change to Provider system if possible

class ProjectSwitchboard extends StatefulWidget {
  final int index;

  ProjectSwitchboard({this.index});

  @override
  _ProjectSwitchboardState createState() {
    _ProjectSwitchboardState.stateIndex = this.index;
    projectSwitchboardState = _ProjectSwitchboardState();
    return projectSwitchboardState;
  }
}

class _ProjectSwitchboardState extends State<ProjectSwitchboard> with AutomaticKeepAliveClientMixin<ProjectSwitchboard> {
  static int stateIndex = 0;
  static Queue _projectHistory = Queue();
  static List<Widget> _subScreens = [
    AllProjects(),
    ProjectTabWrapper(),
  ];

  bool emptyProjectHistory() {
    return _projectHistory.length == 0;
  }

  void changeProjectScreen(int newIndex, String projectId, String projectName) async {
    final database = Provider.of<Database>(context, listen: false);
    String _uid = database.getUid();
    String _name = await database.getName();
    var _imageUrl = await database.getImageUrl();
    bool _valid = await database.runListQuery(projectId);
    List _userUidList = List();
    List _userNameList = List();
    List _userImageUrlList = List();
    // List _newUserImageUrlList = List();
    if (_valid) {
      _userUidList = database.getUserUidList();
      _userNameList = database.getUserNameList();
      _userImageUrlList = database.getUserImageUrlList();
    //   for (var ele in _userImageUrlList) {
    //     if (ele.toString() != "null") {
    //       var _image = NetworkImage(ele.toString());
    //       _newUserImageUrlList.add(_image);
    //     } else {
    //       _newUserImageUrlList.add(null);
    //     }
    //   }
    }
    // print(_newUserImageUrlList);
    setState(() {
      _addProjectHistory();
      stateIndex = newIndex;
      _subScreens = [
        AllProjects(),   
        Provider<ProjectDatabase>(
          create: (_) => FirestoreProjectDatabase(
            uid: _uid, 
            userName: _name, 
            projectId: projectId, 
            projectName: projectName,
            imageUrl: _imageUrl,
            userUidList: _userUidList,
            userNameList: _userNameList,
            userImageList: _userImageUrlList),//_newUserImageUrlList),
          child: ProjectTabWrapper(),
        ),
      ];
    });
    navState.clearLimit();
  }

  void changeToDefaultProjectScreen() {
    setState(() {
      _addProjectHistory();
      stateIndex = 0;
    });
    navState.clearLimit();
  }

  void _addProjectHistory() {
    _projectHistory.add(stateIndex);
  }

  void goBack() {
    setState(() {
      stateIndex = _projectHistory.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _subScreens[stateIndex];
  }

  @override
  bool get wantKeepAlive => true;
}
