import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
// import 'package:workly/services/auth.dart';
import 'package:workly/services/database.dart';
import 'package:workly/wrappers/navbar_wrapper.dart';

/*
Overall notes: places that need replacing after database:
1. Buttons - they work but their onPressed property needs to be changed to the right commands.
2. Text - The strings need to be replaced by the right ones.
*/

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _token;

  @override
  initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    final database = Provider.of<Database>(context, listen: false);
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      database.updateUserToken({'pushToken': token});
      setState(() {
        _token = token;
      });
    }).catchError((err) {
      print(err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher'); //'app_icon
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.squalllabs.workly' : 'com.squalllabs.workly',
      'Workly',
      'Chat notification',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
    // print(message['body'].toString());
    // print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

    // await flutterLocalNotificationsPlugin.show(
    //     0, 'plain title', 'plain body', platformChannelSpecifics,
    //     payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
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
                    BackBoxButtons(database: database),
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
              // Container(
              //   child: (FlatButton(
              //     onPressed: () =>
              //         _signOut(), //[Action] Here's the temporary button.
              //     child: Text(
              //       'Sign-out',
              //       style: TextStyle(
              //         color: Colors.grey,
              //         fontFamily: 'Roboto',
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(34.0),
              //     ),
              //   )),
              //   margin: EdgeInsets.only(
              //     left: 40,
              //     right: 40,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Color(0xFFFCFCFC),
              //     borderRadius: BorderRadius.all(Radius.circular(34)),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.2),
              //         spreadRadius: 2,
              //         blurRadius: 15,
              //         offset: Offset(0, 3),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class BackBoxNotifs extends StatefulWidget {
  @override
  _BackBoxNotifsState createState() => _BackBoxNotifsState();
}

class _BackBoxNotifsState extends State<BackBoxNotifs> {
  bool onStart;

  @override
  initState() {
    super.initState();
    onStart = true;
  }


  List<String> _notiList = [];

  void getDocumentsList() async {
    List<String> newNotiList = new List();
    final database = Provider.of<Database>(context, listen: false);
    List<Map> _meeting = await database.userMeetingDocuments();
    print(_meeting);
    for (var meetingEle in _meeting) {
      String newNotiT = "";
      DateTime meetingDate = _convert(meetingEle['meetingDate']);
      DateTime now = DateTime.now();
      if (meetingDate.compareTo(now) <= 0) {
        newNotiT =
            "[${meetingEle['projectTitle']}]: There is a meeting '${meetingEle['meetingTitle']}' today";
        newNotiList.add(newNotiT);
      }
    }
    List<Map> _task = await database.userTaskDocuments();
    print(_task);
    for (var taskEle in _task) {
      String newNotiT = "";
      DateTime taskDate = _convert(taskEle['taskDeadline']);
      DateTime nextTwoDays = DateTime.now().add(new Duration(days: 2));
      if (taskDate.compareTo(nextTwoDays) <= 0) {
        newNotiT =
            "[${taskEle['projectTitle']}]: Task '${taskEle['taskTitle']}' due soon";
        newNotiList.add(newNotiT);
      }
    }
    if (this.mounted) {
      setState(() {
        _notiList = newNotiList;
        onStart = false;
      });
    }
  }

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

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    onStart ? getDocumentsList() : doNothing();
    // _containerList = buildList(_notifListTest);
    _containerList = buildList(_notiList);

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
                color: Color(0xFF141336),
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

class BackBoxButtons extends StatefulWidget {
  final Database database;
  BackBoxButtons({@required this.database});

  @override
  _BackBoxButtonsState createState() => _BackBoxButtonsState();
}

class _BackBoxButtonsState extends State<BackBoxButtons> {
  int missed = 0;
  int dueSoon = 0;
  bool onStart;

  @override
  initState() {
    super.initState();
    onStart = true;
  }

  void getDocumentsList() async {
    int _missed = 0;
    int _dueSoon = 0;
    List<Map> _project = await widget.database.userProjectDocuments();
    print("GET PROJECT" + '$_project');
    List<DateTime> deadline = new List();
    for (var projectEle in _project) {
      deadline.add(_convert(projectEle['projectDeadline']));
    }
    for (var deadlineEle in deadline) {
      DateTime today = DateTime.now();
      DateTime nextWeek = DateTime.now().add(new Duration(days: 7));
      if (deadlineEle.compareTo(today) <= 0) {
        _missed++;
      } else if (deadlineEle.compareTo(nextWeek) <= 0) {
        _dueSoon++;
      }
    }
    if (this.mounted) {
      setState(() {
        missed = _missed;
        dueSoon = _dueSoon;
        onStart = false;
      });
    }
  }

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    //[Note] This is highly scalable because it auto-scales to the screen. Replicate row/column system elsewhere if needed.
    onStart ? getDocumentsList() : doNothing();
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
                        missed.toString(),
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
                        dueSoon.toString(),
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

DateTime _convert(String s) {
  if (s != null) {
    print(s);
    String t = s.split("/")[2] + s.split("/")[1] + s.split("/")[0];
    //String t = s.substring(6, 10) + s.substring(3, 5) + s.substring(0, 2);
    return DateTime.parse(t);
  }
  return null;
}
