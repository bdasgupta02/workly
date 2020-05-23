import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/CustomRaisedButton.dart';
import 'package:workly/screens/home.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyContent(context),
      backgroundColor: Colors.grey[200], //[Action needed] Update colour
    );
  }
}

Widget _bodyContent(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(45.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      crossAxisAlignment: CrossAxisAlignment.stretch, 
      children: <Widget>[
        Text(
          'Sign in',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 70.0), //Separation between above text and below box
        SignInButton(
          text: "Sign in with email",
          textColor: Colors.white, //[Action needed] Update colour
          buttonColor: Color(0xFF43425A), //[Action needed] Update colour
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }, //[Action needed] Update onPressed action
        ),
      ],
    ),
  );
}
