import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workly/models/meeting_alt.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/project_database.dart';

/*
IMPORTANT Notes:
- Can store date and time values in the form of string (with toString() method for DateTime and TimeOfDay) and parse it 
  with flutter methods when quering it from the DB.
- Exactly the same style as idea view page, with visual changes.
- Most attributes are on the top of each class, but I've marked "TODO" where it's inside a method.
- I've changed the alternatives to a voting system instead of a "attending" system, because it's more
  straightforward and easier to understand than a nested meeting system. The original meeting creator can
  edit the meeting to another one if needed. This is a good UX idea imo.
- Same query for the meeting (top) card and streambuilder for alternative (bottom) card would work amazingly.

How it works:
Meeting class - Represents the first card with the meeting details, edit and delete buttons, and the attending board.
Alternative class - Displays the alternatives and includes a date picker to give your own alternative. Allows voting.
 */
_MeetingViewState meetingViewState;

class MeetingView extends StatefulWidget {
  final String meetingId;
  final String user;
  final String title;
  final String desc;
  final String location;
  final String dateString;
  final String timeString;
  final List attending;
  final List maybe;
  final List notAttending;
  final ProjectDatabase database;

  MeetingView({
    @required this.database,
    @required this.meetingId,
    @required this.user,
    @required this.title,
    @required this.desc,
    @required this.location,
    @required this.dateString,
    @required this.timeString,
    @required this.attending,
    @required this.maybe,
    @required this.notAttending,
  });

  @override
  _MeetingViewState createState() {
    meetingViewState = _MeetingViewState();
    return meetingViewState;
  }
}

class _MeetingViewState extends State<MeetingView> {
  bool _readOnly = true;
  Meeting meeting;
  List<Alternative> alternatives;
  DateTime _alternativeFormDate;
  TimeOfDay _alternativeFormTime;
  List userUidList;
  List userNameList;
  List userImageUrlList;

  Function onPostAlternative = () => null;

  @override
  void setState(fn) {
    // TODO: implement setState
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    getAlternative();
    // query meeting here
    // THESE ARE HARD-CODED TESTS
    // If you look carefully, the date format is in the form of YYYY-MM-DD.
    // This can be replaced by any of the formats given here:
    // https://api.dart.dev/stable/1.24.3/dart-core/DateTime/parse.html
    // ^Needs to be in these specific formats to parse to and from the date picker and strings etc.
    meeting = Meeting(
      title: widget.title,
      desc: widget.desc,
      isUser: widget.user == widget.database.getUid(),
      date: widget.dateString,
      time: widget.timeString,
      notAttending: widget.notAttending.length,
      attending: widget.attending.length,
      maybe: widget.maybe.length,
      attendingState: widget.attending.contains(widget.database.getUid())
          ? Meeting.ATTENDING
          : (widget.notAttending.contains(widget.database.getUid())
              ? Meeting.NOT_ATTENDING
              : (widget.maybe.contains(widget.database.getUid())
                  ? Meeting.MAYBE
                  : Meeting.UNSELECTED)),
      onDelete: () => showDeleteDialog(null),
      onEdit: () => editMeeting(),
      onSave: (String title, String desc, String location, String date,
              String time) =>
          saveMeeting(title, desc, location, date, time),
      onAttend: (Meeting meet) => updateMeetingAttending(meet, 1),
      onNotAttend: (Meeting meet) => updateMeetingAttending(meet, 2),
      onMaybe: (Meeting meet) => updateMeetingAttending(meet, 3),
      context: context,
      location: widget.location,
    );

    alternatives = [];
  }

  void getAlternative() async {
    List<Alternative> _alternatives = new List();
    List<MeetingAlt> alt =
        await widget.database.meetingAltList(widget.meetingId);
    for (var ele in alt) {
      Alternative newAlt = Alternative(
        alternativeId: ele.meetingAltId,
        uid: ele.user,
        name: userNameList[userUidList.indexOf(ele.user)],
        dateString: ele.date,
        timeString: ele.time,
        image: userImageUrlList[userUidList.indexOf(ele.user)] == null
            ? null
            : NetworkImage(
                userImageUrlList[userUidList.indexOf(ele.user)].toString()),
        onPress: (Alternative alt) => showDeleteDialog(alt),
        onVote: (Alternative alt) => updateAlternativeVote(alt),
        onAcceptAlternative: (Alternative alt) => updateAlternative(alt),
        onRejectAlternative: (Alternative alt) => updateAlternative(alt),
        votes: ele.votesCount,
        hasVoted: ele.votes.contains(widget.database.getUid()),
        isMeetingCreator: widget.database.getUid() == widget.user,
        acceptState: ele.acceptState,
      );
      _alternatives.add(newAlt);
    }
    setState(() {
      alternatives = _alternatives;
    });
  }

