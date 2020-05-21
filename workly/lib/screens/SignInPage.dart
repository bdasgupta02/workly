import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/CustomRaisedButton.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workly"),
        centerTitle: true,
        elevation: 10.0, //shadow of appBar, default is 4.0
      ),
      body: _bodyContent(),
      backgroundColor: Colors.grey[200], //[Action needed] Update colour
    );
  }
}

Widget _bodyContent() {
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
        SizedBox(height: 50.0), //Separation between above text and below box
        SignInButton(
          text: "Sign in with email",
          textColor: Colors.black, //[Action needed] Update colour
          buttonColor: Colors.tealAccent[100], //[Action needed] Update colour
          onPressed: () {}, //[Action needed] Update onPressed action
        ),
      ],
    ),
  );
}
