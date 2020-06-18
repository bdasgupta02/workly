import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/services/project_database.dart';
import 'package:workly/models/idea.dart';

_ProjectIdeasState projectIdeasState;

class ProjectIdeas extends StatefulWidget {
  @override
  _ProjectIdeasState createState() => _ProjectIdeasState();
}

class _ProjectIdeasState extends State<ProjectIdeas> {
  final FocusNode _ideaNameFocusNode = FocusNode();
  final FocusNode _ideaDescriptionFocusNode = FocusNode();
  final TextEditingController _ideaNameController = TextEditingController();
  final TextEditingController _ideaDescriptionController =
      TextEditingController();
  bool _ideaNameValid = true;
  bool _ideaDescValid = true;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      // body: Tester.test(),
      body: _buildIdeaList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => {//updateVote(),//addNewIdea(),
          setState(() {
              _ideaNameController.clear();
              _ideaDescriptionController.clear();
              _ideaNameValid = true;
              _ideaDescValid = true;
          }),
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildIdeaForm(database);
            },
            barrierDismissible: true,
          ),
        },
      ),
    );
  }

  Widget _buildIdeaForm(ProjectDatabase database) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(48.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(48)),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Close",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => {
                          Navigator.of(context).pop(),
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34.0),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        _ideaNameField(),
                        SizedBox(
                          height: 25,
                        ),
                        _ideaDescriptionField(),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () => {
                          if (_ideaName.isEmpty || _ideaDescription.isEmpty) {
                            setState(() {
                              _ideaNameValid = _ideaName.isNotEmpty;
                              _ideaDescValid = _ideaDescription.isNotEmpty;
                            }),
                          } else {
                            addNewIdea(),
                          }
                        },
                        child: Text(
                          "Add my Idea!",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        color: Colors.red[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }

  String get _ideaName => _ideaNameController.text;
  String get _ideaDescription => _ideaDescriptionController.text;

  Widget _ideaNameField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Idea Name",
        hintText: "Name of your idea",
        errorText: _ideaNameValid ? null : "Please fill in a name",
      ),
      controller: _ideaNameController,
      textInputAction: TextInputAction.next,
      focusNode: _ideaNameFocusNode,
      onChanged: (name) => _updateState(),
      onEditingComplete: () => _ideaNameEditingComplete(),
      showCursor: true,
      textAlign: TextAlign.start,
    );
  }

  Widget _ideaDescriptionField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        labelText: "Idea Description",
        hintText: "Description for your idea",
        errorText: _ideaDescValid ? null : "Please fill in some description",
      ),
      controller: _ideaDescriptionController,
      textInputAction: TextInputAction.next,
      focusNode: _ideaDescriptionFocusNode,
      onChanged: (desc) => _updateState(),
      onEditingComplete: () => addNewIdea(),
      maxLines: null,
      showCursor: true,
      maxLengthEnforced: true,
      maxLength: 500,
      textAlign: TextAlign.start,
    );
  }

  void _ideaNameEditingComplete() {
    final newFocus = _ideaName.trim().isNotEmpty
        ? _ideaDescriptionFocusNode
        : _ideaNameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void addNewIdea() async {
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    String _ideaId = DateTime.now().toString();
    await database.createIdea(_ideaId, {
      "name": database.getUserName(),
      "user": database.getUid(),
      "title": _ideaName,
      "description": _ideaDescription,
      "ideaId": _ideaId,
      "votes": [],
      "voteCount": 0,
    });
    Navigator.of(context).pop();
  }

  Widget _buildIdeaList() {
  final database = Provider.of<ProjectDatabase>(context, listen: false);
    return StreamBuilder<List<Idea>>(
      stream: database.ideaStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("PrinT");
          final ideaItem = snapshot.data;
          final ideas = ideaItem
              .map((idea) => IdeaTile(
                 title: idea.title, idea: idea.description, votes: idea.voteCount, ideaId: idea.ideaId, database: database)).toList();
          return IdeaList(ideas: ideas).makeList();
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });
  }

  void updateVote() async {
    print("TESTUPDATE");
    final database = Provider.of<ProjectDatabase>(context, listen: false);
    await database.updateVotes("2020-06-17 14:56:53.873491");
  }
}

class IdeaList {
  List<IdeaTile> ideas;

  IdeaList({@required this.ideas});

  Widget makeList() {
    List<Widget> list = [];
    list.add(SizedBox(height: 40));
    for (IdeaTile i in ideas) {
      list.add(i.makeIdeaTile());
    }
    return ListView(children: list);
  }
}

//[Note] This class is only to generate the tiles for this list.
// We should make this class outside if we want to extend this to other screens.
class IdeaTile {
  var title;
  var idea;
  var votes;
  String ideaId;
  ProjectDatabase database;

  IdeaTile({@required this.title, @required this.idea, @required this.votes, @required ideaId, @required database});

  Widget makeIdeaTile() {
    String newIdea = idea;//idea.length > 65 ? idea.substring(0, 65) + '...' : idea;
    String newTitle =
        title.length > 65 ? title.substring(0, 65) + '...' : title;

    //[Note] This is for ONPRESSED
    Function _goToVoteAction = () => projectIdeasState.updateVote();
    
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10, bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF141336),
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(3, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCFCFC),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: () {
                  print("BODY");
                  projectIdeasState.updateVote();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              right: 0,
                              left: 0,
                              bottom: 3,
                            ),
                            child: Text(
                              newTitle,
                              style: TextStyle(
                                color: Color(0xFF141336),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 3,
                              right: 0,
                              left: 0,
                              bottom: 15,
                            ),
                            child: Text(
                              newIdea,
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'Roboto',
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => projectIdeasState.updateVote(),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        right: 10,
                        bottom: 3,
                      ),
                      child: Text(
                        'Votes',
                        style: TextStyle(
                          color: Color(0xFFFCFCFC),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 3,
                        right: 10,
                        bottom: 15,
                      ),
                      child: Text(
                        votes.toString(),
                        style: TextStyle(
                          color: Color(0xFFFCFCFC),
                          fontFamily: 'Roboto',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class Tester {
//   static Widget test() {
//     var ideas = [
//       IdeaTile(title: 'Test title', idea: 'test idea', votes: 2),
//       IdeaTile(
//           title: 'Test title 2',
//           idea:
//               'test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2',
//           votes: 7),
//       IdeaTile(title: 'Test title 3', idea: 'test idea 3', votes: 0),
//       IdeaTile(title: 'Test title 4', idea: 'test idea 4', votes: 23),
//     ];

//     return IdeaList(ideas: ideas).makeList();
//   }
// }
