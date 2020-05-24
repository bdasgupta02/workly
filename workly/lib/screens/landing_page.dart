import 'package:flutter/material.dart';
import 'package:workly/screens/sign_in_page.dart';
import 'package:workly/services/auth.dart';

class LandingPage extends StatelessWidget {
  final AuthBase auth;
  
  LandingPage({
    @required this.auth,
  });

  @override 
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            return SignInPage(
              auth: auth,
            );
          } else {
            return Container (
              color: Colors.white,
              child: RaisedButton(
                child: Text("Log out"),
                onPressed: _signOut,
              ),
             ); //[Action needed] Replace with homepage
            /*
            HomePage();
            */
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }
    );
  }

  Future<void> _signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e.toString);
    }
  }
}