  void getUserListDetails() {
    setState(() {
      userUidList = widget.database.getUserUidList();
      userNameList = widget.database.getUserNameList();
      userImageUrlList = widget.database.getUserImageList();
    });
  }

  void refreshUserListDetails() async {
    Map _userListDetails = await widget.database.getUserList();
    setState(() {
      userUidList = _userListDetails['userUidList'];
      userNameList = _userListDetails['userNameList'];
      userImageUrlList = _userListDetails['userImageUrlList'];
    });
  }

  void refresh() {
    setState(() {});
  }

  void editMeeting() {
    setState(() {
      _readOnly = false;
    });
  }

  void acceptAlternative(Alternative alt) {
    meeting.setDate(alt.date);
    meeting.setTime(alt.time);
    int votes = alt.hasVoted ? alt.votes : (alt.votes == 0 ? 1 : alt.votes + 1);
    meeting.setAttendingNumbers(votes, 0, 0);
    meeting.setAttendingState(true);
    refresh();
    widget.database.acceptAltMeetingDetails(
        alt.alternativeId, widget.title, widget.meetingId, {
      'date': alt.date,
      'time': alt.time,
      'dateSort': _convertFromString(alt.date, alt.time),
    });
  }

  void updateAlternative(Alternative alt) {
    widget.database.updateAltMeetingDetails(
        alt.alternativeId, widget.title, widget.meetingId, {
      'date': alt.dateString,
      'time': alt.timeString,
      'acceptState': alt.acceptState,
    });
  }

  void updateAlternativeVote(Alternative alt) {
    widget.database.updateAltMeetingVotes(alt.alternativeId, alt.dateString,
        alt.timeString, widget.title, widget.meetingId);
  }

  void updateMeetingAttending(Meeting meet, int state) {
    widget.database.updateMeetingAttending(
        state, meet.attendingState, widget.title, widget.meetingId);
  }

