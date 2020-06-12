import 'package:flutter/material.dart';

/*
Functionality add-on: Enter to send (probably a TextField constructor field).

How this screen works:
- Message class: To represent a single message with different properties.
  This is also used to generate each widget tile for the chat.
- MessageList class: stores and builds a ListView with input msgs.
- Tester: hardcoded tester that uses messageList class.

Notes:
- Leave image for the message null if user does not have an image.
  An automatic avatar is generated if that's the case.
- ListView builder is efficient.
- Needs to update dynamically with each msg update, instead of having to reload the page.
- need some way to check that 
 */

class ProjectChat extends StatefulWidget {
  @override
  _ProjectChatState createState() => _ProjectChatState();
}

class _ProjectChatState extends State<ProjectChat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Tester.test(),
        ),
        makeTextBar(),
      ],
    );
  }

  Widget makeTextBar() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 25,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
              margin: EdgeInsets.only(left: 20, bottom: 10),
              child: TextField(
                maxLines: 1,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 7, bottom: 8, top: 3, right: 7),
                  hintText: 'Tap to chat',
                  hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black38),
                ),
              ),
            ),
          ),
          sendButton(),
        ],
      ),
    );
  }

  Widget sendButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 7, right: 10, left: 10),
          child: IconButton(
          icon: Icon(
            Icons.send,
            size: 30,
            color: Color(0xFF24DCB7),
          ),
          onPressed: () => null),
    );
  }
}

class MessageList {
  List<Message> messages;

  MessageList({@required this.messages});

  Widget makeList() {
    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int idx) {
        final Message msg = messages[messages.length - 1 - idx];
        return msg.makeChatTile();
      },
    );
  }
}

class Message {
  var name;
  var msg;
  var img;
  var time; //[Note] For now time is in string format
  bool user; //[Note] If this is the user's own msg
  bool sameUserAsNext; //[Note] If this msg is from the same user as the next
  bool
      isEvent; //[Note] False if this message is a proper text, true if this msg is an event (eg. John has joined the group)

  Message(
      {this.name,
      this.msg,
      this.img,
      this.time,
      this.user,
      this.sameUserAsNext,
      this.isEvent});

  //[Action] Maybe can make a method to change the same user as next field

  Widget makeChatTile() {
    if (isEvent) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            msg,
            style: TextStyle(
              color: Colors.black38,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    var notUser = Row(
      children: <Widget>[
        SizedBox(width: 7),
        sameUserAsNext
            ? SizedBox(width: 40)
            : Container(
                alignment: Alignment.bottomCenter,
                child: makeAvatar(),
              ),
        SizedBox(width: 7),
        Flexible(child: this.makeTextTile()),
        SizedBox(width: 30),
      ],
    );

    var isUser = Row(
      children: <Widget>[
        SizedBox(width: 30),
        Expanded(
            child: Container(
                alignment: Alignment.centerRight, child: this.makeTextTile())),
      ],
    );

    return user ? isUser : notUser;
  }

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: user
                ? Color(0xFF00CFF8).withOpacity(0.4)
                : Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 25,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: img,
        backgroundColor: Color(0xFFFCFCFC),
        foregroundColor: Colors.black,
        radius: 20,
        child: img == null
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

  Widget makeTextTile() {
    BorderRadius a;
    if (sameUserAsNext) {
      a = BorderRadius.all(Radius.circular(24));
    } else {
      if (user) {
        a = BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        );
      } else {
        a = BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: user ? Color(0xFF04C9F1) : Color(0xFFE9E9E9),
        borderRadius: a,
        boxShadow: [
          BoxShadow(
            color: user
                ? Color(0xFF00CFF8).withOpacity(0.4)
                : Colors.black38.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 25,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 11, bottom: 11, left: 12, right: 12),
      margin: EdgeInsets.only(
        right: 10,
        bottom: sameUserAsNext ? 12 : 19,
      ),
      child: Column(
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          user ? SizedBox() : nameText(),
          SizedBox(height: 4),
          msgText(),
          SizedBox(height: 5),
          timeText(),
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
        fontSize: 15,
        color: user ? Color(0xFFFCFCFC) : Colors.black87,
      ),
    );
  }

  Widget nameText() {
    return Text(
      name,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: Color(0xFF141336),
      ),
    );
  }

  Widget timeText() {
    return Text(
      time,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: user ? Colors.white70 : Colors.black38,
      ),
    );
  }
}

class Tester {
  static Widget test() {
    List<Message> list = [
      Message(
        isEvent: true,
        msg: 'Some guy has joined this group',
      ),
      Message(
        name: 'Some guy',
        msg: 'Something about work.',
        time: '11:35',
        user: false,
        sameUserAsNext: true,
        img: AssetImage('assets/fb_icon.png'),
        isEvent: false,
      ),
      Message(
        name: 'Some guy',
        msg:
            'This is a long message just to test the system. Here\'s another line',
        time: '14:00',
        user: false,
        sameUserAsNext: false,
        img: AssetImage('assets/fb_icon.png'),
        isEvent: false,
      ),
      Message(
        name: 'Me',
        msg: 'This is a message.',
        time: '15:00',
        user: true,
        sameUserAsNext: true,
        img: AssetImage('assets/sign_in_graphics.png'),
        isEvent: false,
      ),
      Message(
        name: 'Me',
        msg:
            'This would be a follow-up message with a longer string of words and characters.',
        time: '15:01',
        user: true,
        sameUserAsNext: false,
        img: AssetImage('assets/sign_in_graphics.png'),
        isEvent: false,
      ),
      Message(
        name: 'Some other guy',
        msg: 'Generic reply.',
        time: '17:23',
        user: false,
        sameUserAsNext: false,
        isEvent: false,
      ),
    ];

    return MessageList(messages: list).makeList();
  }
}
