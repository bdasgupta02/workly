import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/task.dart';

/*
This class has a Tester class to test a few Tasks for the list.

Things to keep in mind:
- Each Task has a toPress field which is a function for onPressed action 
  for the tiles.
- Can centralize onPressed on the Task class itself if all tiles have the same
  function in both project_tasks_all and project_tasks_mine
- Both project_tasks_all and project_tasks_mine use the same Task class for 
  widget generation. Just gotta pass a list of tasks as seen from the Tester.
*/
class ProjectTasksMine extends StatefulWidget {
  @override
  _ProjectTasksMineState createState() => _ProjectTasksMineState();
}

class _ProjectTasksMineState extends State<ProjectTasksMine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: Tester.test(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => null,
      ),
    );
  }
}

class Tester {
  static Widget test() {
    var taskList = [
      Task(
        title: 'Test task 3',
        desc: 'Test Desc 3',
        priority: 2,
        state: 2,
        toPress: () => null,
      ),
    ];
    return TaskListConstructor(tasks: taskList).construct();
  }
}
