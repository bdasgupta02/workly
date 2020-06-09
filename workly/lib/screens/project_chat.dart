import 'package:flutter/material.dart';

class ProjectChat extends StatefulWidget {
  @override
  _ProjectChatState createState() => _ProjectChatState();
}

class _ProjectChatState extends State<ProjectChat> {
  @override
  Widget build(BuildContext context) {
    return Message(msg: 'This is a message.').makeChatTile();
  }
}

class Message {
  var name;
  var msg;
  var img;
  var time; //[Note] For now time is in string format
  bool user;
  bool sameUserAsLast;

  Message(
      {this.name,
      this.msg,
      this.img,
      this.time,
      this.user,
      this.sameUserAsLast});

  Widget makeChatTile() {
    return Container(
      child: Column(
        children: <Widget>[
          msgText(),
          Row(
            children: <Widget>[

            ],
          ),
        ],
      ),
    );
  }

  Widget msgText() {
    return Text(
      msg,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
    );
  }


}
