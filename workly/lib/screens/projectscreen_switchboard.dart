import 'package:flutter/material.dart';
import 'package:workly/screens/projectscreen_all.dart';
import 'package:workly/screens/projectscreen_deadlines..dart';
import 'package:workly/screens/projectscreen_due_soon.dart';

class ProjectSwitchboard extends StatefulWidget {
  final int index;

  ProjectSwitchboard({this.index});

  @override
  _ProjectSwitchboardState createState() => _ProjectSwitchboardState(index: this.index);
}

class _ProjectSwitchboardState extends State<ProjectSwitchboard> {
  final int index;
  static final List<Widget> _subScreens = [
    AllProjects(),
    MissedDeadlines(),
    DueSoon(),
  ];

  _ProjectSwitchboardState({this.index});

  @override
  Widget build(BuildContext context) {
    return _subScreens[index];
  }
}
