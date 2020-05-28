import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/services/auth.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

/*
Overall notes: places that need replacing after database:
1. Buttons - they work but their onPressed property needs to be changed to the right commands.
2. Text - The strings need to be replaced by the right ones.
*/

class Home extends StatefulWidget {
  final AuthBase auth;

  Home({
    this.auth,
  });
//Above codes temporary for signout button

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
          ClippedHeader(),
          ListView(
            //[Note] ListView because for phones with shitty screens, it will exceed below; this enables them to scroll down
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 100),
                child: Text(
                  'Let\'s get to work!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Khula',
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                //[Action] Change to divider
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(bottom: 50),
              ),
              Container(
                //[Note] More scalable to wrap in Container in terms of resolutions and font sizes than implementing directly to  View
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(left: 40, right: 40),
                decoration: BoxDecoration(
                  color: Color(0xFF20293B),
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
                    BackBoxButtons(),
                    FlatButton(
                      child: Text(
                        'All Projects',
                        style: TextStyle(
                          color: Color(0xFFFCFCFC),
                          fontSize: 17,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => navState.customPage(1),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(bottom: 20),
              ),
              BackBoxNotifs(),
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                child: (FlatButton(
                  onPressed: () =>
                      _signOut(), //[Action] Here's the temporary button.
                  child: Text(
                    'Temp Logout',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(34.0),
                  ),
                )),
                margin: EdgeInsets.only(
                  left: 40,
                  right: 40,
                ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    } catch (e) {
      print(e.toString);
    }
  }
}

class BackBoxNotifs extends StatefulWidget {
  @override
  _BackBoxNotifsState createState() => _BackBoxNotifsState();
}

class _BackBoxNotifsState extends State<BackBoxNotifs> {
  //[Note] setState when the String list is updated, probably in a method here that builds it when this page is built for the first time.
  List<String> _notifListTest = [
    'First dummy notif.',
    'Second dummy notif.',
  ]; //[Action] This is a dummy String list input. Change this with String list of notifs from database.
  static List<Container> _containerList;

  List<Container> buildList(List<String> notifList) {
    //[Note] Builds notification widget list
    List<Container> containerList = new List<Container>();
    if (notifList.length == 0) {
      containerList.add(Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          left: 20,
        ),
        child: Text(
          'You are all caught up!',
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.black54),
        ),
      ));
    }
    for (var i = 0; i < notifList.length; i++) {
      if (i != 0) {
        containerList.add(Container(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          child: Divider(
            thickness: 2,
          ),
        ));
      }
      containerList.add(Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          left: 20,
        ),
        child: Text(
          notifList[i],
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black54,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
      ));
    }
    return containerList;
  }

  @override
  Widget build(BuildContext context) {
    _containerList = buildList(_notifListTest);

    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(left: 40, right: 40),
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
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
              top: 14,
              left: 20,
              bottom: 8,
            ),
            child: Text(
              'Notifications',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A7795),
                fontFamily: 'Khula',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Column(children: _containerList),
          ),
        ],
      ),
    );
  }
}

class BackBoxButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //[Note] This is highly scalable because it auto-scales to the screen. Replicate row/column system elsewhere if needed.
    return Container(
      alignment: Alignment.topCenter,
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
              child: FlatButton(
                onPressed: () => navState.customPage(1),
                //[Placeholder] Needs to be changed to clone projects pages
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        //[Placeholder] Overdue items
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 22),
                      child: Text(
                        'Missed \nDeadlines',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Khula',
                          height: 1,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF87892),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF87892).withOpacity(0.9),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 5),
              child: FlatButton(
                onPressed: () => navState.customPage(1),
                //[Placeholder] Needs to be changed to clone projects pages
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        //[Placeholder] Due soon
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 22),
                      child: Text(
                        'Due \nSoon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Khula',
                          height: 1,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF04C9F1),
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00CFF8).withOpacity(0.6),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
