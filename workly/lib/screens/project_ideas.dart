import 'package:flutter/material.dart';

class ProjectIdeas extends StatefulWidget {
  @override
  _ProjectIdeasState createState() => _ProjectIdeasState();
}

class _ProjectIdeasState extends State<ProjectIdeas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      body: Tester.test(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF06D8AE),
        onPressed: () => null,
      ),
    );
  }
}

class IdeaList {
  List<Idea> ideas;

  IdeaList({@required this.ideas});

  Widget makeList() {
    List<Widget> list = [];
    list.add(SizedBox(height: 40));
    for (Idea i in ideas) {
      list.add(i.makeIdeaTile());
    }
    return ListView(children: list);
  }
}

//[Note] This class is only to generate the tiles for this list.
// We should make this class outside if we want to extend this to other screens.
class Idea {
  var title;
  var idea;
  var votes;

  Idea({@required this.title, @required this.idea, @required this.votes});

  Widget makeIdeaTile() {
    String newIdea = idea.length > 65 ? idea.substring(0, 65) + '...' : idea;
    String newTitle =
        title.length > 65 ? title.substring(0, 65) + '...' : title;

    //[Note] This is for ONPRESSED
    Function _goToSubScreen = () => null;

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
                onPressed: _goToSubScreen,
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
              onTap: _goToSubScreen,
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

class Tester {
  static Widget test() {
    var ideas = [
      Idea(title: 'Test title', idea: 'test idea', votes: 2),
      Idea(
          title: 'Test title 2',
          idea:
              'test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2 test idea 2',
          votes: 7),
      Idea(title: 'Test title 3', idea: 'test idea 3', votes: 0),
      Idea(title: 'Test title 4', idea: 'test idea 4', votes: 23),
    ];

    return IdeaList(ideas: ideas).makeList();
  }
}
