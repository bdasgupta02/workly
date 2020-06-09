import 'package:flutter/material.dart';
import 'package:workly/screens/project_tasks_all.dart';
import 'package:workly/screens/project_tasks_mine.dart';

class ProjectTaskWrapper extends StatefulWidget {
  @override
  _ProjectTaskWrapperState createState() => _ProjectTaskWrapperState();
}

class _ProjectTaskWrapperState extends State<ProjectTaskWrapper> {
  var _index = 0;
  final _screens = [
    ProjectTasksAll(),
    ProjectTasksMine(),
  ];

  void customPage(int i) {
    setState(() {
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color(0xFFE9E9E9),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
              child: Container(
                color: Color(0xFFFCFCFC),
                padding: EdgeInsets.only(left: 50, right: 50),
                child: Row(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Expanded(child: createButton('All Tasks', 0)),
                    Container(
                      color: Colors.black45,
                      width: 1,
                      height: 10,
                    ),
                    Expanded(child: createButton('My Tasks', 1)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            _screens[_index],
          ],
        ),
      ),
    );
  }

  Widget createButton(String tab, int order) {
    return FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onPressed: () => customPage(order),
      child: Padding(
        padding: EdgeInsets.only(top: 3),
              child: Text(
          tab,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'Khula',
              fontWeight: FontWeight.w600,
              color: _index == order ? Color(0xFF141336) : Colors.black38),
        ),
      ),
    );
  }
}
