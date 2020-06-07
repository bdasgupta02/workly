import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/screens/sign_in_page.dart';
import 'package:workly/services/auth.dart';
import 'package:workly/services/database.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

class LandingPage extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = snapshot.data;
          if (user == null) {
            return SignInPage();
          } else {
            return Provider<Database>(
              create: (_) => FirestoreDatabase(uid: user.uid),
              child: NavbarWrapper(),
            );
          }
            /*
            Container (
              color: Colors.white,
              child: RaisedButton(
                child: Text("Log out"),
                onPressed: _signOut,
              ),
             );
             */
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
  /*
  Future<void> _signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e.toString);
    }
  }*/
}