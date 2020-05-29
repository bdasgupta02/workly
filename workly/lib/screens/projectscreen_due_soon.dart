import 'package:flutter/material.dart';
import 'package:workly/screens/projectscreen_switchboard.dart';

class DueSoon extends StatefulWidget {
  @override
  _DueSoonState createState() => _DueSoonState();
}

class _DueSoonState extends State<DueSoon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(100),
      child: FlatButton(
        onPressed: () => projectSwitchboardState.changeProjectScreen(0),
        child: Text('Due'),
      ),
    );
  }
}