  void showDeleteDialog(Alternative alt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _deleteDialog(alt);
      },
      barrierDismissible: true,
    );
  }

  Widget _deleteDialog(Alternative alt) {
    String verb =
        alt == null ? "scheduled meeting" : "alternative proposed meeting";
    return AlertDialog(
      title: Text("Are you sure?"),
      content: Text("This $verb? will be lost forever."),
      actions: <Widget>[
        FlatButton(
          child: Text("No"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () => {
            deleteMeeting(alt),
            Navigator.of(context).pop(),
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  void deleteMeeting(Alternative alt) {
    if (alt == null) {
      widget.database.deleteMeeting(widget.title, widget.meetingId);
      Navigator.of(context).pop();
    } else {
      widget.database.deleteMeetingAlt(widget.title, widget.meetingId,
          alt.alternativeId, alt.dateString, alt.timeString);
      getAlternative();
    }
  }

  void saveMeeting(
      String title, String desc, String location, String date, String time) {
    widget.database.updateMeetingDetails(widget.meetingId, {
      'title': title,
      'description': desc,
      'location': location,
      'date': date,
      'time': time,
      'dateSort': _convertFromString(date, time),
    });
    setState(() {
      _readOnly = true;
    });
  }

  Timestamp _convertFromString(String date, String time) {
    String dd = date.substring(8, 10);
    String mm = date.substring(5, 7);
    String yyyy = date.substring(0, 4);

    String hh = time.substring(0, 2);
    String min = time.substring(3, 5);

    return Timestamp.fromDate(
        DateTime.parse(yyyy + mm + dd + "T" + hh + min + "00"));
  }

  @override
  Widget build(BuildContext context) {
    if (userUidList == null) {
      getUserListDetails();
      refreshUserListDetails();
    }
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
      ),
      backgroundColor: Color(0xFFE9E9E9),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 10,
                  bottom: 20,
                ),
                child: Text(
                  'Meeting Details',
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
                child:
                    _readOnly ? meeting.toWidgetView() : meeting.toWidgetEdit(),
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
                child: _alternativesCard(alternatives),
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

  Widget _alternativesCard(List meetingList) {
    List<Widget> widgets = [];
    widgets.add(headingText("Alternatives"));
    for (int i = 0; i < meetingList.length; i++) {
      widgets.add(meetingList[i].toWidget());
      if (i == meetingList.length - 1) widgets.add(addAlternativeForm());
    }
    if (meetingList.length == 0) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(top: 15),
          child: Center(
            child: Text(
              "There are no alternatives!",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      widgets.add(addAlternativeForm());
    }
    return Column(
      children: widgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget addAlternativeForm() {
    return Container(
      margin: EdgeInsets.only(left: 15, bottom: 15, top: 25, right: 15),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      bottomLeft: Radius.circular(35)),
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
                    _pickDate();
                  },
                  child: Text(
                    _alternativeFormDate == null || _alternativeFormTime == null
                        ? "Pick a date and time"
                        : "Selected: ${MeetingTimeString.create(_alternativeFormDate, _alternativeFormTime)}",
                    style: TextStyle(
                      fontFamily: "Roboto",
                      color: _alternativeFormDate == null ||
                              _alternativeFormTime == null
                          ? Colors.black54
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            alternativeButton(),
          ],
        ),
      ),
    );
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _alternativeFormDate = date;
        _alternativeFormTime = null;
      });
    }
    _pickTime();
  }

  _pickTime() async {
    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _alternativeFormTime = time;
      });
    }
  }

  Widget alternativeButton() {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: IconButton(
        icon: Icon(
          Icons.send,
          size: 25,
          color: Colors.white,
        ),
        onPressed: () =>
            _alternativeFormDate == null ? null : onSendAlternative(),
      ),
    );
  }

  void onSendAlternative() async {
    String meetingAltId = DateTime.now().toString();
    alternatives.add(
      Alternative(
        alternativeId: meetingAltId,
        uid: widget.database.getUid(),
        isMeetingCreator: widget.database.getUid() == widget.user,
        image: userImageUrlList[
                    userUidList.indexOf(widget.database.getUid())] ==
                null
            ? null
            : NetworkImage(
                userImageUrlList[userUidList.indexOf(widget.database.getUid())]
                    .toString()),
        hasVoted: false,
        votes: 0,
        name: userNameList[userUidList.indexOf(widget.database.getUid())],
        onVote: (Alternative alt) => updateAlternativeVote(alt),
        onAcceptAlternative: (Alternative alt) => updateAlternative(alt),
        onPress: (Alternative alt) => showDeleteDialog(alt),
        onRejectAlternative: (Alternative alt) => updateAlternative(alt),

        //SHOULD BE LIKE THIS WHEN STORING THE STRING TO DB TOO
        //This is correct unlike the other hard-coded stuff around it
        //KEEP THIS for new entry into DB
        timeString: _alternativeFormTime.toString().substring(10, 15),
        dateString: DateFormat('yyyy-MM-dd').format(_alternativeFormDate),
      ),
    );

    widget.database
        .createMeetingAlt(widget.title, widget.meetingId, meetingAltId, {
      'meetingAltId': meetingAltId,
      'user': widget.database.getUid(),
      'isMeetingCreator': widget.database.getUid() == widget.user,
      'votes': [],
      'votesCount': 0,
      'date': DateFormat('yyyy-MM-dd').format(_alternativeFormDate),
      'time': _alternativeFormTime.toString().substring(10, 15),
      'acceptState': 0,
    });

    //KEEP THIS
    _alternativeFormTime = null;
    _alternativeFormDate = null;
    getAlternative();
    refresh();
  }

  Widget headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 12,
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
}

class Meeting {
  String title;
  String desc;
  String location;
  String date;
  String time;
  int attending;
  int notAttending;
  int maybe;
  TextEditingController _titleController;
  TextEditingController _descController;
  TextEditingController _locationController;
  bool _readOnly;
  bool isUser;

  Function onDelete;
  Function onEdit;
  Function onSave;
  Function onAttend;
  Function onNotAttend;
  Function onMaybe;

