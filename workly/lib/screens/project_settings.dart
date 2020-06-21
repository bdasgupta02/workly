import 'package:flutter/material.dart';
import 'package:workly/index.dart';
import 'package:workly/services/project_database.dart';

/*
  Things to note:
  - Leave project means the user leaves the project.
  - Delete project would be for admins to remove the project. 
    If the admin is the only admin left in the group, they should not
    be able to leave the project without either:
      (i) Deleting the project.
      (ii) Nominating someone else to be the admin.
  - Need to get project description in the constructor method.
  - Need to get the list of members with the fields in the MembersTester class.
  - I've only called the project title and the invite code so far, so need to call the rest.
 */
class ProjectSettings extends StatefulWidget {
  @override
  _ProjectSettingsState createState() => _ProjectSettingsState();
}

class _ProjectSettingsState extends State<ProjectSettings> {
  bool admin =
      true; //[Action] Need a way to check if the user is the admin for this project.
  bool lastAdmin =
      false; //[Action] Need a way to check if this user is the last remaining admin.

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return constructor(database);
  }

  //[Note] This method arranges the screen's main order of items inside a listview
  Widget constructor(ProjectDatabase db) {
    return ListView(
      children: <Widget>[
        textTile(db.getProjectName(), true),
        textTile(
            'Test description goes here. More lines for testing going right here to add more text to test wrapping.',
            false), //[Action] Need to retrieve project description and input here.
        SizedBox(height: 30),
        headingText('Members'),
        SizedBox(height: 5),
        MemberTester.testMemberTiles(),
        SizedBox(height: 30),
        headingText('Project Settings'),
        uniqueCode(db.getProjectId()),
        lastAdmin
            ? SizedBox()
            : buttonTile(
                () => null, 'Leave Project', 'Leave', Colors.orangeAccent),
        admin
            ? buttonTile(
                () => null, 'Delete Project', 'Delete', Colors.redAccent)
            : SizedBox(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buttonTile(
      Function toPress, String text, String buttonText, Color buttonColor) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 9,
              bottom: 9,
              right: 9,
              left: 12,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              right: 6,
            ),
            child: FlatButton(
              color: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: toPress,
              child: Text(
                buttonText,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(24)),
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

  Widget textTile(String text, bool isTitle) {
    return Container(
      margin: EdgeInsets.only(
        top: 12,
        right: 15,
        left: 15,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: isTitle ? 20 : 15,
          fontWeight: isTitle ? FontWeight.w600 : FontWeight.w400,
          color: isTitle ? Color(0xFF141336) : Colors.black54,
        ),
      ),
    );
  }

  Widget uniqueCode(String code) {
    return Container(
      margin: EdgeInsets.only(
        top: 12,
        left: 15,
        right: 15,
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          'Invite people through this unique code: ' + code,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    );
  }

  Widget headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Member {
  String name;
  ImageProvider<dynamic> image;
  bool admin;

  Member({@required this.name, this.image, @required this.admin});

  Widget makeMemberTile(Function toPress) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 5,
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        onPressed: toPress,
        child: Row(
          children: <Widget>[
            makeAvatar(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 5,
                    right: 5,
                    bottom: 2,
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    bottom: 5,
                  ),
                  child: Text(
                    admin ? 'Admin' : 'Member',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
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

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        top: 12,
        right: 5,
      ),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: image,
        backgroundColor: Color(0xFFFCFCFC),
        foregroundColor: Colors.black,
        radius: 20,
        child: image == null
            ? Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
              )
            : SizedBox(),
      ),
    );
  }
}

class MemberTester {
  static Widget testMemberTiles() {
    List<Member> members = [
      Member(name: 'Test name', image: null, admin: true),
      Member(name: 'Second test name', image: null, admin: true),
      Member(name: 'Third test name', image: null, admin: false),
    ];
    return constructor(members);
  }

  static Widget constructor(List<Member> members) {
    List<Widget> memberWidgets = [];
    for (int i = 0; i < members.length; i++) {
      memberWidgets.add(members[i].makeMemberTile(() => null));
    }
    return Column(
      children: memberWidgets,
    );
  }
}
