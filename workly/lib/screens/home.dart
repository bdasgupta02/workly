import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Container(
            child: ClipPath(
              clipper: MyClipper(),
              child: Container(
                height: 420,
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
          ),
          ListView(
            //[Note] ListView because for phones with shitty screens, it will exceed below; this enables them to scroll down
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  'Let\'s get to work!',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(bottom: 50),
              ),
              Container(
                //[Note] More scalable to wrap in Container in terms of resolutions and font sizes than implementing directly to ListView
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(left: 40, right: 40),
                decoration: BoxDecoration(
                  color: Color(0xFFC97788),
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
                child: Column(
                  children: <Widget>[
                    BackBoxWhiteNoMargin(),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        //[Action] Need to change this to a button with a transparent background for OnPressed to Project screen
                        'Swipe for projects!',
                        style:
                            TextStyle(color: Color(0xFFFCFCFC), fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(bottom: 20),
              ),
              BackBoxWhite(),
              RaisedButton(
                onPressed: () {
                  //
                  NavbarWrapperState.selectedPage = 1;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NavbarWrapper()),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  //[Note] Can move this to reusables if it's gonna be used in the tabbars
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BackBoxWhite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(left: 40, right: 40),
      height: 170,
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
    );
  }
}

class BackBoxWhiteNoMargin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: 170,
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
    );
  }
}
