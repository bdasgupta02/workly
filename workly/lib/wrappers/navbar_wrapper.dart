import 'package:flutter/material.dart';
import 'package:workly/screens/home.dart';
import 'package:workly/screens/calendar.dart';
import 'package:workly/screens/main_settings.dart';

class NavbarWrapper extends StatefulWidget {
  @override
  NavbarWrapperState createState() => NavbarWrapperState();
}

class NavbarWrapperState extends State<NavbarWrapper> { //[Note] Public to be accessed by other screens
  static int selectedPage = 0;
  final _pageOptions = [
    Home(),
    Calendar(),
    Calendar(),
    MainSettings(),
  ];
  var _pageController = PageController(initialPage: selectedPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: PageView(
        children: _pageOptions,
        onPageChanged: (index) {
          setState(() {
            selectedPage = index;
          });
        },
        controller: _pageController,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        child: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (int index) {
            setState(() {
              selectedPage = index;
              _pageController.animateToPage(selectedPage, duration: Duration(milliseconds: 200), curve: Curves.linear);
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

