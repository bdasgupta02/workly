import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/CustomRaisedButton.dart';
import 'package:workly/services/auth.dart';

class EmailLoginPage extends StatelessWidget {
  final AuthBase auth;

  EmailLoginPage({
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: EmailLoginForm(
              auth: auth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(36.0),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200], //[Action needed] Update colour
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final String raisedButtonText = _formType == EmailLoginFormType.signIn
        ? "Sign in"
        : "Create my account now!";
    final String flatButtonText = _formType == EmailLoginFormType.signIn
        ? "New to Workly? Create a new account now!"
        : "Have an account? Sign in here";
    bool enableSignInButton = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;

    return [
      _emailTextField(),
      SizedBox(height: 8.0),
      _passwordTextField(),
      SizedBox(height: 8.0),
      CustomRaisedButton(
        child: Text(
          raisedButtonText,
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        color: Colors.lightBlue, //[Action needed] Update colors
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        onPressedAction: () => enableSignInButton ? _submit() : null,
      ),
      SizedBox(height: 4.0),
      FlatButton(
        child: Text(flatButtonText),
        onPressed: () => !_isLoading ? _toggleFormType() : null,
      ),
    ];
  }

  TextField _emailTextField() {
    bool showErrorText = _submitted && !widget.emailValidator.isValid(_email);
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
    final newFocus = widget.emailValidator.isValid(_email)
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
        await widget.auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await widget.auth.createUserWithEmailAndPassword(_email, _password);
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
