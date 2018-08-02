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
  List<MessageHolder> messageList;
  bool disposed = false;
  ScrollController controller;
  FocusNode focusNode = FocusNode();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
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
    CollectionReference collection =
        Firestore.instance.collection('$conversation/messages');
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
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
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

  _handleMessageCollection() {
    if (messageList == null) {
      messageList = List();
    }

    firestore
        .collection("$conversation/messages")
        .orderBy("createdAt")
        .snapshots()
        .listen((data) {
      data.documentChanges.forEach((changes) {
        if (changes.type == DocumentChangeType.added) {
          messageList.insert(0, MessageHolder(null, changes.document));
        }
      });
      data.documents.forEach((shot) {
        var day = DateTime
                .fromMillisecondsSinceEpoch(shot['createdAt'])
                .millisecondsSinceEpoch ~/
            Constants.oneDay;

        var messages = messageMap[day];
        if (messages == null) {
          messages = List();
          messageMap.putIfAbsent(day, () => messages);
        }
        messageMap[day].add(shot);
      });

      messageMap.keys.forEach((key) {
        var time = DateTime.fromMillisecondsSinceEpoch(key * Constants.oneDay);
        var formatter = DateFormat('EEEE, MMMM dd, yyyy');
        String date = formatter.format(time);
        messageList.insert(0, MessageHolder(date, null));

        messageMap[key].forEach((shot) {
          messageList.insert(0, MessageHolder(null, shot));
        });
      });

      if (!disposed) setState(() {});
    });
  }

  Widget _getScreen() {
    if (messageList != null && messageList.length > 0) {
      return ListView.builder(
          itemCount: messageList.length,
          reverse: true,
          controller: controller,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (_, int index) {
            if(messageList[index].date != null){
              return Text(messageList[index].date);
            }


            final DocumentSnapshot document =
                messageList[index].message;
            var createdBy = document['createdBy'].split(" ");
            var initial = createdBy[0].length > 0 ? createdBy[0][0] : '';
            if (createdBy.length > 1) {
              initial = createdBy[1].length > 0
                  ? "$initial${createdBy[1][0]}"
                  : "$initial";
            }

            return ChatMessage(
              text: document['body'],
              name: "${document['createdBy']}",
              initial: "$initial",
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
      children: <Widget>[
        //new
        Flexible(
            //new
            child: SizedBox.expand(
          child: _getScreen(),
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
