import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/auth.dart';

class ForgetPasswordPage extends StatefulWidget {
  final AuthBase auth;

  ForgetPasswordPage({
    @required this.auth,
  });

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = false;
  bool _incorrectEmailFormat = false;
  bool _emailDoesNotExist = false;
  String _emailErrorMsg = ""; 
  bool _activateLink = false;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 110,
                  bottom: 70,
                ),
                child: Text(
                  'Password reset',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w400,
                    height: 1.5
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                child: passwordResetForm(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget passwordResetForm(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget> [
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Please key in your email address for us to send you a password reset link. Thank you.",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              _emailTextField(),
              SizedBox(height: 12.0),
              OutlineButton(
                borderSide: BorderSide(color: Color(0xFF31BCD8)),
                child: Text(
                  "Send me the password reset link!",
                  style: TextStyle(
                    color: Color(0xFF31BCD8),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(24.0),
                  ),
                ),
                onPressed: () => !_isLoading ? _resetPassword(context) : null,
              ),
              Offstage(
                offstage: !_activateLink, //add in logic afterwards
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget> [
                    SizedBox(height: 8.0),
                    FlatButton(
                      child: Text(
                        "Didn't received the email? Send me another one!",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () => _resetPassword(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _emailTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "user@example.com",
        errorText: _emailErrorMsg == "" ? null : _emailErrorMsg,
        enabled: !_isLoading,
      ),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      focusNode: _emailFocusNode,
      onChanged: (email) => _updateState(),
      onEditingComplete: () => _resetPassword(context),
    );
  }
  String get _email => _emailController.text;
  
  void _updateState() {
    setState(() {});
  }

  void _updateEmailErrorMsg() {
    if (_incorrectEmailFormat) {
      print("B");
      _emailErrorMsg = "Invalid email format";
    } else if (_emailDoesNotExist) {
      print("A");
      _emailErrorMsg = "$_email does not exist";
    } else {
      _emailErrorMsg = "";
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _incorrectEmailFormat = false;
      _emailDoesNotExist = false;
      _activateLink = false;
    });
    try {
      await widget.auth.sendPasswordResetEmail(_email);
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        _activateLink = true;
      });
    } catch (e) {
      switch(e.code) {
        case "ERROR_INVALID_EMAIL": {
          setState(() {
            _incorrectEmailFormat = true;
          });
          _updateEmailErrorMsg();
        }
        break;
        default: {
          setState(() {
            _emailDoesNotExist = true;
          });
          _updateEmailErrorMsg();
        }
        break;
      }
      print(e.code);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}