import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workly/models/idea_comment.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/screens/project_ideas.dart';
import 'package:workly/services/project_database.dart';

/*
  How this works:
  - IdeaPage class: generates the top card of the screen with the idea details,
    edit and delete buttons, and vote button. Functional in the front-end as I've 
    already made it work through a cache system for instant feedback, and functions 
    need to be filled where commented.
  - Comment class: represents a single comment and generates a widget for it. The screen
    state class has methods to generate a widget column based on a list of comments. This
    method also adds a text field and button to send a comment.
  - The state is external so that the IdeaPage can refresh the state class based on the cache.

  Some notes:
  - The idea title and body switches between text and text field, 
    because of the fact that text has auto-wrapping but text field 
    has a fixed number of hard-coded maxLines. 
  - Need to add blank text field validation for the input of title and body fields.
  - Edit button only appears if this is the user that is the original creator
    of the idea.
  - The comment text field changes the amount of lines based on how long the user's input is.
    
  Thoughts on calling from DB and saving:
  - Can use StreamBuilder for IdeaPage widget but what if you query it once in initState() or something
    and only upload it back onSave, never querying it again in this screen's
    lifetime. Not sure if this will work, but it will remove the whole StreamBuilder
    load time.
  - However, comment list system needs to run separately maybe? With a StreamBuilder due 
    to a listener for received updates. It's fine if there's a loading time when the user sends
    a new comment.
 */
_IdeaViewState ideaViewState;

class IdeaView extends StatefulWidget {
  final bool isUser;
  final int votes;
  final bool hasVoted;
  final String title;
  final String idea;
  final String ideaId;
  final ProjectDatabase database;

  IdeaView({@required this.isUser, @required this.votes, @required this.hasVoted, @required this.title, @required this.idea, @required this.ideaId, @required this.database});

  @override
  _IdeaViewState createState() {
    ideaViewState = _IdeaViewState();
    return ideaViewState;
  }
}

class _IdeaViewState extends State<IdeaView> {
  TextEditingController _commentController = TextEditingController();
  bool _readOnly = true;
  IdeaPage idea;
  List userUidList;
  List userImageUrlList;

  @override
  void initState() {
    super.initState();

    idea = IdeaPage(
      isUser: widget.isUser,
      votes: widget.votes,
      hasVoted: widget.hasVoted,
      title: widget.title,
      idea: widget.idea,
      onDelete: () => showDeleteDialog(null, null, false),
      voteOrUnvote: () => projectIdeasState.updateVote(widget.ideaId),
      onEdit: () => editIdea(),
      onSave: (String title, String idea) => saveIdea(title, idea),
    );
  }

  void saveIdea(String title, String idea) {
    setState(() {
      _readOnly = true;
    });
    projectIdeasState.updateIdeaDetails(widget.ideaId, title, idea);
  }

  void editIdea() {
    //TODO: Code to go here to edit the idea, but this should be enough I think

    setState(() {
      _readOnly = false;
    });
  }

  void getUserListDetails() {
    setState(() {
      userUidList = widget.database.getUserUidList();
      userImageUrlList = widget.database.getUserImageList();
    });
  }

  void refreshUserListDetails() async {
    Map _userListDetails = await widget.database.getUserList();
    setState(() {
      userUidList = _userListDetails['userUidList'];
      userImageUrlList = _userListDetails['userImageUrlList'];
    });
  }

  //TODO: Stream builder for the second card with the comment list, and either
  //query or stream builder for the ideaPage card (more notes on top).
  @override
  Widget build(BuildContext context) {
    if (userUidList == null) {
      getUserListDetails();
      refreshUserListDetails();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141336),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFFFCFCFC),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Color(0xFFE9E9E9),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 10,
                  bottom: 20,
                ),
                child: Text(
                  'View Idea',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w400,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: _readOnly ? idea.toWidgetView() : idea.toWidgetEdit(),
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
              ),
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: _buildCommentList(),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addCommentForm() {
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
      margin: EdgeInsets.only(left: 15, bottom: 15, top: 25, right: 15),
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
                      color: Colors.black38.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 12,
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
                    hintText: 'Tap to comment',
                    hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black38),
                  ),
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 1,
                  maxLengthEnforced: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            commentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    return StreamBuilder<List<IdeaComment>>(
      stream: widget.database.ideaCommentStream(widget.ideaId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final ideaCommentItem = snapshot.data;
          final comments = ideaCommentItem
              .map((com) => Comment(
                  uid: com.user,
                  name: com.name,
                  comment: com.comment,
                  commentId: com.commentId,
                  image: userImageUrlList[userUidList.indexOf(com.user)] == null ? null : NetworkImage(userImageUrlList[userUidList.indexOf(com.user)].toString()),
                  onPress: () => com.user == widget.database.getUid() ? showDeleteDialog(com.comment, com.commentId, true) : null,
                  ))
              .toList();
          return commentColBuilder(comments);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget commentColBuilder(List comments) {
    List<Widget> widgets = [];
    widgets.add(headingText("Comments"));
    for (int i = 0; i < comments.length; i++) {
      widgets.add(comments[i].toWidget());
      if (i == comments.length - 1) widgets.add(addCommentForm());
    }
    if (comments.length == 0) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(top: 15),
          child: Center(
            child: Text(
              "There are no comments!",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      widgets.add(addCommentForm());
    }
    return Column(
      children: widgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 12,
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

  Widget commentButton() {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      child: IconButton(
        icon: Icon(
          Icons.send,
          size: 25,
          color: Colors.white,
        ),
        onPressed: () => _commentController.text.isEmpty ? null : onSendComment(),
      ),
    );
  }

  void onSendComment() async {
    String _commentId = DateTime.now().toString();
    await widget.database.createIdeaComment(widget.title, widget.ideaId, _commentId, {
      "name": widget.database.getUserName(),
      "user": widget.database.getUid(),
      "time": FieldValue.serverTimestamp(),
      "comment": _commentController.text,
      "commentId": _commentId,
    });
    setState(() {
      _commentController.clear();
    });
  }

  void onDeleteComment(String comment, String commentId) async {
    await widget.database.deleteIdeaComment(comment, widget.title, widget.ideaId, commentId);
  }
  
  void showDeleteDialog(String commentContent, String commentId, bool comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _deleteDialog(commentContent, commentId, comment);
      },
      barrierDismissible: true,
    );
  }

  Widget _deleteDialog(String commentContent, String commentId, bool comment) {
    String verb = comment ? "comment" : "idea";
    return AlertDialog(
      title: Text("Wait..."),
      content: Text(
          "Do you really want to delete this $verb?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Yes, delete $verb"),
          onPressed: () => {
            comment ? deleteIdeaComment(commentContent, commentId) : projectIdeasState.deleteIdea(widget.title, widget.ideaId),
            Navigator.of(context).pop(),
          },
        ),
      ],
    );
  }

  void deleteIdeaComment(String comment, String commentId) async {
    await widget.database.deleteIdeaComment(comment, widget.title, widget.ideaId, commentId);
  }

  void refresh() {
    setState(() {});
  }
}

