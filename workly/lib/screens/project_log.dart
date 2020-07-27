import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:workly/models/log.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/project_database.dart';

_ProjectLogState projectLogState;

//TODO: List pagination

class ProjectLog extends StatefulWidget {
  final ProjectDatabase database;

  ProjectLog({@required this.database});

  @override
  _ProjectLogState createState() {
    projectLogState = _ProjectLogState();
    return projectLogState;
  }
}

class _ProjectLogState extends State<ProjectLog> {
  bool mine = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141336),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFFCFCFC),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 10),
            child: Container(
              decoration: BoxDecoration(
                color: mine ? Color(0xFF06D8AE) : Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: FlatButton.icon(
                label: Text(
                  "Show my logs",
                  style: TextStyle(color: mine ? Color(0xFFFCFCFC) : Colors.black45)),
                icon: Icon(
                  Icons.check_circle_outline,
                  color: mine ? Color(0xFFFCFCFC) : Colors.black45,
                ),
                onPressed: () => {
                  setState(() {
                    mine = !mine;
                  })
                },
              )
            )
          ) 
        ],
      ),
      backgroundColor: Color(0xFFE9E9E9),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          ClippedHeader(),
          // Tester.test(),
          _buildLogList(),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    print("called");
    return StreamBuilder<List<Log>>(
      stream: mine ? widget.database.myLogStream() : widget.database.logStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final logItem = snapshot.data;
          final logs = logItem
              .map((log) => LogTile(date: log.date, task: log.task, userName: log.name, description: log.description)).toList();
          if (logs.isEmpty) {
            return Center(
              child: Text(
                "No logs for this project...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }
          return makeList(logs);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget makeList(List logs) {
    List<Widget> list = [];
    list.add(SizedBox(height: 20));
    for (LogTile i in logs) {
      list.add(i.makeLogTile());
    }
    return ListView(children: list);
  }
}

//[Note] This class is only to generate the tiles for this list.
// We should make this class outside if we want to extend this to other screens.
class LogTile {
  var date;
  var userName;
  var description;
  var task;

  LogTile(
      {@required this.date,
      @required this.userName,
      @required this.description,
      @required this.task});

  Widget makeLogTile() {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10, bottom: 5),
      decoration: BoxDecoration(
        color: task ? Colors.orange[800] : Colors.greenAccent[400],
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
            flex: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 10,
                            left: 10,
                            bottom: 3,
                          ),
                          child: Text(
                            "Date: " + date,
                            style: TextStyle(
                              color: Color(0xFF141336),
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 10,
                            left: 10,
                            bottom: 3,
                          ),
                          child: Text(
                            "User: " + userName,
                            style: TextStyle(
                              color: Color(0xFF141336),
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
                            right: 10,
                            left: 10,
                            bottom: 10,
                          ),
                          child: Text(
                            description,
                            style: TextStyle(
                              color: Colors.black45,
                              fontFamily: 'Roboto',
                              fontSize: 10,
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
          Expanded(
            flex: 2,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}

class Tester {
  static Widget test() {
    var logs = [
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test2 have created a new task: Add project logs", date: "10/10/2010", task: false),
      LogTile(userName:"A", description: "TESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING TESTINGTESTING", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
      LogTile(userName:"A", description: "Test1 have added a new idea: Project logs", date: "10/10/2010", task: true),
    ];
    return projectLogState.makeList(logs);
  }
}