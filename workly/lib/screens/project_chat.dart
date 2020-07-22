import 'package:flutter/material.dart';
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
  ChatStreamPagination _chatStreamPagination;
  final ScrollController _listScrollController = new ScrollController();
  List userUidList;
  List userImageUrlList;

  void getUserListDetails() async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    setState(() {
      userUidList = database.getUserUidList();
      userImageUrlList = database.getUserImageList();
    });
  }

  void refreshUserListDetails() async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    Map _userListDetails = await database.getUserList();
    setState(() {
      userUidList = _userListDetails['userUidList'];
      userImageUrlList = _userListDetails['userImageUrlList'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userUidList == null) {
      getUserListDetails();
      refreshUserListDetails();
    }
    return Column(
      children: <Widget>[
        Expanded(
          //child: Tester.test(),
          child: _buildChatList(),
        ),
        makeTextBar(),
      ],
    );
  }

  Widget makeTextBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF141336),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    bottomLeft: Radius.circular(35),
                  ),
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
          size: 25,
          color: Colors.white
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
    String extractedMsg = _message;
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    setState(() {
      _chatMessageController.clear();
    });
    await database.createNewMessage(extractedMsg);
  }

  @override
  void initState() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    super.initState();
    _chatStreamPagination =
        ChatStreamPagination(projectId: database.getProjectId());
    _listScrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_listScrollController.offset >=
            _listScrollController.position.maxScrollExtent &&
        !_listScrollController.position.outOfRange) {
      _chatStreamPagination.requestMoreData();
    }
  }

  Widget _buildChatList() {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return StreamBuilder<List<ChatMessage>>(
        stream: _chatStreamPagination
            .listenToChatsRealTime(), //database.chatStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chatMessages = snapshot.data;
            final chatList = chatMessages
                .map((chat) => Message(
                      uid: chat.user,
                      name: chat.name,
                      msg: chat.message,
                      img: userImageUrlList[userUidList.indexOf(chat.user)] ==
                              null
                          ? null
                          : NetworkImage(
                              userImageUrlList[userUidList.indexOf(chat.user)]
                                  .toString()),
                      //database.getImageUrl() == null ? null : NetworkImage(database.getImageUrl().toString()),
                      time: chat.time,
                      user: chat.user == database.getUid(),
                      sameUserAsNext: false,
                      isEvent: chat.event,
                      onPress: () => showDeleteDialog(chat.chatId),
                    ))
                .toList();
            cacheChat = chatList;
            return constructChatList(chatList);
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
    cacheChat.add(Message(
        uid: null,
        name: 'Does not matter due to Cache',
        img: null,
        time: time,
        user: true,
        sameUserAsNext: true,
        isEvent: false,
        onPress: () => null,
        msg: cacheString));
    changeLastMsgCache();
    return constructChatList(cacheChat);
  }

  ListView constructChatList(List<Message> chatList) {
    return ListView.builder(
      controller: _listScrollController,
      shrinkWrap: true,
      reverse: true,
      itemCount: chatList.length,
      itemBuilder: (BuildContext context, int idx) {
        final Message draftMsg = chatList[chatList.length - 1 - idx];
        bool _sameUserAsNext = (chatList.length - idx) == chatList.length
            ? false
            : chatList[chatList.length - idx].uid ==
                chatList[chatList.length - 1 - idx].uid;
        final Message msg = Message(
          name: draftMsg.name,
          msg: draftMsg.msg,
          img: draftMsg.img,
          time: draftMsg.time,
          user: draftMsg.user,
          sameUserAsNext: _sameUserAsNext,
          isEvent: draftMsg.isEvent,
          onPress: draftMsg.onPress,
        );
        // if (draftMsg.isEvent) {
        //   refreshUserListDetails();
        //   print("Call refresh list to get new image");
        // }
        return msg.makeChatTile();
      },
    );
  }

  void showDeleteDialog(String chatId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _deleteDialog(chatId);
      },
      barrierDismissible: true,
    );
  }

  Widget _deleteDialog(String chatId) {
    return AlertDialog(
      // title: Text("Delete message"),
      content: Text("Do you really want to delete this message?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
            child: Text("Delete message"),
            onPressed: () => {
                  deleteChatMessage(chatId),
                  Navigator.of(context).pop(),
                }),
      ],
    );
  }

  void deleteChatMessage(String chatId) async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    await database.deleteChatMessage(chatId);
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
  Function onPress;
  String uid;
  var name;
  var msg;
  ImageProvider<dynamic> img;
  var time; //[Note] For now time is in string format
  bool user; //[Note] If this is the user's own msg
  bool sameUserAsNext; //[Note] If this msg is from the same user as the next
  bool
      isEvent; //[Note] False if this message is a proper text, true if this msg is an event (eg. John has joined the group)

  Message(
      {this.onPress,
      this.uid,
      this.name,
      this.msg,
      this.img,
      this.time,
      this.user,
      this.sameUserAsNext,
      this.isEvent});

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

    return GestureDetector(
      onLongPress: onPress,
      child: Container(
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
