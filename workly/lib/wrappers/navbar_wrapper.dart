import 'package:flutter/material.dart';
import 'package:workly/screens/home.dart';
import 'package:workly/screens/calendar.dart';
import 'package:workly/screens/main_settings.dart';
import 'package:workly/services/auth.dart';
import 'package:workly/screens/projectscreen_switchboard.dart';
import 'dart:collection';

_NavbarWrapperState navState;
//[Action] Better to use a Provider than a global variable to change this state externally.

class NavbarWrapper extends StatefulWidget {
  final AuthBase auth;
  NavbarWrapper({this.auth});

  @override
  _NavbarWrapperState createState() {
    _NavbarWrapperState.authentication = auth;
    navState = _NavbarWrapperState();
    return navState;
  }
}

class _NavbarWrapperState extends State<NavbarWrapper> {
  static int _selectedPage = 0;
  static AuthBase authentication;
  static Home _home = Home(auth: authentication);
  static ProjectSwitchboard _projects = ProjectSwitchboard(index: 0);
  static Calendar _calendar = Calendar();
  static MainSettings _mainSettings = MainSettings();
  static final _pageOptions = [
    _home,
    _projects,
    _calendar,
    _mainSettings,
  ];
  static Queue<int> _history = Queue();
  static int _backLimit = 0;
  var _pageController = PageController(initialPage: _selectedPage);

  void customPage(int i) {
    this.setState(() {
      _pageController.jumpToPage(i);
    });
    clearLimit();
  }

  //[Note] Custom backward navigation through a custom history system
  Future<bool> _onBackPressed() async {
    if (_history.length != 0 && _backLimit < 6) {
      setState(() {
        if (_selectedPage == 1) {
          if (!projectSwitchboardState.emptyProjectHistory()) {
            projectSwitchboardState.goBack();
          } else {
            goBackNavbar();
          }
        } else {
          goBackNavbar();
        }
      });
      _backLimit++;
      return null;
    } else {
      return Future.sync(() => true);
    }
  }

  void goBackNavbar() {
    int temp = _backLimit;
    _pageController.jumpToPage(_history.removeLast());
    _history.removeLast();
    _backLimit = temp;
  }

  void clearLimit() {
    _backLimit = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Color(0xFFE9E9E9),
        body: PageView(
          children: _pageOptions,
          onPageChanged: (index) {
            setState(() {
              _history.add(_selectedPage);
              _selectedPage = index;
            });
            clearLimit();
          },
          controller: _pageController,
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            currentIndex: _selectedPage,
            onTap: (int index) {
              setState(() {
                _pageController.jumpToPage(index);
              });
              clearLimit();
            },
            items: [
              BottomNavigationBarItem(
                backgroundColor: Color(0xFFFCFCFC),
                icon: Icon(
                  Icons.home,
                  color: Color(0xFF898691),
                ),
                activeIcon: Icon(
                  Icons.home,
                  color: Color(0xFF39CEEB),
                ),
                title: Text(
                  'Home',
                  style: TextStyle(
                    color: Color(0xFF009FBE),
                    fontSize: 15,
                    fontFamily: 'Khula',
                    height: 1.2,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Color(0xFFFCFCFC),
                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF898691),
                ),
                activeIcon: Icon(
                  Icons.edit,
                  color: Color(0xFF39CEEB),
                ),
                title: Text(
                  'Projects',
                  style: TextStyle(
                    color: Color(0xFF009FBE),
                    fontSize: 15,
                    fontFamily: 'Khula',
                    height: 1.2,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Color(0xFFFCFCFC),
                icon: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF898691),
                ),
                activeIcon: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF39CEEB),
                ),
                title: Text(
                  'Calendar',
                  style: TextStyle(
                    color: Color(0xFF009FBE),
                    fontSize: 15,
                    fontFamily: 'Khula',
                    height: 1.2,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Color(0xFFFCFCFC),
                icon: Icon(
                  Icons.settings,
                  color: Color(0xFF898691),
                ),
                activeIcon: Icon(
                  Icons.settings,
                  color: Color(0xFF39CEEB),
                ),
                title: Text('Settings',
                    style: TextStyle(
                      color: Color(0xFF009FBE),
                      fontSize: 15,
                      fontFamily: 'Khula',
                      height: 1.2,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
