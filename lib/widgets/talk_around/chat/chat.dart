import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/constants.dart';
import '../message/message.dart';
import 'package:location/location.dart';

class Chat extends StatefulWidget {
  final String conversation;
  final DocumentSnapshot user;

  Chat({Key key, this.conversation, this.user}) : super(key: key);

  @override
  createState() => _ChatState(conversation, user);
}

class _ChatState extends State<Chat> {
  final TextEditingController _textController = TextEditingController();
  final String conversation;
  final DocumentSnapshot user;
  final Firestore firestore = Firestore.instance;
  Location _location = Location();
  List<MessageHolder> messageList = List();
  bool disposed = false;
  ScrollController controller;
  FocusNode focusNode = FocusNode();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  var dateFormatter = DateFormat('EEEE, MMMM dd, yyyy');

  _ChatState(this.conversation, this.user);

  @override
  initState() {
    _handleMessageCollection();
    controller = ScrollController();
    controller.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (!focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  dispose() {
    disposed = true;
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text == null || text.trim() == '') {
      return;
    }
    CollectionReference collection = Firestore.instance.collection('$conversation/messages');
    final DocumentReference document = collection.document();
    document.setData(<String, dynamic>{
      'body': _textController.text,
      'createdById': user.documentID,
      'createdBy': "${user.data['firstName']} ${user.data['lastName']}",
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'location': await _getLocation(),
      'reportedByPhone': "${user['phone']}"
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
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text))),
          ],
        ),
      ), //new
    );
  }

  _convertDateToKey(createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).millisecondsSinceEpoch ~/
        Constants.oneDay;
  }

  _getHeaderItem(day) {
    var time = DateTime.fromMillisecondsSinceEpoch(day * Constants.oneDay);
    String date = dateFormatter.format(time);
    return MessageHolder(date, null);
  }

  _handleMessageMapInsert(shot) {
    var day = _convertDateToKey(shot['createdAt']);

    var messages = messageMap[day];
    var message = MessageHolder(null, shot);
    if (messages == null) {
      messages = List();
      messageMap[day] = messages;
      messageList.insert(0, _getHeaderItem(day));
      messageList.insert(0, message);
    } else {
      messageList.insert(0, message);
    }
    messageMap[day].add(shot);
    _updateState();
  }

  _handleDocumentChanges(documentChanges) {
    documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        _handleMessageMapInsert(change.document);
      }
    });
  }

  _updateState() {
    if (!disposed) setState(() {});
  }

  _handleMessageCollection() {
    firestore.collection("$conversation/messages").orderBy("createdAt").snapshots().listen((data) {
      _handleDocumentChanges(data.documentChanges);
    });
  }

  Widget _getScreen() {
    if (messageList.length > 0) {
      return ListView.builder(
          itemCount: messageList.length,
          reverse: true,
          controller: controller,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (_, int index) {
            if (messageList[index].date != null) {
              return Container(
                child: Stack(
                  children: [
                    Container(
                        height: 12.0,
                        child: Center(
                            child: Container(
                          height: 1.0,
                          decoration: BoxDecoration(color: Colors.black12),
                        ))),
                    Container(
                      color: Colors.white,
                      child: Center(
                          child: Text(
                        messageList[index].date,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.0),
                      )),
                      margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                    )
                  ],
                ),
              );
            }

            final DocumentSnapshot document = messageList[index].message;
            return ChatMessage(
              text: document['body'],
              name: "${document['createdBy']}",
              timestamp: document['createdAt'],
              self: document['createdById'] == user.documentID,
              location: document['location'],
              message: document,
            );
          });
    }
    return const Center(
      child: const Text('Loading...'),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      //modified
      children: [
        //new
        Flexible(
            //new
            child: SizedBox.expand(
          child: Container(color: Colors.white,child: _getScreen()),
        )), //new
        Divider(height: 1.0), //new
        Container(
          //new
          decoration: BoxDecoration(color: Theme.of(context).cardColor), //new
          child: _buildTextComposer(), //modified
        ), //new
      ], //new
    );
  }
}
