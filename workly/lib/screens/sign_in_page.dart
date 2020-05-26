import 'package:flutter/material.dart';
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
      body: _bodyContent(context),
      backgroundColor: Color(0xFFE9E9E9), //[Action needed] Update colour
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
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF33CFEE).withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FlatButton(
              child: Text(
                'Sign in with email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _signInWithEmail(context),
              color: Color(0xFF04C9F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
            ),
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
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => EmailLoginPage(
        auth: auth,
      ),
    ));
  }
}