  BuildContext context;

  int attendingState;
  static const ATTENDING = 1;
  static const NOT_ATTENDING = 2;
  static const MAYBE = 3;
  static const UNSELECTED = 0;

  Meeting({
    @required this.title,
    @required this.desc,
    @required this.date,
    @required this.time,
    @required this.attending,
    @required this.notAttending,
    @required this.maybe,
    @required this.attendingState,
    @required this.isUser,
    @required this.onDelete,
    @required this.onEdit,
    @required this.onSave,
    @required this.onAttend,
    @required this.onNotAttend,
    @required this.onMaybe,
    @required this.context,
    @required this.location,
  }) {
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _locationController = TextEditingController();
    _titleController.text = title;
    _descController.text = desc;
    _locationController.text = location;
  }

  void setDate(String date) {
    this.date = date;
  }

  void setTime(String time) {
    this.time = time;
  }

  void setAttendingNumbers(int attending, int maybe, int notAttending) {
    this.attending = attending;
    this.maybe = maybe;
    this.notAttending = notAttending;
  }

  void setAttendingState(bool attending) {
    this.attendingState = attending ? Meeting.ATTENDING : Meeting.UNSELECTED;
  }

  Widget toWidgetEdit() {
    _readOnly = false;
    return toWidget();
  }

  Widget toWidgetView() {
    _readOnly = true;
    return toWidget();
  }

  void setTitle(String s) {
    _titleController.text = s;
    title = s;
  }

  void setDesc(String s) {
    _descController.text = s;
    desc = s;
  }

  void setLocation(String s) {
    _locationController.text = s;
    location = s;
  }

  String get titleString {
    return title;
  }

  String get descString {
    return desc;
  }

