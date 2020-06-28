import 'package:flutter/material.dart';

class Member {
  String name;
  String uid;
  ImageProvider<dynamic> image;
  bool admin;

  Member({@required this.name, this.uid, this.image, this.admin});

  String get getUid => uid;

  String get getName => name;

  Widget makeMemberTile(Function toPress, bool forTaskView) {
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
                forTaskView
                    ? SizedBox()
                    : Padding(
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
