import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/CustomRaisedButton.dart';
import 'package:workly/screens/email_login_page.dart';
import 'package:workly/services/auth.dart';


class SignInPage extends StatelessWidget {
  final AuthBase auth;

  SignInPage({
    @required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workly"),
        centerTitle: true,
        elevation: 10.0, //shadow of appBar, default is 4.0
      ),
      body: _bodyContent(context),
      backgroundColor: Colors.grey[200], //[Action needed] Update colour
    );
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
          SizedBox(height: 50.0), //Separation between above text and below box
          SignInButton(
            text: "Email sign in",
            textColor: Colors.black, //[Action needed] Update colour
            buttonColor: Colors.tealAccent[100], //[Action needed] Update colour
            onPressed: () => _signInWithEmail(context),
          ),
          SizedBox(height: 25.0),
          /*
          SignInButton(
            text: "Google sign in",
            textColor: Colors.black,
            buttonColor: Colors.white,
            onPressed: () {},
          ),*/
        ],
      ),
    );
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailLoginPage(
          auth: auth,
        ),
      )
    );
  }
}