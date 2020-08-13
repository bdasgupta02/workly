import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/screens/email_login_page.dart';
import 'package:workly/services/auth.dart';

//[Action] We need to have privacy policy somewhere

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyContent(context),
      backgroundColor: Color(0xFF141336),
    );
  }

  Widget _bodyContent(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(
              top: 30,
              bottom: 10,
            ),
            child: Image(
              image: AssetImage('assets/sign_in_graphics_dark_tp.png'),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(right: 120, left: 120, top: 120),
              child: Image(
                image: AssetImage('assets/workly_logo_nobg.png'),
                color: Color(0xFF04C9F1),
              ),
            ),
            /*Expanded(
              child: SizedBox(),
            ),*/
            Spacer(),
            //[Note] Empty spacer which makes it more scalable for more phones
            Container(
              margin: EdgeInsets.only(
                left: 60,
                right: 60,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
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
                    color: Color(0xFF141336),
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
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 15),
              alignment: Alignment.center,
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, left: 90, right: 90, bottom: 45),
              child: Row(
                children: <Widget>[
                  //[Action] These buttons have onPressed placeholders for social media login
                  Expanded(
                    child: FlatButton(
                      onPressed: () => _signInWithGoogle(context),
                      child: Image(
                        image: AssetImage('assets/google_icon.png'),
                        height: 45,
                        width: 45,
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: FlatButton(
                  //     onPressed: null,
                  //     child: Image(
                  //       image: AssetImage('assets/fb_icon.png'),
                  //       height: 45,
                  //       width: 45,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            /*SignInButton(
              text: "Google sign in",
              textColor: Colors.black,
              buttonColor: Colors.white,
              onPressed: () {},
            ),*/
          ],
        ),
      ],
    );
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => EmailLoginPage(),
    ));
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      print(e.toString());
    }
  }
}
