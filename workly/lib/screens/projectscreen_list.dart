import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:workly/models/user_projects.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';
import 'package:workly/screens/projectscreen_switchboard.dart';
import 'package:workly/services/database.dart';

class AllProjects extends StatefulWidget {
  @override
  _AllProjectsState createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  //[Note] Make static sub screens

  final FocusNode _projectNameFocusNode = FocusNode();
  final FocusNode _projectDescriptionFocusNode = FocusNode();
  // final FocusNode _projectDeadlineFocusNode = FocusNode();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  // final TextEditingController _projectDeadlineController =
  //     TextEditingController();
  final TextEditingController _projectCodeController = TextEditingController();
  bool _joinProject = false;
  bool _titleValid = true;
  bool _dateValid = true;
  bool _codeValid = true;
  DateTime _date;
  List<Project> _projects;
  bool _loading = false;

  bool onStart;

  @override
  void initState() {
    super.initState();
    _date = null;
    _projects = null;
    onStart = true;
  }

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    onStart ? getDocumentsList() : doNothing();
    return Scaffold(
      appBar: CustomAppbar.appBar('Projects'),
      backgroundColor: Color(0xFFE9E9E9),
      // body: Padding(
      //   padding: EdgeInsets.all(10),
      //   child: ListContructor.test(),
      // ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: _loading ? 
          _loadingScreen() : _buildProjectList(context),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.library_add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => {
          setState(() {
            _projectNameController.clear();
            _projectDescriptionController.clear();
            // _projectDeadlineController.clear();
            _projectCodeController.clear();
            _joinProject = false;
            _codeValid = true;
            _titleValid = true;
            _dateValid = true;
            _date = null;
          }),
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildProjectForm(database);
            },
            barrierDismissible: true,
          ),
        },
      ),
    );
  }

  Widget _loadingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 10,),
        Center(
          child: Text(
            _joinProject ? "Joining project..." : "Creating project...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectForm(Database database) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(48.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => {
                          Navigator.of(context).pop(),
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34.0),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: _joinProject,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _projectNameField(),
                          SizedBox(
                            height: 25,
                          ),
                          _projectDescriptionField(),
                          SizedBox(
                            height: 5,
                          ),
                          _projectDeadlineField((date) => {
                            setState(() {
                              _date = date;
                              _dateValid = true;
                            })
                          }),
                          Offstage(
                            offstage: _dateValid,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Please set a deadline",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: !_joinProject,
                      child: _projectCodeField(database),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () => {
                          if (_joinProject
                              ? _projectCode.isEmpty
                              : (_projectName.isEmpty ||
                                  _date == null))
                            {
                              print("CHECK"),
                              setState(() {
                                _codeValid = _joinProject
                                    ? _projectCode.isNotEmpty
                                    : true;
                                _titleValid = _joinProject
                                    ? true
                                    : _projectName.isNotEmpty;
                                _dateValid = _joinProject
                                    ? true
                                    : (_date != null);
                                
                              }),
                            }
                          else
                            {
                              _createProject(database),
                            }
                        },
                        child: Text(
                          _joinProject ? "Join project" : 'Create a new project',
                          style: TextStyle(
                            color: Color(0xFFFCFCFC),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        color: Color(0xFF04C9F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34.0),
                        ),
                      ),
                      decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00CFF8).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text("OR"),
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () => {
                          setState(() {
                            _joinProject = !_joinProject;
                          })
                        },
                        child: Text(
                          _joinProject
                              ? 'Create a project instead'
                              : 'Join a project instead',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }

  String get _projectName => _projectNameController.text;
  String get _projectDescription => _projectDescriptionController.text;
  // String get _projectDeadline => _projectDeadlineController.text;
  String get _projectCode => _projectCodeController.text;

  Widget _projectNameField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Project Title",
        hintText: "Title for your project",
        errorText: _titleValid ? null : "Title cannot be empty",
      ),
      controller: _projectNameController,
      textInputAction: TextInputAction.next,
      focusNode: _projectNameFocusNode,
      onChanged: (name) => _updateState(),
      onEditingComplete: () => _projectNameEditingComplete(),
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _projectDescriptionField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Project Description",
        hintText: "Description for your project",
      ),
      controller: _projectDescriptionController,
      textInputAction: TextInputAction.next,
      focusNode: _projectDescriptionFocusNode,
      onChanged: (desc) => _updateState(),
      onEditingComplete: () => _projectDescriptionEditingComplete(),
      maxLines: null,
      showCursor: true,
      maxLengthEnforced: true,
      maxLength: 300,
      textAlign: TextAlign.start,
    );
  }

  Widget _projectDeadlineField(Function setPick) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        onPressed: () {
          _pickDate(setPick);
        },
        child: Text(
          _date == null ? "Set a deadline" : "Deadline: " + _formatStringDate(_date),
          style: TextStyle(
            fontFamily: "Roboto",
            color: _date == null ? Colors.black54 : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  void _pickDate(Function setPick) async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    setPick.call(date);
  }

  Widget _projectCodeField(Database database) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Project Code",
        hintText: "Unique Project Code",
        errorText: _codeValid ? null : "Project Code cannot be empty",
      ),
      controller: _projectCodeController,
      textInputAction: TextInputAction.next,
      onChanged: (code) => _updateState(),
      onEditingComplete: () => _createProject(database),
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  void _projectNameEditingComplete() {
    final newFocus = _projectName.trim().isNotEmpty
        ? _projectDescriptionFocusNode
        : _projectNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _projectDescriptionEditingComplete() {
    _projectDescription.trim().isNotEmpty
        ? FocusScope.of(context).unfocus()
        : FocusScope.of(context).requestFocus(_projectDescriptionFocusNode);
  }

  Widget _showErrorMsg(String results) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(5.0),
        child: Text(results,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            ),
          ),
        height: 35,
      ),
    );
  }

  Future<void> _createProject(Database database) async {
    if (_joinProject) {
      print("joinproject");
      var results = await database.joinProject(_projectCode);
      if (results != 1) {
        String msg = results == 2 ? "You are already in the project" : "The project code is invalid";
        Timer timer = Timer(Duration(seconds: 3), (){
          Navigator.of(context, rootNavigator: true).pop();
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _showErrorMsg(msg);
          },
          barrierDismissible: true,
        ).then((value){
          timer?.cancel();
          timer = null;
        });
      } else {
        Navigator.of(context).pop();
      }
    } else {
      print("createproject");
      String code = generateProjectId;
      while (await database.checkCode(code)) {
        code = generateProjectId;
      }
      print(code);
      String _userName = await database.getName();
      String _userImageUrl = await database.getImageUrl();
      await database.createUserProject(code, {
        "title": _projectName,
        "code": code,
        "description": _projectDescription,
        "deadline": _convertFromDateTime(_date),
        "admin": [database.getUid(),],
        "userUid": [database.getUid(),],
        "userName": [_userName,],
        "userImageUrl": [_userImageUrl,],
      });
      Navigator.of(context).pop();
    }
    setState(() {
      onStart = true;
    });
  }

  // Timestamp _convertFromString(String date) {
  //   int indexOfSlash = date.indexOf("/");
  //   String _dd = date.substring(0, indexOfSlash);
  //   String dd = _dd.length < 2 ? "0" + _dd : _dd;
  //   int indexOfSecondSlash = date.substring(indexOfSlash + 1).indexOf("/");
  //   String _mm =
  //       date.substring(indexOfSlash + 1).substring(0, indexOfSecondSlash);
  //   String mm = _mm.length < 2 ? "0" + _mm : _mm;
  //   String _yyyy =
  //       date.substring(indexOfSlash + 1).substring(indexOfSecondSlash + 1);
  //   String yyyy = _yyyy.length == 2 ? "20" + _yyyy : _yyyy;
  //   return Timestamp.fromDate(DateTime.parse(yyyy + mm + dd));
  // }

  Timestamp _convertFromDateTime(DateTime date) {
    String _dd = date.day.toString();
    String dd = _dd.length < 2 ? "0" + _dd : _dd;
    String _mm = date.month.toString();
    String mm = _mm.length < 2 ? "0" + _mm : _mm;
    String _yyyy = date.year.toString();
    String yyyy = _yyyy.length == 2 ? "20" + _yyyy : _yyyy;
    return Timestamp.fromDate(DateTime.parse(yyyy + mm + dd));
  }

  String _formatStringDate(DateTime date) {
    String newMonth = date.month < 10 ? "0${date.month}" : "${date.month}";
    String newDay = date.day < 10 ? "0${date.day}" : "${date.day}";
    return '$newDay/$newMonth/${date.year}';
  }

  //Generate a 6digit project id
  String get generateProjectId {
    var rng = Random();
    var list = new List();
    var code = "";
    list.add(rng.nextInt(26) + 97);
    list.add(rng.nextInt(26) + 65);
    list.add(rng.nextInt(10) + 48);
    list.add(rng.nextInt(26) + 65);
    list.add(rng.nextInt(26) + 97);
    list.add(rng.nextInt(10) + 48);
    for (var numGen in list) {
      code += String.fromCharCode(numGen);
    }
    return code;
  }

  //For reading streamdata for projects
  Widget _buildProjectList(BuildContext context) {
    if (_projects == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 10,),
          Center(
            child: Text(
              "Loading projects...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    } else if (_projects.isEmpty) {
      return Center(
        child: Text(
          "Create a project or join one!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    } else {
      _projects.sort((x,y) => x.getDateTime().compareTo(y.getDateTime()));
      return ListContructor.construct(_projects);
    }

    // final database = Provider.of<Database>(context, listen: false);
    // return StreamBuilder<List<UserProjects>>(
    //     stream: database.userProjectsStream(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         final userProjects = snapshot.data;
    //         final list = userProjects
    //             .map((project) => Project(
    //                 name: project.title,
    //                 desc: project.description,
    //                 deadline: project.deadline,
    //                 projectId: project.code))
    //             .toList();
    //         return ListContructor.construct(list);
    //       } else if (snapshot.hasError) {
    //         return Center(child: Text('Error in UserProjects Stream'));
    //       } else {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //     });
  }
  
  void getDocumentsList() async {
    final database = Provider.of<Database>(context, listen: false);
    List<Map> _projectMap = await database.userProjectDocuments();
    List<Project> _projectList = new List();
    print(_projectMap);
    for (var projectEle in _projectMap) {
      Project pd = new Project(
        name: projectEle['projectTitle'], 
        projectId: projectEle['projectId'], 
        deadline: projectEle['projectDeadline'],
        desc: projectEle['projectDesc'],
      );
      _projectList.add(pd);
    }
    if (this.mounted) {
      setState(() {
        _projects = _projectList;
        onStart = false;
      });
    }
  }
}

//[Note] Constructs the list of widgets based on project objects by calling the construct() method
class ListContructor {
  static ListView test() {
    List<Project> projectList = [
      Project(
        name: 'Business Project',
        desc:
            'Making a sound business plan and coming up with a proper operational plan for our new business.',
        deadline: '17/06/2020',
      ),
      Project(
        name: 'CP2016 Project',
        desc:
            'Making a killer app that solves a lot of problems we have today.',
        deadline: '31/07/2020',
      ),
      Project(
        name: 'UTC Mod Group',
        desc:
            'Predicting real world events using mathematical and logical models.',
        deadline: '07/09/2020',
      ),
      Project(
        name: 'This is a massive title consisting of multiple lines lulz',
        desc: 'The description is supposed to be long too!',
        deadline: '20/06/2020',
      ),
    ];
    return construct(projectList);
  }

  static ListView construct(List<Project> projectList) {
    List<Widget> widgetList = [];
    for (int i = 0; i < projectList.length; i++) {
      widgetList.add(projectList[i].makeWidgetTile());
    }
    return ListView(
      children: widgetList,
    );
  }
}

// [Note] This is just to test out the output
class Project {
  String name;
  String desc;
  String deadline;
  String projectId;
  Project({this.name, this.desc, this.deadline, this.projectId});

  //[Note] This generates a SINGLE widget tile based on the project object attributes.
  // If an object is not used, can just use those 3 strings in any way possible.
  Widget makeWidgetTile() {
    String newDesc = desc.length > 65 ? desc.substring(0, 65) + '...' : desc;

    //[Placeholder] To navigate to project sub screens
    Function _goToSubScreen =
        () => projectSwitchboardState.changeProjectScreen(1, projectId, name);

    return Container(
      margin: EdgeInsets.only(right: 10, left: 10, bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
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
            flex: 8,
            child: Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: _goToSubScreen,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              right: 0,
                              left: 0,
                              bottom: 3,
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Color(0xFF141336),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                          ),
                          Padding(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: _goToSubScreen,
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
                          color: Color(0xFFFCFCFC),
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
                          color: Color(0xFFFCFCFC),
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

  DateTime getDateTime() {
    String t = deadline.substring(6, 10) + deadline.substring(3, 5) + deadline.substring(0, 2);
    return DateTime.parse(t);
  }
}
