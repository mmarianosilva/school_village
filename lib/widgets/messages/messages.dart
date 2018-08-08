import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/components/messages_input_field.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/widgets/messages/broadcast_message.dart';
import '../../util/user_helper.dart';
import 'package:school_village/util/constants.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  FirebaseUser _userId;
  String name = '';
  String _schoolId = '';
  var isLoaded = false;
  DocumentReference _userRef;
  List<String> _groups = List<String>();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  List<MessageHolder> messageList = List();
  var disposed = false;
  ScrollController _scrollController;
  final focusNode = FocusNode();
  InputField inputField;

  getUserDetails() async {
    _userId = await UserHelper.getUser();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = Firestore.instance.document("users/${_userId.uid}");
    _userRef.get().then((user) {
      var keys = user.data["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = List<String>();
      for (int i = 0; i < keys.length; i++) {
        if (user.data["associatedSchools"][schoolId]["groups"][keys.elementAt(i)] == true) {
          groups.add(keys.elementAt(i));
        }
      }
      setState(() {
        _schoolId = schoolId;
        _groups = groups;
        isLoaded = true;
        _handleMessageCollection();
      });
    });
  }

  belongsToGroup(messageGroup) {
    for (int i = 0; i < messageGroup.length; i++) {
      for (int j = 0; j < _groups.length; j++) {
        if (_groups.elementAt(j) == messageGroup.elementAt(i)) {
          return true;
        }
      }
    }
    return false;
  }

  _convertDateToKey(createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).millisecondsSinceEpoch ~/ Constants.oneDay;
  }

  _getHeaderItem(day) {
    var time = DateTime.fromMillisecondsSinceEpoch(day * Constants.oneDay);
    return MessageHolder(getHeaderDate(time.millisecondsSinceEpoch), null);
  }

  _handleMessageMapInsert(shot) {

    if (!belongsToGroup(shot['groups'].keys)) {
      return;
    }
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

  @override
  initState() {

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    inputField = InputField(sendPressed: (image, text) {
//      _handleSubmitted(image, text);
    });

    super.initState();
  }

  _updateState() {
    if (!disposed) setState(() {});
  }

  _scrollListener() {
    if (!focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  dispose() {
    disposed = true;
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  _handleMessageCollection() {
    Firestore.instance.collection("schools/$_schoolId/broadcasts").orderBy("createdAt").snapshots().listen((data) {
      _handleDocumentChanges(data.documentChanges);
    });
  }

  _handleDocumentChanges(documentChanges) {
    documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        _handleMessageMapInsert(change.document);
      }
    });
  }

  _getScreen() {
    if (messageList.length > 0 && isLoaded) {
      return ListView.builder(
          itemCount: messageList.length,
          reverse: true,
          controller: _scrollController,
          padding: Constants.messagesHorizontalMargin,
          itemBuilder: (_, int index) {
            if (messageList[index].date != null) {
              return Container(
                margin: EdgeInsets.only(top: 30.0),
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
                        style: TextStyle(fontSize: 12.0, letterSpacing: 1.1),
                      )),
                      margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                    )
                  ],
                ),
              );
            }

            final DocumentSnapshot document = messageList[index].message;
            return BroadcastMessage(
              text: document['body'],
              name: "${document['createdBy']}",
              timestamp: document['createdAt'],
//              self: document['createdById'] == user.documentID,
              location: document['location'],
              imageUrl: document['image'],
              message: document,
            );
          });
    }
    return const Center(
      child: const Text('Loading...'),
    );

  }

  @override
  build(BuildContext context) {
    if(!isLoaded){
      getUserDetails();
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: Text('Messages', textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body:Column(children: [
          Expanded(
            child: Container(color: Colors.white, child: _getScreen()),
          ), //new
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 14.0),
            child: inputField,
          )
        ])
    );
  }
}
