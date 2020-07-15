import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/resuable_widgets/task.dart';
import 'package:workly/screens/task_form.dart';
import 'package:workly/screens/task_view.dart';
import 'package:workly/services/project_database.dart';
import 'package:workly/models/task_model.dart';

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
_ProjectTasksMineState projectTasksMineState;

class ProjectTasksMine extends StatefulWidget {
  @override
  // _ProjectTasksMineState createState() => _ProjectTasksMineState();
  _ProjectTasksMineState createState() {
    projectTasksMineState = _ProjectTasksMineState();
    return projectTasksMineState;
  }
}

class _ProjectTasksMineState extends State<ProjectTasksMine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: _buildMyTaskList(),//Tester.test(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => goToTaskForm(),
      ),
    );
  }
  
  void goToTaskForm() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
      Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => TaskFormPage(database: database, edit: false),
    ));
  }

  void goToEditTaskForm(String taskName, String taskDescription, String taskDeadline, int taskPriority, int taskState, List taskAssignUid, String taskId, String creatorId) {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
      Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => TaskView(
        database: database, 
        taskName: taskName,
        taskDescription: taskDescription,
        taskDeadline: taskDeadline,
        taskPriority: taskPriority,
        taskState: taskState,
        // taskAssignName: taskAssignName,
        taskAssignUid: taskAssignUid,
        taskId: taskId,
        creatorId: creatorId,
      ),
    ));
  }

  Widget _buildMyTaskList() {
  final database = Provider.of<ProjectDatabase>(context, listen: false);
    return StreamBuilder<List<TaskModel>>(
      stream: database.myTaskStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final taskItem = snapshot.data;
          taskItem.sort((x,y) => x.deadlineTS.compareTo(y.deadlineTS));
          final tasks = taskItem
              .map((task) => Task(
                taskId: task.taskId, title: task.title, desc: task.description, priority: task.priority, state: task.state, deadline: task.deadline, assignedUID: task.assignedUid, toPress: () => projectTasksMineState.goToEditTaskForm(task.title, task.description, task.deadline, task.priority, task.state, task.assignedUid,task.taskId, task.uid))).toList();
          tasks.sort((y,x) => x.priority.compareTo(y.priority));
          int unassigned = 0;
          for (var ele in tasks) {
            if (ele.assignedUID.isEmpty) {
              unassigned += 1;
            }
          } 
          return TaskListConstructor(tasks: tasks, unassigned: unassigned).construct();
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: CircularProgressIndicator());
        } else {
          print("EMPTY");
          return TaskListConstructor(tasks: [], unassigned: 0).construct();//Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// class Tester {
//   static Widget test() {
//     var taskList = [
//       Task(
//         title: 'Test task 3',
//         desc: 'Test Desc 3',
//         priority: 2,
//         state: 2,
//         deadline: '28/07/2020',
//         toPress: () => null,
//       ),
//     ];
//     return TaskListConstructor(tasks: taskList).construct();
//   }
// }
