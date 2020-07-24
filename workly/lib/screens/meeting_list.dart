import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/models/meeting_model.dart';
import 'package:workly/screens/meeting_form.dart';
import 'package:workly/screens/meeting_view.dart';
import 'package:workly/services/project_database.dart';

class MeetingList extends StatefulWidget {
  @override
  _MeetingListState createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  // var meetingsTest = [
  //   MeetingTile(
  //     title: "first",
  //     desc: "desc",
  //     dateString: "25/07/2020",
  //     timeString: "17:00",
  //   ),
  //   MeetingTile(
  //     title: "second",
  //     desc: "desc desc desc desc desc desc desc desc desc desc desc desc desc desc desc desc",
  //     dateString: "25/07/2020",
  //     timeString: "10:00",
  //   ),
  //   MeetingTile(
  //     title: "third",
  //     desc: "desc",
  //     dateString: "25/07/2020",
  //     timeString: "1150",
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: _buildMeetingList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => goToMeetingForm(),
      ),
    );
  }

  void goToMeetingForm() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
      Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => MeetingFormPage(database: database),
    ));
  }

  Widget _buildMeetingList() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return StreamBuilder<List<MeetingModel>>(
      stream: database.meetingStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final meetingItem = snapshot.data;
          final meetings = meetingItem
              .map((meet) => MeetingTile(
                database: database, user: meet.user, meetingId: meet.meetingId, title: meet.title, desc: meet.description, location: meet.location, dateString: meet.date, 
                timeString: meet.time, attending: meet.attending, maybe: meet.maybe, notAttending: meet.notAttending
                )).toList();
          if (meetings.isEmpty) {
            return Center(
              child: Text(
                "No meetings created yet. \n \n Call the first meeting now",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }
          return construct(meetings);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget construct(List<MeetingTile> meetings) {
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10));
    for (int i = 0; i < meetings.length; i++) {
      widgets.add(meetings[i].toWidget(context));
    }
    return ListView(children: widgets);
  }
}

class MeetingTile {
  ProjectDatabase database;
  String user;
  String meetingId;
  String title;
  String desc;
  String location;
  String dateString;
  String timeString;
  List attending;
  List maybe;
  List notAttending;

  MeetingTile({
    @required this.database,
    @required this.user,
    @required this.meetingId,
    @required this.title,
    @required this.desc,
    @required this.location,
    @required this.dateString,
    @required this.timeString,
    @required this.attending,
    @required this.maybe,
    @required this.notAttending,
  });

  Widget toWidget(BuildContext context) {
    Function _toViewMeeting = () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MeetingView(
      database: database, user: user, meetingId: meetingId, title: title, desc: desc, location: location, dateString: dateString, 
      timeString: timeString, attending: attending, maybe: maybe, notAttending: notAttending
    )));

    String newTitle =
        title.length > 65 ? title.substring(0, 65) + '...' : title;

    return Container(
      margin: EdgeInsets.only(right: 10, left: 10, bottom: 6, top: 6),
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
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: _toViewMeeting,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
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
                              desc,
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
            flex: 3,
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
                      dateString,
                      style: TextStyle(
                        color: Color(0xFFFCFCFC),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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
                      timeString,
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
