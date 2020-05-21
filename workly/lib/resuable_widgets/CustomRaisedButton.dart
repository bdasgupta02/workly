import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  @required final Widget child;
  final Color color;
  @required final ShapeBorder shape;
  final double height;
  final VoidCallback onPressedAction;

  CustomRaisedButton(
      {this.child, this.color = Colors.white, this.shape, this.height = 35.0, this.onPressedAction});

  @override
  Widget build(BuildContext contect) {
    return SizedBox(
      height: this.height,
      child: RaisedButton(
        child: this.child,
        color: this.color,
        elevation: 5.0,
        shape: this.shape,
        onPressed: onPressedAction,
      ),
    );
  }
}

class SignInButton extends CustomRaisedButton {
  final String text;
  final Color textColor;
  final Color buttonColor;
  final VoidCallback onPressed;

  SignInButton({this.text = "", this.textColor = Colors.black, this.buttonColor = Colors.white, this.onPressed})
      : super(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 16.0),
          ),
          color: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          height: 35.0, //[Action needed] Decide button height
          onPressedAction: onPressed,
        );
}