  Widget toWidget() {
    //TODO: PARSES DATE AND TIME STRINGS HERE
    //Time string parses the format of HH:MM strings.
    //Need testing here.
    DateTime newDate = DateTime.parse(date);
    TimeOfDay newTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 12),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 19,
                        ),
                      )
                    : TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 19,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: _readOnly,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Title of your meeting",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 2, right: 15),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        location,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black26,
                          fontSize: 15,
                        ),
                      )
                    : TextField(
                        controller: _locationController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: _readOnly,
                        maxLines: 6,
                        minLines: 1,
                        decoration: InputDecoration(
                          labelText: "Location",
                          hintText: "Location of your meeting",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 15, bottom: 10, right: 15, top: _readOnly ? 0 : 8),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        "Scheduled on: ${MeetingTimeString.create(newDate, newTime)}",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
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
                            _pickDate();
                          },
                          child: Text(
                            // "Scheduled on: $date $time",
                            "Scheduled on: ${MeetingTimeString.create(newDate, newTime)}",
                            style: TextStyle(
                              fontFamily: "Roboto",
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        desc,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      )
                    : TextField(
                        controller: _descController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: _readOnly,
                        maxLines: 6,
                        minLines: 1,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Description of your meeting",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: isUser ? 20 : 0),
        isUser ? editSaveButton() : SizedBox(),
        isUser ? deleteButton() : SizedBox(),
        Row(
          children: <Widget>[
            headingText("Attending?"),
            Spacer(),
          ],
        ),
        attendingBar(),
        SizedBox(height: isUser ? 5 : 0),
      ],
    );
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _pickTime(date);
    }
  }

  _pickTime(DateTime date) async {
    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      String meetingString = MeetingTimeString.create(date, time);
      this.date = meetingString.split(" ")[0].split("/")[2] +
          meetingString.split(" ")[0].split("/")[1] +
          meetingString.split(" ")[0].split("/")[0];
      this.time = meetingString.split(" ")[1];
      //TODO: THE STRINGS AFTER THIS NEED TO BE SAVED WITH onEdit FUNCTION.
      meetingViewState.refresh();
    }
  }

  Widget attendingBar() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 10),
      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: attendingButton(),
          ),
          SizedBox(width: 8),
          Expanded(
            child: maybeButton(),
          ),
          SizedBox(width: 8),
          Expanded(
            child: notAttendingButton(),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
    );
  }

  void decreaseCounts() {
    if (attendingState == ATTENDING) {
      attending--;
    } else if (attendingState == NOT_ATTENDING) {
      notAttending--;
    } else if (attendingState == MAYBE) {
      maybe--;
    }
  }

  Widget attendingButton() {
    return Container(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        color: attendingState == ATTENDING ? Colors.white60 : Color(0xFF06D8AE),
        onPressed: () {
          onAttend.call(this);
          if (attendingState != ATTENDING) {
            decreaseCounts();
            attendingState = ATTENDING;
            attending++;
          } else {
            attendingState = UNSELECTED;
            attending--;
          }
          meetingViewState.refresh();
        },
        child: Column(
          children: <Widget>[
            SizedBox(height: 6),
            Center(
              child: Text(
                "Yes",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                attending.toString(),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 6),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: attendingState == ATTENDING
                ? Colors.black.withOpacity(0.15)
                : Color(0xFF24DCB7).withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
    );
  }

  Widget notAttendingButton() {
    return Container(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        color:
            attendingState == NOT_ATTENDING ? Colors.white60 : Colors.redAccent,
        onPressed: () {
          onNotAttend.call(this);
          if (attendingState != NOT_ATTENDING) {
            decreaseCounts();
            attendingState = NOT_ATTENDING;
            notAttending++;
          } else {
            attendingState = UNSELECTED;
            notAttending--;
          }
          meetingViewState.refresh();
        },
        child: Column(
          children: <Widget>[
            SizedBox(height: 6),
            Center(
              child: Text(
                "No",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                notAttending.toString(),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 6),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: attendingState == NOT_ATTENDING
                ? Colors.black.withOpacity(0.15)
                : Colors.redAccent.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget maybeButton() {
    return Container(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        color: attendingState == MAYBE ? Colors.white60 : Color(0xFFfc9803),
        onPressed: () {
          onMaybe.call(this);
          if (attendingState != MAYBE) {
            decreaseCounts();
            attendingState = MAYBE;
            maybe++;
          } else {
            attendingState = UNSELECTED;
            maybe--;
          }
          meetingViewState.refresh();
        },
        child: Column(
          children: <Widget>[
            SizedBox(height: 6),
            Center(
              child: Text(
                "Maybe",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                maybe.toString(),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 6),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: attendingState == MAYBE
                ? Colors.black.withOpacity(0.15)
                : Color(0xFFffab24).withOpacity(0.35),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget editSaveButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
        onPressed: _readOnly
            ? onEdit
            : () {
                onSave.call(
                    _titleController.text,
                    _descController.text,
                    _locationController.text,
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(this.date)),
                    this.time);
                //[Note] Local cache below.
                setTitle(_titleController.text);
                setDesc(_descController.text);
                setLocation(_locationController.text);
              },
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              _readOnly ? "Edit meeting" : "Save changes",
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

  Widget deleteButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FlatButton(
        color: Colors.redAccent,
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              "Delete meeting",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFFFCFCFC),
              ),
            ),
            Spacer(),
          ],
        ),
        onPressed: onDelete,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    );
  }

  Widget headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 12,
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
}

class Alternative {
  String alternativeId;
  String uid;
  String name;
  String dateString;
  String timeString;
  ImageProvider<dynamic> image;
  Function onPress;
  Function onVote;
  Function onAcceptAlternative;
  Function onRejectAlternative;
  bool hasVoted;
  int votes;
  bool isMeetingCreator;

  int acceptState;
  static const ACCEPTED = 1;
  static const REJECTED = 2;
  static const UNSELECTED = 0;

  Alternative({
    @required this.alternativeId,
    @required this.uid,
    @required this.name,
    @required this.dateString,
    @required this.timeString,
    @required this.image,
    @required this.onPress,
    @required this.onVote,
    @required this.votes,
    @required this.hasVoted,
    @required this.isMeetingCreator,
    @required this.onAcceptAlternative,
    @required this.onRejectAlternative,
    this.acceptState,
  }) {
    if (acceptState == null) acceptState = UNSELECTED;
  }

  String get date => dateString;

  String get time => timeString;

  Widget toWidget() {
    DateTime newDate = DateTime.parse(dateString);
    TimeOfDay newTime = TimeOfDay(
        hour: int.parse(timeString.split(":")[0]),
        minute: int.parse(timeString.split(":")[1]));

    return GestureDetector(
      onLongPress: () {
        onPress.call(this);
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                makeAvatar(),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Votes: $votes",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      color: Colors.black45,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              MeetingTimeString.create(newDate, newTime)
                                  .split(" ")[0],
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10, bottom: 10),
                            child: Text(
                              MeetingTimeString.create(newDate, newTime)
                                  .split(" ")[1],
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(right: 10, bottom: 10),
                    child: FlatButton(
                      color: !hasVoted && acceptState == 0
                          ? Color(0xFF06D8AE)
                          : Color(0xFFE9E9E9),
                      onPressed: () {
                        if (acceptState != 0) {
                          return null;
                        } else {
                          onVote.call(this);
                          hasVoted = !hasVoted;
                          if (hasVoted) {
                            votes++;
                          } else {
                            votes--;
                          }
                        }
                        meetingViewState.refresh();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            !hasVoted
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 40,
                            color: !hasVoted && acceptState == 0
                                ? Colors.white
                                : Colors.black45,
                          ),
                          Text(
                            hasVoted ? "Unvote" : "Vote",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: !hasVoted && acceptState == 0
                                  ? Colors.white
                                  : Colors.black45,
                            ),
                          ),
                          SizedBox(height: 6),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: !hasVoted && acceptState == 0
                              ? Color(0xFF06D8AE).withOpacity(0.3)
                              : Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isMeetingCreator
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8, right: 4),
                          child: FlatButton(
                            color: !(acceptState == ACCEPTED) &&
                                    acceptState != REJECTED
                                ? Color(0xFF06D8AE)
                                : Color(0xFFE9E9E9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            onPressed: () {
                              if (acceptState != ACCEPTED &&
                                  acceptState != REJECTED) {
                                acceptState = ACCEPTED;
                                onAcceptAlternative.call(this);
                                meetingViewState.acceptAlternative(this);
                                //meetingViewState.refresh();
                              }
                            },
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: !(acceptState == ACCEPTED) &&
                                        acceptState != REJECTED
                                    ? Colors.white
                                    : Colors.black45,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: !(acceptState == ACCEPTED) &&
                                        acceptState != REJECTED
                                    ? Color(0xFF06D8AE).withOpacity(0.3)
                                    : Colors.black.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 4, right: 8),
                          child: FlatButton(
                            color: acceptState != REJECTED &&
                                    acceptState != ACCEPTED
                                ? Colors.redAccent
                                : Color(0xFFE9E9E9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            onPressed: () {
                              if (acceptState != ACCEPTED &&
                                  acceptState != REJECTED) {
                                acceptState = REJECTED;
                                onRejectAlternative.call(this);
                                meetingViewState.refresh();
                              }
                            },
                            child: Text(
                              "Reject",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: acceptState != REJECTED &&
                                        acceptState != ACCEPTED
                                    ? Colors.white
                                    : Colors.black45,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: acceptState != REJECTED &&
                                        acceptState != ACCEPTED
                                    ? Colors.redAccent.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
            acceptState == ACCEPTED || acceptState == REJECTED
                ? Container(
                    margin: EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        acceptState == ACCEPTED
                            ? "Accepted"
                            : acceptState == REJECTED ? "Rejected" : "",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: acceptState == ACCEPTED
                              ? Color(0xFF06D8AE)
                              : acceptState == REJECTED
                                  ? Colors.redAccent
                                  : Color(0xFFE9E9E9),
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        top: 12,
        right: 6,
        left: 12,
      ),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: image,
        backgroundColor: Color(0xFFFCFCFC),
        foregroundColor: Colors.black,
        radius: 12,
        child: image == null
            ? Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  fontSize: 10,
                ),
              )
            : SizedBox(),
      ),
    );
  }
}

class MeetingTimeString {
  static String create(DateTime date, TimeOfDay time) {
    String newHour = "";
    String newMinute = "";
    String newMonth = "";
    String newDay = "";

    if (time != null && date != null) {
      newHour = time.hour < 10 ? "0${time.hour}" : "${time.hour}";
      newMinute = time.minute < 10 ? "0${time.minute}" : "${time.minute}";
      newMonth = date.month < 10 ? "0${date.month}" : "${date.month}";
      newDay = date.day < 10 ? "0${date.day}" : "${date.day}";
    }

    return "$newDay/$newMonth/${date.year} $newHour:$newMinute";
  }
}
