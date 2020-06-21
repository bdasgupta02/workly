import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/project_database.dart';

class TaskFormPage extends StatelessWidget {
  final ProjectDatabase database;
  final bool edit;
  final String taskName;
  final String taskDescription;
  final String taskDeadline;
  final int taskPriority;
  final int taskState;
  final String taskAssign;
  final String taskId;

  TaskFormPage({
    @required this.database, 
    @required this.edit,
    this.taskName,
    this.taskDescription,
    this.taskDeadline,
    this.taskPriority,
    this.taskState,
    this.taskAssign,
    this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 50,
                  bottom: 10,
                ),
                child: Text(
                  edit ? 'Edit Task' : 'Task Creation',
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
                //[Note] Now it's at the center of the screen which automatically gets lifted by a keyboard
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      child: TaskForm(
                        database: database, 
                        edit: edit,
                        taskName: taskName,
                        taskDescription: taskDescription,
                        taskDeadline: taskDeadline,
                        taskPriority: taskPriority,
                        taskState: taskState,
                        taskAssign: taskAssign,
                        taskId: taskId,
                        ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFFE9E9E9), //[Action needed] Update colour
    );
  }
}

_TaskFormState taskFormState;

class TaskForm extends StatefulWidget {
  final ProjectDatabase database;
  final bool edit;
  final String taskName;
  final String taskDescription;
  final String taskDeadline;
  final int taskPriority;
  final int taskState;
  final String taskAssign;
  final String taskId;

  TaskForm({
    @required this.database, 
    @required this.edit,
    this.taskName,
    this.taskDescription,
    this.taskDeadline,
    this.taskPriority,
    this.taskState,
    this.taskAssign,
    this.taskId,
  });

  @override
  _TaskFormState createState() {
    taskFormState = _TaskFormState();
    return taskFormState;
  }
}

