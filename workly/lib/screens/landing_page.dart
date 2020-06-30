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
          //TODO: CHECK IF CAN MAKE WHITE SCREEN A CIRCULAR PROGRESS INDICATOR
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
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
