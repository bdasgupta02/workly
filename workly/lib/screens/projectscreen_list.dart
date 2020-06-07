import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/models/user_projects.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';
import 'package:workly/services/database.dart';

class AllProjects extends StatefulWidget {
  @override
  _AllProjectsState createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  //[Note] Make static sub screens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appBar('Projects'),
      backgroundColor: Color(0xFFE9E9E9),
      // body: Padding(
      //   padding: EdgeInsets.all(10),
      //   child: ListContructor.test(),
      // ),
      body: _buildContents(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add),
        onPressed: () => createProject(context)
      ),
    );
  }
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

//For creating a new project, will need to link the fields to the form, or transfer codes to the form
Future<void> createProject(BuildContext context) async {
  final database = Provider.of<Database>(context, listen: false);
  String code = generateProjectId;
  while (await database.checkCode(code)) {
    code = generateProjectId;
  }
  print(code);
  await database.createUserProject(code, {
    "name" : "test",
  });
}
//For reading streamdata for projects
Widget _buildContents(BuildContext context) {
  final database = Provider.of<Database>(context);
  return StreamBuilder<List<UserProjects>>(
    stream: database.userProjectsStream(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final userProjects = snapshot.data;
        final list = userProjects.map((project) => Project(name: project.name, desc: "TEST", deadline: "01/01/01")).toList();
        return ListContructor.construct(list);
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error in UserProjects Stream'));
      }
      return Center(child: CircularProgressIndicator());
    }
  );
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
  Project({this.name, this.desc, this.deadline});

  //[Note] This generates a SINGLE widget tile based on the project object attributes.
  // If an object is not used, can just use those 3 strings in any way possible.
  Widget makeWidgetTile() {
    String newDesc = desc.length > 65 ? desc.substring(0, 65) + ' ...' : desc;

    //[Placeholder] To navigate to project sub screens
    Function _goToSubScreen = () => null;

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
                onPressed: _goToSubScreen,
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
            ),
          ),
          Expanded(
            flex: 2,
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
}
