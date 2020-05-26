import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/CustomRaisedButton.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/auth.dart';

class EmailLoginPage extends StatelessWidget {
  final AuthBase auth;

  EmailLoginPage({
    @required this.auth,
  });

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
                  'Sign in with email',
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
                //[Note] Now it's at the center of the screen which automatically gets lifted by a keyboard
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      child: EmailLoginForm(
                        auth: auth,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFFE9E9E9), //[Action needed] Update colour
    );
  }
}

enum EmailLoginFormType {
  signIn,
  register,
}

class EmailLoginForm extends StatefulWidget with EmailAndPasswordValidators {
  final AuthBase auth;

  EmailLoginForm({
    @required this.auth,
  });

  @override
  _EmailLoginFormState createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final TextEditingController _emailController =
      TextEditingController(); //To store the user input
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _submitted = false;
  bool _isLoading = false;

  EmailLoginFormType _formType = EmailLoginFormType.signIn;

  void _toggleFormType() {
    //To toggle between different state, either sign in or register
    setState(() {
      _submitted = false;
      _formType = _formType == EmailLoginFormType.signIn
          ? EmailLoginFormType.register
          : EmailLoginFormType.signIn;
    });
    _emailController
        .clear(); //Clear the user input when toggling between different state
    _passwordController.clear();
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final String flatButtonText = _formType == EmailLoginFormType.signIn
        ? "Sign in"
        : "Create an account";
    final String outlineButtonText = _formType == EmailLoginFormType.signIn
        ? "New? Create a new account now!"
        : "Have an account? Sign in here";
    bool enableSignInButton = widget.emailValidator.isValid(_email.trim()) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;

    return [
      _emailTextField(),
      SizedBox(height: 8.0),
      _passwordTextField(),
      SizedBox(height: 20.0),
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
            flatButtonText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          color: Color(0xFF04C9F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24.0),
            ),
          ),
          onPressed: () => enableSignInButton ? _submit() : null,
        ),
      ),
      SizedBox(height: 4.0),
      OutlineButton(
        borderSide: BorderSide(color: Color(0xFF31BCD8)),
        child: Text(
          outlineButtonText,
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
        onPressed: () => !_isLoading ? _toggleFormType() : null,
      ),
    ];
  }

  TextField _emailTextField() {
    bool showErrorText =
        _submitted && !widget.emailValidator.isValid(_email.trim());
    return TextField(
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "user@example.com",
        errorText: showErrorText ? widget.invalidEmailErrorText : null,
        enabled: !_isLoading,
      ),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocusNode,
      onChanged: (email) => _updateState(),
      onEditingComplete: () => _emailEditingComplete(),
    );
  }

  TextField _passwordTextField() {
    bool showErrorText =
        _submitted && !widget.passwordValidator.isValid(_password);
    return TextField(
      decoration: InputDecoration(
        labelText: "Password",
        errorText: showErrorText ? widget.invalidPasswordErrorText : null,
        enabled: !_isLoading,
      ),
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocusNode,
      onChanged: (password) => _updateState(),
      onEditingComplete: () => _submit(),
      obscureText: true,
    );
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email.trim())
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _updateState() {
    setState(() {});
  }

  String get _email => _emailController.text;

  String get _password => _passwordController.text;

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      if (_formType == EmailLoginFormType.signIn) {
        await widget.auth.signInWithEmailAndPassword(_email.trim(), _password);
      } else {
        await widget.auth
            .createUserWithEmailAndPassword(_email.trim(), _password);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

abstract class StringValidator {
  bool isValid(String value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NonEmptyStringValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = "Email can\'t be empty";
  final String invalidPasswordErrorText = "Password can\'t be empty";
}
