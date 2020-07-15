import 'package:flutter/material.dart';

/*
Reason that this is separately created in the reusable widgets
is because this will be used by project_tasks_all and project_tasks_mine.

[Note] this file has two classes:
- Task: to represent a single task and generate its list tile widget.
- TaskListConstructor: to construct a listview by the given tasks.

Making a new TaskListConstructor with a list of given tasks will generate a listview.
*/

class Task {
  var taskId;
  var title;
  var desc;
  var priority; //[Note] 1 - Low, 2 - Med, 3 - High
  var state; //[Note] 1 - To start, 2 - In progress, 3 - To review, 4 - Done
  var assignedUID; //[Note] unused for now
  var deadline;
  Function toPress;

  Task(
      {@required this.taskId,
      @required this.title,
      @required this.desc,
      @required this.priority,
      @required this.state,
      @required this.toPress,
      @required this.deadline,
      this.assignedUID});

  bool isState(int i) {
    return state == i;
  }

  Widget taskTile() {
    Color c;
    if (priority == 1) {
      c = Color(0xFFF8EB95);
    } else if (priority == 2) {
      c = Color(0xFFF5A76A);
    } else {
      c = Color(0xFFF56A82);
    }

    Color txtColor;
    if (priority == 1) {
      txtColor = Colors.black54;
    } else if (priority == 2) {
      txtColor = Colors.white;
    } else {
      txtColor = Colors.white;
    }

    String newTitle =
        title.length > 65 ? title.substring(0, 65) + '...' : title;
    String newDesc = desc.length > 65 ? desc.substring(0, 65) + '...' : desc;

    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(3, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: toPress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Offstage(
                          offstage: assignedUID.isNotEmpty,
                          child: Padding (
                            padding: EdgeInsets.only(
                              top: 15,
                              right: 5,
                              left: 0,
                              bottom: 3,
                            ),
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: new BoxDecoration(
                                color: Colors.lightGreenAccent[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              right: 0,
                              left: 0,
                              bottom: 3,
                            ),
                            child: Text(
                              newTitle,
                              style: TextStyle(
                                color: Color(0xFF141336),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 3,
                              right: 0,
                              left: 0,
                              bottom: 15,
                            ),
                            child: Text(
                              newDesc,
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'Roboto',
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: toPress,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        right: 10,
                        bottom: 3,
                      ),
                      child: Text(
                        'Deadline',
                        style: TextStyle(
                          color: txtColor,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 3,
                        right: 10,
                        bottom: 15,
                      ),
                      child: Text(
                        deadline,
                        style: TextStyle(
                          color: txtColor,
                          fontFamily: 'Roboto',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListConstructor {
  List<Task> tasks;
  int unassigned;

  TaskListConstructor({@required this.tasks, @required this.unassigned});

  Widget construct() {
    bool toDo = false;
    bool inProg = false;
    bool toRev = false;
    bool comp = false;

    List<Widget> widgetList = [];

    if (unassigned > 0) { 
      widgetList.add(noteTxt(
        unassigned == 1 ? "There is 1 unassigned task" : "There are $unassigned unassigned tasks"
      ));
    }

    //[Note] Generates the 'To Do' portion
    widgetList.add(titleTxt('To do'));
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isState(1)) {
        widgetList.add(SizedBox(height: 10));
        widgetList.add(tasks[i].taskTile());
        toDo = true;
      }
    }
    if (!toDo) widgetList.add(emptyTxt(1));

    //[Note] Generates the 'In Progress' portion
    widgetList.add(titleTxt('In progress'));
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isState(2)) {
        widgetList.add(SizedBox(height: 10));
        widgetList.add(tasks[i].taskTile());
        inProg = true;
      }
    }
    if (!inProg) widgetList.add(emptyTxt(2));

    //[Note] Generates the 'To Review' portion
    widgetList.add(titleTxt('To review'));
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isState(3)) {
        widgetList.add(SizedBox(height: 10));
        widgetList.add(tasks[i].taskTile());
        toRev = true;
      }
    }
    if (!toRev) widgetList.add(emptyTxt(3));

    //[Note] Generates the 'Completed' portion
    widgetList.add(titleTxt('Complete'));
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isState(4)) {
        widgetList.add(SizedBox(height: 10));
        widgetList.add(tasks[i].taskTile());
        comp = true;
      }
    }
    if (!comp) widgetList.add(emptyTxt(4));

    return ListView(
      children: widgetList,
    );
  }
}

Widget titleTxt(String s) {
  return Row(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 20, top: s == 'To do' ? 10 : 30),
        child: Text(
          s,
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 19,
          ),
        ),
      ),
      Spacer(),
    ],
  );
}

Widget emptyTxt(int state) {
  String s;
  switch (state) {
    case 1:
      s = 'You don\'t have any tasks to do!';
      break;

    case 2:
      s = 'You don\'t have any tasks in progress!';
      break;

    case 3:
      s = 'You don\'t have any tasks to review!';
      break;

    default:
      s = 'You don\'t have any complete tasks!';
      break;
  }

  return Row(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
        child: Text(
          s,
          style: TextStyle(
            color: Colors.black38,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
      Spacer(),
    ],
  );
}

Widget noteTxt(String s) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 20, top: 10),
        child: Text(
          s,
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 5, top: 10),
        child: Container(
          width: 10.0,
          height: 10.0,
          decoration: new BoxDecoration(
            color: Colors.lightGreenAccent[400],
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  );
}
