import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/project_database.dart';
import 'package:intl/intl.dart';

class MeetingFormPage extends StatelessWidget {
  final ProjectDatabase database;

  MeetingFormPage({
    @required this.database,
  });

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
      ),
      body: Stack(
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
                  'Meeting Creation',
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
                      child: MeetingForm(
                        database: database,
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

_MeetingFormState meetingFormState;

class MeetingForm extends StatefulWidget {
  final ProjectDatabase database;

  MeetingForm({
    @required this.database,
  });

  @override
  _MeetingFormState createState() {
    meetingFormState = _MeetingFormState();
    return meetingFormState;
  }
}

class _MeetingFormState extends State<MeetingForm> {
  final FocusNode _meetingTitleFocusNode = FocusNode();
  final FocusNode _meetingDescriptionFocusNode = FocusNode();
  final FocusNode _meetingLocationFocusNode = FocusNode();
  final TextEditingController _meetingTitleController = TextEditingController();
  final TextEditingController _meetingDescriptionController =
      TextEditingController();
  final TextEditingController _meetingLocationController = TextEditingController();
  bool _meetingNameValid = true;
  bool _meetingDescValid = true;
  bool _formValid = true;
  DateTime _date;
  TimeOfDay _time;
  String _meetingDate;

  @override
  void dispose() {
    _meetingTitleController.dispose();
    _meetingDescriptionController.dispose();
    _meetingLocationController.dispose();
    _meetingTitleFocusNode.dispose();
    _meetingDescriptionFocusNode.dispose();
    _meetingLocationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
            left: 15,
            right: 15,
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
      _meetingTitleField(),
      SizedBox(height: 10.0),
      _meetingDescriptionField(),
      SizedBox(height: 10.0),
      _meetingLocationField(),
      SizedBox(height: 10.0),
      _meetingDeadlineField(),
      SizedBox(height: 10.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              color: Color(0xFFE9E9E9),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
                  "Create Meeting",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
                onPressed: () => _addmeeting(),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void checkFormValid() {
    bool _valid = (_meetingTitle.isNotEmpty) &&
        (_meetingDescription.isNotEmpty) &&
        (_meetingDate != null);
    setState(() {
      _meetingNameValid = _meetingTitle.isNotEmpty;
      _meetingDescValid = _meetingDescription.isNotEmpty;
      _formValid = _valid;
    });
  }

  void _addmeeting() async {
    checkFormValid();
    if (_formValid) {
      print("Meeting form is valid, writing to DB now");
      String meetingId = DateTime.now().toString();
      await widget.database.createMeeting(meetingId, {
      'user': widget.database.getUid(),
      'title': _meetingTitle,
      'description': _meetingDescription, 
      'location': _meetingLocation,
      'meetingId': meetingId,
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'time': _time.toString().substring(10,15),
      'attending': [widget.database.getUid(),],
      'maybe': [],
      'notAttending': [],
      'dateSort': _convertFromString(_date, _time),
      });
      Navigator.of(context).pop(true);
    } else {
      print("Meeting form is not valid");
    }
  }

  Timestamp _convertFromString(DateTime date, TimeOfDay time) {
    String _dd = date.day.toString();
    String dd = _dd.length < 2 ? "0" + _dd : _dd;
    String _mm = date.month.toString();
    String mm = _mm.length < 2 ? "0" + _mm : _mm;
    String _yyyy = date.year.toString();
    String yyyy = _yyyy.length == 2 ? "20" + _yyyy : _yyyy;

    String hh = time.toString().substring(10,12);
    String min = time.toString().substring(13,15);
    
    return Timestamp.fromDate(DateTime.parse(yyyy + mm + dd + "T" + hh + min + "00"));
  }
  
  void _updateState() {
    setState(() {});
  }

  String get _meetingTitle => _meetingTitleController.text.trim();
  String get _meetingDescription => _meetingDescriptionController.text.trim();
  String get _meetingLocation => _meetingLocationController.text.trim();

  Widget _meetingTitleField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Meeting title",
        hintText: "The title of your meeting",
        errorText: _meetingNameValid ? null : "Please fill in a title",
      ),
      controller: _meetingTitleController,
      textInputAction: TextInputAction.next,
      focusNode: _meetingTitleFocusNode,
      onChanged: (name) => _updateState(),
      onEditingComplete: () => _meetingTitleEditingComplete(),
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _meetingDescriptionField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Meeting description",
        hintText: "The agenda of your meeting",
        errorText: _meetingDescValid ? null : "Please fill in some description",
      ),
      controller: _meetingDescriptionController,
      textInputAction: TextInputAction.next,
      focusNode: _meetingDescriptionFocusNode,
      onChanged: (desc) => _updateState(),
      onEditingComplete: () => _meetingDescEditingComplete(),
      maxLines: 3,
      showCursor: true,
      maxLengthEnforced: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _meetingLocationField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Meeting location",
        hintText: "The location of your meeting",
      ),
      controller: _meetingLocationController,
      textInputAction: TextInputAction.next,
      focusNode: _meetingLocationFocusNode,
      onChanged: (desc) => _updateState(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      maxLines: 2,
      showCursor: true,
      maxLengthEnforced: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _meetingDeadlineField() {
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
          _pickDate();
        },
        child: Text(
          _meetingDate == null ? "Pick a date and time" : "Scheduled on: " + _meetingDate,
          style: TextStyle(
            fontFamily: "Roboto",
            color: _meetingDate == null ? Colors.black54 : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  void _pickDate() async {
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

  void _pickTime(DateTime date) async {
    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      String meetingString = MeetingTimeString.create(date, time);
      // String dateString = meetingString.split(" ")[0].split("/")[2] +
      //     meetingString.split(" ")[0].split("/")[1] +
      //     meetingString.split(" ")[0].split("/")[0];
      // String timeString = meetingString.split(" ")[1];
      setState(() {
        _date = date;
        _time = time;
        _meetingDate = meetingString;
      });
    }
  }

  void _meetingTitleEditingComplete() {
    final newFocus = _meetingTitle.trim().isNotEmpty
        ? _meetingDescriptionFocusNode
        : _meetingTitleFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
    setState(() {
      _meetingNameValid = _meetingTitle.trim().isNotEmpty;
    });
  }

  void _meetingDescEditingComplete() {
    final newFocus = _meetingDescription.trim().isNotEmpty
        ? _meetingLocationFocusNode
        : _meetingDescriptionFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
    setState(() {
      _meetingDescValid = _meetingDescription.trim().isNotEmpty;
    });
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
