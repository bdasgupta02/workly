import 'package:flutter/material.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

class CustomAppbar {
  static AppBar appBar(String string) {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFFE9E9E9),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Color(0xFF141336),
        ),
        onPressed: () => navState.onBackPressed(),
      ),
      title: Text(
        string,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: Color(0xFF141336),
        ),
      ),
    );
  }

  static AppBar appBarDark(String string) {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFF141336),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Color(0xFFFCFCFC),
        ),
        onPressed: () => navState.onBackPressed(),
      ),
      title: Text(
        string,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: Color(0xFFFCFCFC),
        ),
      ),
    );
  }
  //[Action] put tabbars here
}
