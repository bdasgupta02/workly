import 'package:flutter/material.dart';
import 'package:workly/screens/projectscreen_switchboard.dart';

class MissedDeadlines extends StatefulWidget {
  @override
  _MissedDeadlinesState createState() => _MissedDeadlinesState();
}

class _MissedDeadlinesState extends State<MissedDeadlines> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(100),
        child: FlatButton(
          onPressed: () => projectSwitchboardState.changeProjectScreen(2),
          child: Text('Deadlines'),
        ),
      ),
    );
  }
}