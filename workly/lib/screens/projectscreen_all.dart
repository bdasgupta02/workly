import 'package:flutter/material.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

class AllProjects extends StatefulWidget {
  @override
  _AllProjectsState createState() => _AllProjectsState();
}

class _AllProjectsState extends State<AllProjects> {
  //[Note] Make static sub screens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: Padding(padding: EdgeInsets.all(100), child: FlatButton(onPressed: () => navState.customPage(4), child: Text('Press'),),),
    );
  }
}