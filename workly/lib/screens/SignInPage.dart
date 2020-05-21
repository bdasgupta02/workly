import 'package:flutter/material.dart';

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
      backgroundColor: Colors.grey[200], //colors to be decided
    );
  }
}

Widget _bodyContent() {
  return Padding(
    padding: EdgeInsets.all(45.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, //similar to y-axis
      crossAxisAlignment: CrossAxisAlignment.stretch, //similar to x-axis
      children: <Widget>[
        Text(
          'Sign in',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 50.0), //Separation between above text and below box
        RaisedButton(
          child: Text(
            "Sign in with email",
            style: TextStyle(fontSize: 16.0),
          ),
          color: Colors.tealAccent[100], //Colours to be decided
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          onPressed: () {},
        )
      ],
    ),
  );
}
