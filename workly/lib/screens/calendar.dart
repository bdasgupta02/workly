import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: CustomAppbar.appBar('Calendar'),
    );
  }
}
