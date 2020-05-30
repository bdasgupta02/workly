import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';

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
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListContructor.test(),
      ),
    );
  }
}

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
        desc:
            'The description is supposed to be long too!',
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
    return ListView(children: widgetList,);
  }
}

// [Note] This is just to test out the output
class Project {
  String name;
  String desc;
  String deadline;
  //list of tasks, ideas etc??

  Project({this.name, this.desc, this.deadline});

  String getName() {
    return name;
  }

  String getDesc() {
    return desc;
  }

  String getDeadline() {
    return deadline;
  }

  Widget makeWidgetTile() {
    String newDesc = desc.length > 65 ? desc.substring(0, 65) + ' ...' : desc;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      right: 10,
                      left: 17,
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
                      right: 10,
                      left: 17,
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
          Expanded(
            flex: 2,
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
        ],
      ),
    );
  }
}