class IdeaPage {
  Function onEdit;
  Function onDelete;
  Function onSave;
  Function voteOrUnvote;
  TextEditingController _titleController;
  TextEditingController _ideaController;
  bool _readOnly;
  bool isUser;
  int votes;
  bool hasVoted;
  String title;
  String idea;

  IdeaPage({
    @required this.isUser,
    @required this.votes,
    @required this.title,
    @required this.idea,
    @required this.onDelete,
    @required this.onEdit,
    @required this.onSave,
    @required this.hasVoted,
    @required this.voteOrUnvote,
  }) {
    _titleController = TextEditingController();
    _ideaController = TextEditingController();
    _titleController.text = title;
    _ideaController.text = idea;
  }

  Widget toWidgetEdit() {
    _readOnly = false;
    return toWidget();
  }

  Widget toWidgetView() {
    _readOnly = true;
    return toWidget();
  }

  void setTitle(String s) {
    _titleController.text = s;
    title = s;
  }

  void setIdea(String s) {
    _ideaController.text = s;
    idea = s;
  }

  String get ideaTitle {
    return title;
  }

  String get ideaBody {
    return idea;
  }

  Widget toWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 8),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 19,
                        ),
                      )
                    : TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 19,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: _readOnly,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          labelText: "Idea title",
                          hintText: "Title of your idea",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: Row(
            children: <Widget>[
              Flexible(
                child: _readOnly
                    ? Text(
                        idea,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      )
                    : TextField(
                        controller: _ideaController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: _readOnly,
                        maxLines: 6,
                        minLines: 1,
                        decoration: InputDecoration(
                          labelText: "Idea body",
                          hintText: "Your idea",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: isUser ? 20 : 0),
        isUser ? editSaveButton() : SizedBox(),
        isUser ? deleteButton() : SizedBox(),
        voteWindow(),
        SizedBox(height: isUser ? 5 : 0),
      ],
    );
  }

  Widget voteWindow() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 10),
      padding: EdgeInsets.only(left: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Votes for this idea: $votes",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ),
          voteButton(),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
    );
  }

  Widget voteButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: FlatButton(
          color: !hasVoted ? Color(0xFF06D8AE) : Color(0xFFE9E9E9),
          onPressed: () {
            voteOrUnvote.call();
            hasVoted = !hasVoted;
            if (hasVoted) {
              votes++;
            } else {
              votes--;
            }
            ideaViewState.refresh();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                !hasVoted ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 40,
                color: !hasVoted ? Colors.white : Colors.black45,
              ),
              Text(
                hasVoted ? "Unvote" : "Vote",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: !hasVoted ? Colors.white : Colors.black45,
                ),
              ),
              SizedBox(height: 6),
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: hasVoted
                  ? Color(0xFF06D8AE).withOpacity(0.3)
                  : Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget editSaveButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FlatButton(
        color: Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: _readOnly
            ? onEdit
            : () {
                onSave.call(_titleController.text, _ideaController.text);
                //[Note] Local cache below.
                setTitle(_titleController.text);
                setIdea(_ideaController.text);
              },
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              _readOnly ? "Edit idea" : "Save changes",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget deleteButton() {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FlatButton(
        color: Colors.redAccent,
        child: Row(
          children: <Widget>[
            Spacer(),
            Text(
              "Delete idea",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFFFCFCFC),
              ),
            ),
            Spacer(),
          ],
        ),
        onPressed: onDelete,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
    );
  }
}

class Comment {
  String commentId;
  String uid;
  String name;
  String comment;
  ImageProvider<dynamic> image;
  Function onPress;

  Comment({
    @required this.commentId,
    @required this.uid,
    @required this.name,
    @required this.comment,
    this.image,
    @required this.onPress,
  });

  Widget toWidget() {
    return GestureDetector(
      onLongPress: onPress,
      child: Container(
        margin: EdgeInsets.only(
          top: 10,
          right: 10,
          left: 10,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                makeAvatar(),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12, left: 12),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      comment,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        top: 12,
        right: 6,
        left: 12,
      ),
      width: 24,
      height: 24,
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
        radius: 12,
        child: image == null
            ? Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  fontSize: 10,
                ),
              )
            : SizedBox(),
      ),
    );
  }
}
