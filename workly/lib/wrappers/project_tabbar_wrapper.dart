import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';
import 'package:workly/screens/project_chat.dart';
import 'package:workly/screens/project_ideas.dart';
import 'package:workly/screens/project_settings.dart';
import 'package:workly/services/project_database.dart';
import 'package:workly/wrappers/project_task_wrapper.dart';

class ProjectTabWrapper extends StatefulWidget {
  @override
  _ProjectTabWrapperState createState() => _ProjectTabWrapperState();
}

class _ProjectTabWrapperState extends State<ProjectTabWrapper> {
  var _index = 0;
  static final _screens = [
    ProjectChat(),
    ProjectTaskWrapper(),
    ProjectIdeas(),
    ProjectSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return Scaffold(
      backgroundColor: _index == 1 ? Color(0xFFFCFCFC) : Color(0xFFE9E9E9),
      appBar: CustomAppbar.appBarDark(database.getProjectName(),
          () => customPage(3), 3, _index), //'Project title goes here'),
      body: Column(
        children: <Widget>[
          tab(),
          Expanded(child: _screens[_index]),
        ],
      ),
    );
  }

  Widget tab() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 8),
        decoration: BoxDecoration(
          color: Color(0xFF141336),
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: customButton('Chat', 0)),
            SizedBox(width: 12),
            Expanded(child: customButton('Tasks', 1)),
            SizedBox(width: 12),
            Expanded(child: customButton('Ideas', 2)),
          ],
        ),
      ),
    );
  }

  Widget customButton(String name, int order) {
    return FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: order == _index ? Color(0xFF06D8AE) : Color(0xFFFCFCFC),
      onPressed: () => customPage(order),
      child: Padding(
        padding: EdgeInsets.only(top: 2),
        child: Text(
          name,
          style: TextStyle(
            fontFamily: 'Khula',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: order == _index ? Color(0xFFFCFCFC) : Colors.black45,
          ),
        ),
      ),
    );
  }

  void customPage(int i) {
    setState(() {
      _index = i;
    });
  }
}
