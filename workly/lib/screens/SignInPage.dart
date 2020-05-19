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
    );
  }
}

Widget _bodyContent() {
  return Padding(
    padding: EdgeInsets.all(35.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, //similar to y-axis
      crossAxisAlignment: CrossAxisAlignment.stretch, //similar to x-axis
      children: <Widget>[
        Text('Sign in',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(height: 50.0), //Separation between above text and below box
        Container(
          color: Colors.orange,
          child: SizedBox(
            height: 75.0,
          ),
        ),
      ],
    ),
  );
}
