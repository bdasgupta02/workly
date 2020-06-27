import 'package:flutter/material.dart';
import 'package:workly/index.dart';
import 'package:workly/screens/projectscreen_switchboard.dart';
import 'package:workly/services/project_database.dart';
import 'package:workly/resuable_widgets/member_tile.dart';

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
  List<Member> memberList;
  List adminList;
  String projectDescription;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return constructor(database);
  }

  //[Note] This method arranges the screen's main order of items inside a listview
  Widget constructor(ProjectDatabase db) {
    if (memberList == null) {
      getAdminUserList(db);
      getUserList(db);
    }
    if (projectDescription == null) {
      getProjectDescription(db);
    }
    return ListView(
      children: <Widget>[
        textTile(db.getProjectName(), true),
        // textTile(
        //     'Test description goes here. More lines for testing going right here to add more text to test wrapping.',
        //     false), //[Action] Need to retrieve project description and input here.
        textTile(projectDescription == null ? "" : projectDescription, false),
        SizedBox(height: 30),
        headingText('Members'),
        SizedBox(height: 5),
        memberList == null
            ? MemberTester.constructor(<Member>[])
            : MemberTester.constructor(memberList),
        SizedBox(height: 30),
        headingText('Project Settings'),
        uniqueCode(db.getProjectId()),
        lastAdmin
            ? SizedBox()
            : buttonTile(
                () => leaveProject(), 'Leave Project', 'Leave', Colors.orangeAccent),
        admin
            ? buttonTile(
                () => deleteProject(), 'Delete Project', 'Delete', Colors.redAccent)
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

  void getUserList(ProjectDatabase db) async {
    print("GET USER LIST");
    List<Map<String, String>> userMapList = await db.getUserList();
    List<String> userListName = List<String>();
    List<String> userListUid = List<String>();
    List<Member> memberListName = List<Member>();
    for (var ele in userMapList) {
      userListName.add(ele["name"].toString());
      userListUid.add(ele["uid"].toString());
      memberListName
          .add(Member(name: ele["name"].toString(), image: null, admin: adminList.contains(ele["uid"].toString())));
    }
    if (mounted) {
      setState(() {
        memberList = memberListName;
      });
    }
  }

  void getAdminUserList(ProjectDatabase db) async {
    List adminUserList = await db.getAdminUserList();
    setState(() {
      adminList = adminUserList;
      admin = adminUserList.contains(db.getUid());
      lastAdmin = adminUserList.contains(db.getUid()) && (adminUserList.length == 1);
    });
    print(admin);
    print(lastAdmin);
  }

  void getProjectDescription(ProjectDatabase db) async {
    String _projectDescription = await db.getProjectDescription();
    if (mounted) {
      setState(() {
        projectDescription = _projectDescription;
      });
    }
  }

  void leaveProject() async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    await database.leaveProject();
    print("TEST LEAVE PROJECT");
    // projectSwitchboardState.changeToDefaultProjectScreen();
    projectSwitchboardState.goBack();
  }

  void deleteProject() async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    await database.deleteProject();
    projectSwitchboardState.goBack();
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
      memberWidgets.add(members[i].makeMemberTile(() => null, false));
    }
    return Column(
      children: memberWidgets,
    );
  }
}
