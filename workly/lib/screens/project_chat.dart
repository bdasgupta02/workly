import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import 'package:workly/models/chat_message.dart';
import 'package:workly/services/project_database.dart';

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
  final TextEditingController _chatMessageController = TextEditingController();
  String cacheString = "";
  List<Message> cacheChat = [];
  List<Message> chatList = [];
  List<Message> partition = [];
  int currentLength = 0;
  final int increment = 10;
  bool isLoading = false;
  bool start = true;
  bool initial = true;
  int msgsSent = 0;
  int partLoaded = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future _loadMore() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 0));
    // [Note] I made these two different adding methods due to the
    // fact that the listview is backwards and adds both ways for
    // our cache technique and loading more.
    for (var i = currentLength;
        i <= currentLength + increment && i < chatList.length - msgsSent;
        i++) {
      if (!start) {
        print("Chat Log: add backward");
        List<Message> temp = [chatList[chatList.length - i - 1]];
        for (var j = 0; j < partition.length; j++) temp.add(partition[j]);
        partition = temp;
      } else {
        print("Chat Log: add forward");
        List<Message> temp = [chatList[i]];
        for (var j = 0; j < partition.length; j++) temp.add(partition[j]);
        partition = temp;
      }
    }
    start = false;
    setState(() {
      isLoading = false;
      currentLength = partition.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildChatList(),
        ),
        makeTextBar(),
      ],
    );
  }

  Widget makeTextBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, bottom: 10),
      child: IntrinsicHeight(
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
                child: TextField(
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 7, right: 7),
                    hintText: 'Tap to chat',
                    hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black38),
                  ),
                  controller: _chatMessageController,
                  onChanged: (message) => {
                    setState(() {
                      cacheString = message;
                    }),
                  },
                  maxLines: null,
                  maxLengthEnforced: true,
                  maxLength: 500,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            sendButton(),
          ],
        ),
      ),
    );
  }

  String get _message => _chatMessageController.text;

  Widget sendButton() {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: IconButton(
        icon: Icon(
          Icons.send,
          size: 30,
          color: Color(0xFF24DCB7),
        ),
        onPressed: () => _message.isEmpty ? null : sendMessage(),
      ),
    );
  }

  void changeLastMsgCache() {
    if (cacheChat.length > 1) {
      if (cacheChat[cacheChat.length - 1]
          .testPrevious(cacheChat[cacheChat.length - 2])) {
        cacheChat[cacheChat.length - 2].changeUserAsNext(true);
      }
    }
  }

  void sendMessage() async {
    msgsSent++;
    String extractedMsg = _message;
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    setState(() {
      _chatMessageController.clear();
    });
    await database.createNewMessage(extractedMsg);
  }

  Widget _buildChatList() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return StreamBuilder<List<ChatMessage>>(
        stream: database.chatStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chatMessages = snapshot.data;
            chatList = chatMessages
                .map((chat) => Message(
                    name: chat.name,
                    msg: chat.message,
                    time: chat.time,
                    user: chat.user == database.getUid(),
                    chatId: chat.chatId,
                    sameUserAsNext: false,
                    isEvent: chat.event))
                .toList();
            cacheChat = chatList;
            if (partition.length < 10) {
              _loadMore();
            }
            if (partition.length > 1 &&
                chatList.length > 1 &&
                chatList[chatList.length - 1]
                    .isSame(partition[partition.length - 1])) {
              partition.add(chatList[chatList.length - 1]);
            }
            return LazyLoadScrollView(
              isLoading: isLoading,
              onEndOfPage: () => _loadMore(),
              child: constructChatList(false),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return addCache();
          } else {
            return addCache();
          }
        });
  }

  Widget addCache() {
    String hourZero = DateTime.now().hour < 10
        ? "0" + DateTime.now().hour.toString()
        : DateTime.now().hour.toString();
    String minuteZero = DateTime.now().minute < 10
        ? "0" + DateTime.now().minute.toString()
        : DateTime.now().minute.toString();
    String time = hourZero + ":" + minuteZero;
    Message m = Message(
      name: 'Does not matter due to Cache',
      img: null,
      time: time,
      user: true,
      sameUserAsNext: true,
      isEvent: false,
      msg: cacheString,
    );
    partition.add(m);
    cacheChat.add(m);
    changeLastMsgCache();
    return constructChatList(true);
  }

  ListView constructChatList(bool useCache) {
    print(partition.length);
    List<Message> list;
    if (initial) useCache = false;
    if (initial && !useCache) {
      list = chatList;
      initial = false;
    } else if (useCache) {
      if (partLoaded > 1) {
        list = partition;
      } else {
        list = cacheChat;
      }
    } else {
      partLoaded++;
      list = partition;
    }
    if (partLoaded == 1) {
      partition.clear();
    }
    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int idx) {
        print(isLoading);
        if (partition.length != chatList.length &&
            idx == partition.length - 1) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 20,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final Message draftMsg = list[list.length - 1 - idx];
        bool _sameUserAsNext = (list.length - idx) == list.length
            ? false
            : list[list.length - idx].user == list[list.length - 1 - idx].user;
        final Message msg = Message(
            name: draftMsg.name,
            msg: draftMsg.msg,
            time: draftMsg.time,
            user: draftMsg.user,
            sameUserAsNext: _sameUserAsNext,
            isEvent: draftMsg.isEvent);
        return msg.makeChatTile();
      },
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
  ImageProvider<dynamic> img;
  var time; //[Note] For now time is in string format
  String chatId;
  bool user; //[Note] If this is the user's own msg
  bool sameUserAsNext; //[Note] If this msg is from the same user as the next
  bool
      isEvent; //[Note] False if this message is a proper text, true if this msg is an event (eg. John has joined the group)

  Message({
    this.name,
    this.msg,
    this.img,
    this.time,
    this.user,
    this.sameUserAsNext,
    this.isEvent,
    this.chatId,
  });

  bool isSame(Message other) {
    return this.chatId == other.chatId;
  }

  //[Note] This method changes this msg's properties to indicate if it's from the same user as the next msg.
  // Once the same user texts another msg after this one, this field for this msg needs to be changed to true
  // and the screen's ListView needs to be rebuilt.
  void changeUserAsNext(bool b) {
    sameUserAsNext = b;
  }

  bool testPrevious(Message other) {
    return this.user == true && other.user == true;
  }

  String getMsg() {
    return this.msg;
  }

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
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 11, bottom: 11, left: 12, right: 12),
      margin: EdgeInsets.only(
        right: 10,
        bottom: sameUserAsNext ? 8 : 25,
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
