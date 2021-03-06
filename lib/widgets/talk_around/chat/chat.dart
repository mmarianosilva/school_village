import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_village/components/messages_input_field.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/date_formatter.dart';
import '../message/message.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat extends StatefulWidget {
  final String conversation;
  final DocumentSnapshot user;

  Chat({Key key, this.conversation, this.user}) : super(key: key);

  @override
  createState() => _ChatState(conversation, user);
}

class _ChatState extends State<Chat> {
  static FirebaseStorage storage = FirebaseStorage();
  final String conversation;
  final DocumentSnapshot user;
  final Firestore firestore = Firestore.instance;
  Location _location = Location();
  List<MessageHolder> messageList = List();
  bool disposed = false;
  ScrollController _scrollController;
  final focusNode = FocusNode();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  bool isLoaded = false;

  InputField inputField;

  _ChatState(this.conversation, this.user);

  @override
  initState() {
    _handleMessageCollection();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    inputField = InputField(sendPressed: (image, text) {
      _handleSubmitted(image, text);
    });

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
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  _handleSubmitted(File image, String text) async {
    if (text == null || text.trim() == '') {
      return;
    }
    CollectionReference collection = Firestore.instance.collection('$conversation/messages');
    final DocumentReference document = collection.document();
    var path = '';
    if (image != null) {
      _showLoading();
      path = '${conversation[0].toUpperCase()}${conversation.substring(1)}/${document.documentID}';
      String type = 'jpeg';
      type = lookupMimeType(image.path).split("/").length > 1 ? lookupMimeType(image.path).split("/")[1] : type;
      path = path + "." + type;
      print(path);
      await uploadFile(path, image);
      _hideLoading();
    }
    document.setData(<String, dynamic>{
      'body': text,
      'createdById': user.documentID,
      'createdBy': "${user.data['firstName']} ${user.data['lastName']}",
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'location': await _getLocation(),
      'image': image == null ? null : path,
      'reportedByPhone': "${user['phone']}"
    });
    //FIXME: not good practice
    inputField.key.currentState.clearState();
  }

  uploadFile(String path, File file) async {
    final StorageReference ref = storage.ref().child(path);
    final StorageUploadTask uploadTask = ref.putFile(file);
    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    return downloadUrl;
  }

  _showLoading() {}

  _hideLoading() {}

  _getLocation() async {
    Map<String, double> location;
    String error;
    try {
      location = await _location.getLocation();
      error = null;
    } catch (e) {
      location = null;
    }
    return location;
  }

  static const horizontalMargin = const EdgeInsets.symmetric(horizontal: 25.0);

  _convertDateToKey(createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).millisecondsSinceEpoch ~/ Constants.oneDay;
  }

  _getHeaderItem(day) {
    var time = DateTime.fromMillisecondsSinceEpoch(day * Constants.oneDay);
    return MessageHolder(getHeaderDate(time.millisecondsSinceEpoch), null);
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

  _getScreen() {
    if (messageList.length > 0) {
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
            return ChatMessage(
              text: document['body'],
              name: "${document['createdBy']}",
              timestamp: document['createdAt'],
              self: document['createdById'] == user.documentID,
              location: document['location'],
              imageUrl: document['image'],
              message: document,
            );
          });
    }
    return const Center(
      child: const Text('No messages'),
    );
  }

  @override
  build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Container(color: Colors.white, child: _getScreen()),
      ),
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 14.0),
        child: inputField,
      )
    ]);
  } //modified

}
