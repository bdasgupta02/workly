import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/custom_clipper.dart';

class ClippedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipPath(
        clipper: MyClipper(),
        child: Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF43425A),
                Color(0xFF43425A),
              ],
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 60,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
