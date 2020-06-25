import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/resuable_widgets/member_tile.dart';
import 'package:workly/screens/task_form.dart';
import 'package:workly/services/project_database.dart';

/*
  Notes:
  -This would be navigated to by using the navigator push function.
  -I've hardcoded the placeholders. But they're almost all consolidated at the top of the state class.
  -Most data initialization is done in the state class, other than member list, which is a tester class.
 */

_TaskViewState taskViewState;

class TaskView extends StatefulWidget {
  final ProjectDatabase database;
  final String taskName;
  final String taskDescription;
  final String taskDeadline;
  final int taskPriority;
  final int taskState;
  final List taskAssignName;
  final List taskAssignUid;
  final String taskId;
  
  TaskView({
    @required this.database, 
    @required this.taskName,
    @required this.taskDescription,
    @required this.taskDeadline,
    @required this.taskPriority,
    @required this.taskState,
    @required this.taskAssignName,
    @required this.taskAssignUid,
    @required this.taskId,
  });

  @override
  // _TaskViewState createState() => _TaskViewState();
    _TaskViewState createState() {
    taskViewState = _TaskViewState();
    return taskViewState;
  }
}

class _TaskViewState extends State<TaskView> {
  //[Note] These functions link directly to the buttons below,
  //with the exception of the member tiles, which are left null in the
  //MemberTester class, since in theory it would be mostly to view the
  //members.
  String title;
  String description;
  String state;
  String deadline;
  int priority;
  List<String> _stateList;
  bool mine;
  bool resetPage = true;
  List _taskAssignName;
  List _taskAssignUid;
  //[Note]This bool value indicates if you're already assigned or not. Need to change with the "work on this task" or "leave task" buttons.
  //[Action] Need to replace this with actual data. These are hardcoded placeholders.

  @override
  Widget build(BuildContext context) {
    if (resetPage) {
      _resetPage();
    }
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 40,
                  bottom: 20,
                ),
                child: Text(
                  'View Task',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w400,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: titleDesc(),
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: columnConstructor(),
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget titleDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 5),
        textTile(title, true),
        textTile(description, false),
        SizedBox(height: 20),
      ],
    );
  }

  Widget columnConstructor() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            headingText("Options"),
            Spacer(),
          ],
        ),
        SizedBox(height: 10),
        stateControl(),
        optButton(),
        editButton(),
        SizedBox(height: 30),
        Row(
          children: <Widget>[
            headingText("Assigned to"),
            Spacer(),
          ],
        ),
        SizedBox(height: 15),
        MemberTester.constructor(_taskAssignName),
        SizedBox(height: 20),
      ],
    );
  }

  Widget stateControl() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          stateButton(false),
          Expanded(
            flex: 6,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: textStyling("State", Colors.white54),
                ),
                Text(
                  state,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          stateButton(true),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget textTile(String text, bool isTitle) {
    return Container(
      margin: EdgeInsets.only(
        top: 12,
        right: 15,
        left: 15,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: isTitle ? 20 : 15,
          fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
          color: isTitle ? Color(0xFF141336) : Colors.black54,
        ),
      ),
    );
  }

  Widget textStyling(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }

  Widget stateButton(bool upgrade) {
    int currentStateIndex = _stateList.indexOf(state) + 1;
    int upStateIndex = currentStateIndex == 4 ? 1 : currentStateIndex + 1;
    int downStateIndex = currentStateIndex == 1 ? 4 : currentStateIndex - 1;
    return Expanded(
      flex: 6,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          child: FlatButton(
            color: upgrade ? Color(0xFF06D8AE) : Colors.redAccent,
            onPressed: () => _stateUpdate(upgrade, upStateIndex, downStateIndex),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  upgrade ? Icons.arrow_right : Icons.arrow_left,
                  size: 55,
                  color: Colors.white,
                ),
                textStyling(upgrade ? _stateList[upStateIndex - 1] : _stateList[downStateIndex - 1], Colors.white),
                SizedBox(height: 10),
              ],
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: upgrade
                    ? Color(0xFF06D8AE).withOpacity(0.3)
                    : Colors.redAccent.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget optButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: mine
                ? Colors.redAccent.withOpacity(0.5)
                : Color(0xFF06D8AE).withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FlatButton(
        color: mine ? Colors.redAccent : Color(0xFF06D8AE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: () => _optUpdate(),
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              mine ? "Leave task" : "Work on this task!",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget editButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FlatButton(
        color: Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: () => _goToEditForm(),
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              "Edit task",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void _stateUpdate(bool upgrade, int upStateIndex, int downStateIndex) async {
    int newStateIndex = upgrade ? upStateIndex : downStateIndex;
    await widget.database.updateTaskDetails(widget.taskId, {
      "state": newStateIndex,
    });
    setState(() {
      state = _stateList[newStateIndex - 1];
    });
  }

  void _optUpdate() async {
    List _memberList = _taskAssignName;
    List _memberListId = _taskAssignUid;
    if (mine) {
      //leave
      _memberListId.remove(widget.database.getUid());
      _memberList.remove(widget.database.getUserName());
      await widget.database.updateTaskDetails(widget.taskId, {
          "assignedUid": _memberListId,
          "assignedName": _memberList,
        });
    } else {
      //join
      _memberListId.add(widget.database.getUid());     
      _memberList.add(widget.database.getUserName()); 
      await widget.database.updateTaskDetails(widget.taskId, {
          "assignedUid": _memberListId,
          "assignedName": _memberList,
      });
    }
    setState(() {
      _taskAssignName = _memberList;
      _taskAssignUid = _memberListId;
      mine = _memberListId.contains(widget.database.getUid());
    });
  }

  void _goToEditForm() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => TaskFormPage(
        database: widget.database, 
        edit: true,
        taskName: title,
        taskDescription: description,
        taskDeadline: deadline,
        taskPriority: priority,
        // taskState: taskState,
        // taskAssign: taskAssign,
        taskId: widget.taskId,
        refresh: refresh,
      ),
    ));
  }

  void refresh(String newTitle, String newDescription, String newDeadline, int newPriority) {
    setState(() {
      title = newTitle;
      description = newDescription;
      deadline = newDeadline;
      priority = newPriority;
    });
  }

  void delete() {
    print("Call delete 2");
    Navigator.of(context).pop();
  }

  void _resetPage() {
    List<String> newStateList = <String>[
    "To do",
    "In progress",
    "To review",
    "Completed"
    ];
    setState(() {
      title = widget.taskName;
      description = widget.taskDescription;
      state = newStateList[widget.taskState - 1];
      deadline = widget.taskDeadline;
      priority = widget.taskPriority;
      _stateList = newStateList;
      mine = widget.taskAssignUid.contains(widget.database.getUid());
      resetPage = false;
      _taskAssignName = widget.taskAssignName;
      _taskAssignUid = widget.taskAssignUid;
    });
  }
}

class MemberTester {
  // static Widget testMemberTiles() {
  //   List<Member> members = [
  //     Member(name: 'Test name', image: null),
  //     Member(name: 'Second test name', image: null),
  //     Member(name: 'Third test name', image: null),
  //   ];
  //   return constructor(members);
  // }

  static Widget constructor(List members) {
    if (members.isNotEmpty) {
      List<Widget> memberWidgets = [];
      for (int i = 0; i < members.length; i++) {
        memberWidgets.add(Member(name: members[i], image: null).makeMemberTile(null, true));
      }
      return Column(
        children: memberWidgets,
      );
    } else {
      return Center(
        child: Text(
          "No members working on it yet",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
  }
}
