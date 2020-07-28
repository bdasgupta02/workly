import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workly/index.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';
import 'package:workly/services/database.dart';
import 'package:intl/intl.dart';

import '../local_noti.dart';


class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _deadlines;
  List<dynamic> _selectedDeadlines;
  bool _start;
  List<ProjectDeadline> _projectsList;
  bool onStart;
  bool setNoti;
  static LocalNotification _localNoti = new LocalNotification();

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _deadlines = {};
    _selectedDeadlines = [];
    _start = true;
    _projectsList = null;
    onStart = true;
    setNoti = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDeadlineList(BuildContext context) {
    // final database = Provider.of<Database>(context, listen: false);
    _deadlines.clear();
    if (_projectsList == null || _projectsList.isEmpty) {
      return _bodyConstruct([]);
    } else {
      return _bodyConstruct(_projectsList);
    }
    // return StreamBuilder<List<UserProjects>>(
    //     stream: database.userProjectsStream(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         _deadlines.clear();
    //         final userProjects = snapshot.data;
    //         final list = userProjects
    //             .map((project) => ProjectDeadline(
    //                 title: project.title,
    //                 date: _convert(project.deadline),
    //                 id: project.code))
    //             .toList();
    //         return _bodyConstruct(list);
    //       } else if (snapshot.hasError) {
    //         return Center(child: CircularProgressIndicator());
    //       } else {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //     });
  }

  void doNothing() {}

  void getDocumentsList() async {
    final database = Provider.of<Database>(context, listen: false);
    List<Map> _task = await database.userTaskDocuments();
    print("Calendar DB pull task: " + _task.toString());
    List<ProjectDeadline> projects = new List();
    for (var taskEle in _task) {
      ProjectDeadline pd = new ProjectDeadline(
        title: taskEle['projectTitle'],
        id: taskEle['projectId'],
        date: _convert(taskEle['taskDeadline']),
        type: 2,
        subtypeTitle: taskEle['taskTitle'],
        subtypeId: taskEle['taskId'],
        details: null,
        time: null,
      );
      projects.add(pd);
    }
    if (this.mounted) {
      setState(() {
        _projectsList = projects;
      });
    }
    List<Map> _meeting = await database.userMeetingDocuments();
    print("Calendar DB pull meeting: " + _meeting.toString());
    for (var meetingEle in _meeting) {
      ProjectDeadline pd = new ProjectDeadline(
        title: meetingEle['projectTitle'],
        id: meetingEle['projectId'],
        date: _convert(meetingEle['meetingDate']),
        type: 3,
        subtypeTitle: meetingEle['meetingTitle'],
        subtypeId: meetingEle['meetingId'],
        details: meetingEle['attendance'],
        time: meetingEle['meetingTime'],
      );
      if (meetingEle['attendance'] != "notAttending") {
        projects.add(pd);
      }
    }
    if (this.mounted) {
      setState(() {
        _projectsList = projects;
      });
    }
    List<Map> _project = await database.userProjectDocuments();
    print("Calendar DB pull project: " + _project.toString());
    for (var projectEle in _project) {
      ProjectDeadline pd = new ProjectDeadline(
        title: projectEle['projectTitle'],
        id: projectEle['projectId'],
        date: _convert(projectEle['projectDeadline']),
        type: 1,
        subtypeTitle: null,
        subtypeId: null,
        details: null,
        time: null,
      );
      projects.add(pd);
    }
    if (this.mounted) {
      setState(() {
        _projectsList = projects;
        onStart = false;
        setNoti = true;
      });
    }
  }
  
  DateTime _convert(String s) {
    String t = s.substring(6, 10) + s.substring(3, 5) + s.substring(0, 2);
    return DateTime.parse(t);
  }

  void setLocalNoti() async {
    _localNoti.configLocalNotification();
    await _localNoti.cancelNoti(null);
    for (var ele in _projectsList) {
      print("Calendar Local Noti scheduling [${_projectsList.indexOf(ele)}]");
      String _dd = ele.date.day < 10 ? '0' + ele.date.day.toString() : ele.date.day.toString();
      String _mm = ele.date.month < 10 ? '0' + ele.date.month.toString() : ele.date.month.toString();
      String _yyyy = ele.date.year.toString();
      String _date = _yyyy + _mm + _dd;
      String _hr = ele.time != null ? ele.time.substring(0,2) : "00";
      String _min = ele.time != null ? ele.time.substring(3,5) : "00";
      String _title = "Workly • ${ele.title}";
      String _body1;
      String _body2;
      String _body3;
      DateTime _now = DateTime.now();
      DateTime _newDateTime1;
      DateTime _newDateTime2;
      DateTime _newDateTime3;
      if (ele.type == 1) {
        _body1 = "Project is due next week $_dd/$_mm/$_yyyy";
        _body2 = "Project is due tomorrow";
        _body3 = "Project is due today";
        _newDateTime1 = DateTime.parse(_date + "T" + "120000").subtract(Duration(days: 7));
        _newDateTime2 = DateTime.parse(_date + "T" + "153000").subtract(Duration(days: 1));
        _newDateTime3 = DateTime.parse(_date + "T" + "153000").subtract(Duration(days: 0));
      } else if (ele.type == 2) {
        _body1 = "Task '${ele.subtypeTitle}' is due in 3 days";
        _body2 = "Task '${ele.subtypeTitle}' is due tomorrow";
        _body3 = "Task '${ele.subtypeTitle}' is due today";
        _newDateTime1 = DateTime.parse(_date + "T" + "120000").subtract(Duration(days: 3));
        _newDateTime2 = DateTime.parse(_date + "T" + "153000").subtract(Duration(days: 1));
        _newDateTime3 = DateTime.parse(_date + "T" + "153000").subtract(Duration(days: 0));
      } else if (ele.type == 3) {
        _body1 = "Meeting '${ele.subtypeTitle}' tomorrow at ${ele.time}";
        _body2 = "Meeting '${ele.subtypeTitle}' in 15 mins";
        _body3 = "Meeting '${ele.subtypeTitle}' starting now";
        _newDateTime1 = DateTime.parse(_date + "T" + "153000").subtract(Duration(days: 1));
        _newDateTime2 = DateTime.parse(_date + "T" + _hr + _min + "00").subtract(Duration(minutes: 15));
        _newDateTime3 = DateTime.parse(_date + "T" + _hr + _min + "00");
      } else {
        continue;
      }
      if (_newDateTime1.compareTo(_now) >= 0) {
        _localNoti.setScheduledNotification(id: _projectsList.indexOf(ele), title: _title, body: _body1, dateTime: _newDateTime1);
      } else if (_newDateTime2.compareTo(_now) >= 0) {
        _localNoti.setScheduledNotification(id: _projectsList.indexOf(ele) + 100, title: _title, body: _body2,  dateTime: _newDateTime2);
      } else if (_newDateTime3.compareTo(_now) >= 0) {
        _localNoti.setScheduledNotification(id: _projectsList.indexOf(ele) + 1000, title: _title, body: _body3,  dateTime: _newDateTime3);
      } else {
        continue;
      }
    }
    if (this.mounted) {
      setState(() {
        setNoti = false;
      });
    }
  }

  void _toMap(List<ProjectDeadline> projects) {
    for (int i = 0; i < projects.length; i++) {
      if (_deadlines[projects[i].getDate()] == null) {
        List<String> l = [projects[i].getMsg()];
        _deadlines[projects[i].getDate()] = l;
      } else {
        _deadlines[projects[i].getDate()].add(projects[i].getMsg());
      }
    }
  }

  Widget _listConstructor(List<ProjectDeadline> projects) {
    _toMap(projects);
    if (_start &&
        _deadlines[DateTime.parse(
                DateFormat('yyyyMMdd').format(DateTime.now()))] !=
            null) {
      _selectedDeadlines = _deadlines[
          DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now()))];
      _start = false;
    }
    List<Widget> widgets = [];
    for (int i = 0; i < _selectedDeadlines.length; i++) {
      if (i == 0) {
        widgets.add(Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Text(
                  'Deadlines:',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ));
      }
      widgets.add(Row(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              child: Text(
                _selectedDeadlines[i],
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ));
      if (i == _selectedDeadlines.length - 1) {
        widgets.add(SizedBox(height: 30));
      }
    }

    if (_selectedDeadlines.length == 0) {
      widgets.add(Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: 30,
            left: 20,
            right: 20,
            bottom: 30,
          ),
          child: Text(
            'You don\'t have anything due on this day!',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ));
    }

    return Column(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    onStart ? getDocumentsList() : doNothing();
    setNoti ? setLocalNoti() : doNothing();
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: CustomAppbar.appBar('Calendar'),
      body: _buildDeadlineList(context),
    );
  }

  Widget _bodyConstruct(List<ProjectDeadline> bottom) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(3),
              child: TableCalendar(
                //TODO: This _deadlines object has a Map of DateTimes matching with a list of events.
                //Adding to these deadlines would show the dates.
                //Few things to note:
                //- Make sure the deadline for the current day load on the start of this page.
                //  Reason I'm saying this is because they could need a refresh instead of loading automatically on start, which is bad.
                //- Need to change a bit of UI if we want to add more data inputs, because now it just says "project deadlines:"
                //  But this would take max 1hr.
                //- Is it possible to query instead of streambuilder?
                events: _deadlines,
                calendarStyle: CalendarStyle(
                  todayColor: Color(0xFFE9E9E9),
                  selectedColor: Color(0xFF04C9F1),
                  todayStyle: TextStyle(),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                ),
                calendarController: _controller,
                onDaySelected: (date, deadlines) {
                  setState(() {
                    _selectedDeadlines = deadlines;
                  });
                },
              ),
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            _listConstructor(bottom),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFF141336),
          borderRadius: BorderRadius.all(Radius.circular(30)),
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
    );
  }
}

class ProjectDeadline {
  String id;
  String title;
  DateTime date;
  String subtypeTitle; //Only applicable to type 2,3
  String subtypeId; //Only applicable to type 2,3
  String time; //Only applicable to type 3
  String details; //Only applicable to type 3
  int type; //1: Project, 2: Task, 3: Meeting

  ProjectDeadline({
    @required this.id,
    @required this.title,
    @required this.date,
    @required this.subtypeTitle,
    @required this.subtypeId,
    @required this.time,
    @required this.details,
    @required this.type,
  });

  DateTime getDate() {
    return this.date;
  }

  String getMsg() {
    if (type == 1) {
      return '• The project "$title" is due on this day.';
    } else if (type == 2) {
      return '• The task "$subtypeTitle" for project "$title" is due on this day.';
    } else {
      return '• Meeting "$subtypeTitle" for project "$title" at $time [RSVP: $details].';
    }
  }
}
