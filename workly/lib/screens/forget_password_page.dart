import 'package:flutter/material.dart';
import 'package:workly/services/auth.dart';

class ForgetPasswordPage extends StatelessWidget {
  final AuthBase auth;
  
  ForgetPasswordPage({
    @required this.auth,
  });

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: 12,
          ),
          child: Container(
            child: FlatButton(
              child: Text("back"),
              onPressed: () => resetPassword(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    //remove hardcoding and add text to ask if user have received email
    String email = "worklyplatform@gmail.com";
    try {
      await auth.sendPasswordResetEmail(email);
    } catch (e) {
      print(e.toString);
    }
    Navigator.pop(context);
  }
}