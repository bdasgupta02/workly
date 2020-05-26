import 'package:flutter/material.dart';
import 'package:workly/screens/home.dart';
import 'package:workly/screens/calendar.dart';
import 'package:workly/screens/main_settings.dart';
import 'package:workly/services/auth.dart';

_NavbarWrapperState navState; //[Action] Better to use a Provider than a global variable to change this state externally.

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
  var _pageController = PageController(initialPage: _selectedPage);
  static AuthBase authentication;
  static final _pageOptions = [
    Home(auth: authentication),
    Calendar(),
    Calendar(),
    MainSettings(),
  ];

  void customPage(int i) {
    this.setState(() {
      _selectedPage = i;
      _pageController.jumpToPage(_selectedPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: PageView(
        children: _pageOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
        controller: _pageController,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedPage,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
              _pageController.jumpToPage(_selectedPage);
            });
          },
          items: [
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.home, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.home, color: Color(0xFF39CEEB),),
              title: Text('Home', style: TextStyle(color: Color(0xFF009FBE), fontSize: 15, fontFamily: 'Khula', height: 1.2,)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.edit, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.edit, color: Color(0xFF39CEEB),),
              title: Text('Projects', style: TextStyle(color: Color(0xFF009FBE), fontSize: 15, fontFamily: 'Khula', height: 1.2,)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.calendar_today, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.calendar_today, color: Color(0xFF39CEEB),),
              title: Text('Calendar', style: TextStyle(color: Color(0xFF009FBE), fontSize: 15, fontFamily: 'Khula', height: 1.2,)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.settings, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.settings, color: Color(0xFF39CEEB),),
              title: Text('Settings', style: TextStyle(color: Color(0xFF009FBE), fontSize: 15, fontFamily: 'Khula', height: 1.2,)),
            ),
          ],
        ),
      ),
    );
  }
}

