import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';

class MainSettings extends StatefulWidget {
  @override
  _MainSettingsState createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: CustomAppbar.appBar('Settings'),
    );
  }
}