class _TaskFormState extends State<TaskForm> {
  final FocusNode _taskNameFocusNode = FocusNode();
  final FocusNode _taskDescriptionFocusNode = FocusNode();
  final FocusNode _taskDeadlineFocusNode = FocusNode();
  final FocusNode _taskPriorityFocusNode = FocusNode();
  final FocusNode _taskStateFocusNode = FocusNode();
  final FocusNode _taskAssignFocusNode = FocusNode();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  final TextEditingController _taskDeadlineController = TextEditingController();
  bool _taskNameValid = true;
  bool _taskDescValid = true;
  bool _dateValid = true;
  bool _formValid = true;
  bool _priorityValid = true;
  bool _stateValid = true;
  bool _assignValid = true;
  String _priority;
  String _state;
  String _assign;
  String _taskId;
  List<String> _priorityList = <String>["Low", "Medium", "High"];
  List<String> _stateList = <String>[
    "To do",
    "In progress",
    "To review",
    "Completed"
  ];
  List<String> _userNameList;
  List<String> _userUidList;
  List<DropdownMenuItem<String>> _userList;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _taskDeadlineController.dispose();
    _taskNameFocusNode.dispose();
    _taskDescriptionFocusNode.dispose();
    _taskPriorityFocusNode.dispose();
    _taskStateFocusNode.dispose();
    _taskAssignFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getUserList();
    if (widget.edit) {
      setStateEdit();
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildForm(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      _taskNameField(),
      SizedBox(height: 10.0),
      _taskDescriptionField(),
      SizedBox(height: 10.0),
      _taskDeadlineField(),
      SizedBox(height: 10.0),
      _taskPriorityField(),
      Offstage(
        offstage: _priorityValid,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left:10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height:8.0),
              Text("Please select a priority level", 
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 10.0),
      _taskStateField(),
      Offstage(
        offstage: _stateValid,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left:10),
          child: Column(
            children: <Widget>[
              SizedBox(height:8.0),
              Text("Please select a State", 
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 10.0),
      _taskAssignField(),
      Offstage(
        offstage: _assignValid,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left:10),
          child: Column(
            children: <Widget>[
              SizedBox(height:8.0),
              Text("Please select a person", 
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: OutlineButton(
              borderSide: BorderSide(color: Color(0xFF31BCD8)),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF31BCD8),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
              onPressed: () => {
                Navigator.of(context).pop(),
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF33CFEE).withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: FlatButton(
                child: Text(
                  widget.edit ? "Save" : "Create Task",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                color: Color(0xFF04C9F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(24.0),
                  ),
                ),
                onPressed: () => _addTask(),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height:5,),
      Offstage(
        offstage: !widget.edit,
        child: FlatButton.icon(
          color: Colors.red,
          icon: Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
          label: Text(
            "Delete",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => _deleteTask(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
        ),
      ),
    ];
  }

  void setStateEdit() {
    int priorityIndex = widget.taskPriority - 1;
    int stateIndex = widget.taskState - 1;
    setState(() {
      _taskTitleController.text = widget.taskName;
      _taskDescriptionController.text = widget.taskDescription;
      _taskDeadlineController.text = widget.taskDeadline;
      _priority = _priorityList[priorityIndex];
      _state = _stateList[stateIndex];
      _assign = widget.taskAssign;
      _taskId = widget.taskId;
    });
  }

  void checkFormValid() {
    bool _valid = (_taskTitle.isNotEmpty) &&
        (_taskDescription.isNotEmpty) &&
        (_taskDeadline.isNotEmpty && _taskDeadline.contains("/")) &&
        (_priority != null) &&
        (_state != null) &&
        (_assign != null);
    setState(() {
      _taskNameValid = _taskTitle.isNotEmpty;
      _taskDescValid = _taskDescription.isNotEmpty;
      _dateValid = _taskDeadline.isNotEmpty && _taskDeadline.contains("/");
      _formValid = _valid;
      _priorityValid = _priority != null;
      _stateValid = _state != null;
      _assignValid = _assign != null;
    });
  }

  void _addTask() async {
    checkFormValid();
    if (_formValid) {
      print("VALID");
      String newTaskId = DateTime.now().toString();
      int userIndex = _userNameList.indexOf(_assign);
      int priorityIndex = _priorityList.indexOf(_priority) + 1;
      int stateIndex = _stateList.indexOf(_state) + 1;
      if (widget.edit) {
        await widget.database.updateTaskDetails(_taskId, {
          "name": widget.database.getUserName(),
          "uid": widget.database.getUid(),
          "assignedUid": _userUidList[userIndex],
          "assignedName": _assign,
          "title": _taskTitle,
          "description": _taskDescription,
          "taskId": _taskId,
          "priority": priorityIndex,
          "state": stateIndex,
          "deadline": _convertFromString(_taskDeadline),
        });
      } else {
        await widget.database.createTask(newTaskId, {
          "name": widget.database.getUserName(),
          "uid": widget.database.getUid(),
          "assignedUid": _userUidList[userIndex],
          "assignedName": _assign,
          "title": _taskTitle,
          "description": _taskDescription,
          "taskId": newTaskId,
          "priority": priorityIndex,
          "state": stateIndex,
          "deadline": _convertFromString(_taskDeadline),
        });
      }
      Navigator.of(context).pop();
    } else {
      print("INVALID");
    }
  }

  void _deleteTask() async {
    await widget.database.deleteTask(_taskId);
    Navigator.of(context).pop();
  }

  Timestamp _convertFromString(String date) {
    int indexOfSlash = date.indexOf("/");
    String _dd = date.substring(0, indexOfSlash);
    String dd = _dd.length < 2 ? "0" + _dd : _dd;
    int indexOfSecondSlash = date.substring(indexOfSlash + 1).indexOf("/");
    String _mm =
        date.substring(indexOfSlash + 1).substring(0, indexOfSecondSlash);
    String mm = _mm.length < 2 ? "0" + _mm : _mm;
    String _yyyy =
        date.substring(indexOfSlash + 1).substring(indexOfSecondSlash + 1);
    String yyyy = _yyyy.length == 2 ? "20" + _yyyy : _yyyy;
    return Timestamp.fromDate(DateTime.parse(yyyy + mm + dd));
  }

  void _updateState() {
    setState(() {});
  }

  String get _taskTitle => _taskTitleController.text;
  String get _taskDescription => _taskDescriptionController.text;
  String get _taskDeadline => _taskDeadlineController.text;

  Widget _taskNameField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Task title",
        hintText: "Title of your task",
        errorText: _taskNameValid ? null : "Please fill in a title",
      ),
      controller: _taskTitleController,
      textInputAction: TextInputAction.next,
      focusNode: _taskNameFocusNode,
      onChanged: (name) => _updateState(),
      onEditingComplete: () => _taskNameEditingComplete(),
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _taskDescriptionField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Task Description",
        hintText: "Description of your task",
        errorText: _taskDescValid ? null : "Please fill in some description",
      ),
      controller: _taskDescriptionController,
      textInputAction: TextInputAction.next,
      focusNode: _taskDescriptionFocusNode,
      onChanged: (desc) => _updateState(),
      onEditingComplete: () => _taskDescEditingComplete(),
      maxLines: null,
      showCursor: true,
      maxLengthEnforced: true,
      // maxLength: 500,
      textAlign: TextAlign.start,
    );
  }

  Widget _taskDeadlineField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Task Deadline",
        hintText: "DD/MM/YYYY",
        errorText:
            _dateValid ? null : "Please enter in this format: DD/MM/YYYY",
      ),
      controller: _taskDeadlineController,
      textInputAction: TextInputAction.next,
      focusNode: _taskDeadlineFocusNode,
      onChanged: (date) => _updateState(),
      onEditingComplete: () => _taskDeadlineEditingComplete(),
      keyboardType: TextInputType.datetime,
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _taskPriorityField() {
    return Container(
      padding: EdgeInsets.only(left: 15),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: _priorityValid ? Colors.black38 : Colors.red[400]),
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text("Priority: ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  focusNode: _taskPriorityFocusNode,
                  hint: Text("Task Priority Level"),
                  value: _priority,
                  onChanged: (selected) {
                    setState(() {
                      _priority = selected;
                    });
                    FocusScope.of(context).requestFocus(_taskStateFocusNode);
                  },
                  items: _priorityList.map((value) {
                    return DropdownMenuItem(
                      child: new Text(value, style: TextStyle(fontSize: 16)),
                      value: value,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskStateField() {
    return Container(
      padding: EdgeInsets.only(left: 15),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side:
              BorderSide(color: _stateValid ? Colors.black38 : Colors.red[400]),
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text("State: ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  focusNode: _taskStateFocusNode,
                  hint: Text("Task State"),
                  value: _state,
                  onChanged: (selected) {
                    print("SETSTATE");
                    setState(() {
                      _state = selected;
                    });
                    FocusScope.of(context).requestFocus(_taskAssignFocusNode);
                  },
                  items: _stateList.map((value) {
                    return DropdownMenuItem(
                      child: new Text(value, style: TextStyle(fontSize: 16)),
                      value: value,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskAssignField() {
    return Container(
      padding: EdgeInsets.only(left: 15),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: _assignValid ? Colors.black38 : Colors.red[400]),
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text("Assign to: ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  focusNode: _taskAssignFocusNode,
                  hint: Text("Person Doing"),
                  value: _assign,
                  onChanged: (selected) {
                    setState(() {
                      _assign = selected;
                    });
                  },
                  items: _userList,
                  // _userList.map((value) {
                  //   return DropdownMenuItem(
                  //     child: new Text(value, style: TextStyle(fontSize: 16)),
                  //     value: value,
                  //   );
                  // }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _taskNameEditingComplete() {
    final newFocus = _taskTitle.trim().isNotEmpty
        ? _taskDescriptionFocusNode
        : _taskNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
    setState(() {
      _taskNameValid = _taskTitle.trim().isNotEmpty;
    });
  }

  void _taskDescEditingComplete() {
    final newFocus = _taskDescription.trim().isNotEmpty
        ? _taskDeadlineFocusNode
        : _taskDescriptionFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
    setState(() {
      _taskDescValid = _taskDescription.trim().isNotEmpty;
    });
  }

  void _taskDeadlineEditingComplete() {
    final newFocus =
        (_taskDeadline.trim().isNotEmpty && _taskDeadline.contains("/"))
            ? _taskPriorityFocusNode
            : _taskDeadlineFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
    setState(() {
      _dateValid =
          (_taskDeadline.trim().isNotEmpty && _taskDeadline.contains("/"));
    });
  }

  void getUserList() async {
    List<Map<String, String>> userMapList = await widget.database.getUserList();
    List<String> userListName = List<String>();
    List<String> userListUid = List<String>();
    for (var ele in userMapList) {
      userListName.add(ele["name"].toString());
      userListUid.add(ele["uid"].toString());
    }
    List<DropdownMenuItem<String>> userList = userListName.map((value) {
      return DropdownMenuItem(
        child: new Text(value, style: TextStyle(fontSize: 16)),
        value: value,
      );
    }).toList();
    if (mounted) {
      setState(() {
        _userList = userList;
        _userNameList = userListName;
        _userUidList = userListUid;
      });
    }
  }
}