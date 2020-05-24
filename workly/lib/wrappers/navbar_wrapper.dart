import 'package:flutter/material.dart';
import 'package:workly/screens/home.dart';
import 'package:workly/screens/calendar.dart';
import 'package:workly/screens/main_settings.dart';

_NavbarWrapperState navState; //[Action] Better to use a Provider than a global variable to change this state externally.

class NavbarWrapper extends StatefulWidget {
  @override
  _NavbarWrapperState createState() { 
    navState = _NavbarWrapperState();
    return navState;
  }
}

class _NavbarWrapperState extends State<NavbarWrapper> {
  static int _selectedPage = 0;
  var _pageController = PageController(initialPage: _selectedPage);
  final _pageOptions = [
    Home(),
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
          currentIndex: _selectedPage,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
              _pageController.animateToPage(_selectedPage, duration: Duration(milliseconds: 200), curve: Curves.linear);
            });
          },
          items: [
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.home, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.home, color: Color(0xFFC97788),),
              title: Text('Home', style: TextStyle(color: Color(0xFF898691), fontSize: 15)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.edit, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.edit, color: Color(0xFFC97788),),
              title: Text('Projects', style: TextStyle(color: Color(0xFF898691), fontSize: 15)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.calendar_today, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.calendar_today, color: Color(0xFFC97788),),
              title: Text('Calendar', style: TextStyle(color: Color(0xFF898691), fontSize: 15)),
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFFCFCFC),
              icon: Icon(Icons.settings, color: Color(0xFF898691),),
              activeIcon: Icon(Icons.settings, color: Color(0xFFC97788),),
              title: Text('Settings', style: TextStyle(color: Color(0xFF898691), fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

