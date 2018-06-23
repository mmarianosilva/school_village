import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../util/user_helper.dart';
import '../message/message.dart';
import 'package:location/location.dart';

class Chat extends StatefulWidget {
  final String conversation;
  final DocumentSnapshot user;
  Chat ({Key key, this.conversation, this.user}) : super(key: key);
  @override
  _ChatState createState() => new _ChatState(conversation, user);
}

class _ChatState extends State<Chat> {

  final TextEditingController _textController = new TextEditingController();
  final String conversation;
  final DocumentSnapshot user;
  final Firestore firestore = Firestore.instance;
  bool isLoaded = false;
  Location _location = new Location();

  _ChatState(this.conversation, this.user);


  void _handleSubmitted(String text) async {
    if(text == null || text.trim() == '') {
      return;
    }
    CollectionReference collection  = Firestore.instance.collection('$conversation/messages');
    final DocumentReference document = collection.document();
    document.setData(<String, dynamic>{
      'body': _textController.text,
      'createdById' : user.documentID,
      'createdBy' : "${user.data['firstName']} ${user.data['lastName']}",
      'createdAt' : new DateTime.now().millisecondsSinceEpoch,
      'location': await _getLocation(),
      'reportedByPhone' : "${user['phone']}"
    });
    _textController.clear();
  }

  _getLocation() async {
    Map<String, double> location;
    String error;
    try {
      location = await _location.getLocation;
      error = null;
    } catch (e) {
      location = null;
    }
    return location;
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text))
            ),
          ],
        ),
      ),                                                             //new
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(                                        //modified
      children: <Widget>[                                         //new
            new Flexible(                                             //new
              child:
              new StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection("$conversation/messages").orderBy("createdAt", descending: true).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return const Text('Loading...');
                    final int messageCount = snapshot.data.documents.length;
                    return new ListView.builder(
                      itemCount: messageCount,
                      reverse: true,
                      padding: new EdgeInsets.all(8.0),
                      itemBuilder: (_, int index) {
                        final DocumentSnapshot document = snapshot.data.documents[index];
                        var createdBy = document['createdBy'].split(" ");
                        var initial =  createdBy[0].length > 0 ? createdBy[0][0] : '';
                        if(createdBy.length > 1) {
                          initial = createdBy[1].length > 0 ? "$initial${createdBy[1][0]}" : "$initial";
                        }
                        return new ChatMessage(
                            text: document['body'],
                            name: "${document['createdBy']}",
                            initial: "$initial",
                            timestamp: document['createdAt'],
                            self: document['createdById'] == user.documentID,
                            location : document['location'],
                            message: document,
                        );
                      },
                    );
                  }
              )                                                      //new
            ),                                                        //new
        new Divider(height: 1.0),                                 //new
        new Container(                                            //new
          decoration: new BoxDecoration(
              color: Theme.of(context).cardColor),                  //new
          child: _buildTextComposer(),                       //modified
        ),                                                        //new
      ],                                                          //new
    );
  }
}