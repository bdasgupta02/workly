import 'package:flutter/material.dart';
import 'package:workly/screens/projectscreen_list.dart';
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
  static final List<Widget> _subScreens = [
    AllProjects(),
    ProjectTabWrapper(),
  ];

  bool emptyProjectHistory() {
    return _projectHistory.length == 0;
  }

  void changeProjectScreen(int newIndex) {
    setState(() {
      _addProjectHistory();
      stateIndex = newIndex;
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
