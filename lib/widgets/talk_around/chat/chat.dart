import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:school_village/components/messages_input_field.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/widgets/talk_around/message/message.dart';
import 'package:school_village/util/localizations/localization.dart';

class Chat extends StatefulWidget {
  final String conversation;
  final bool showLocation;
  final DocumentSnapshot user;
  final bool showInput;
  final bool reverseInput;

  Chat({Key key, this.conversation, this.user, this.showInput, this.showLocation = false, this.reverseInput = false,})
      : super(key: key);

  @override
  createState() => _ChatState(conversation, user, this.showInput);
}

class _ChatState extends State<Chat> {
  static FirebaseStorage storage = FirebaseStorage.instance;
  final String conversation;
  final DocumentSnapshot user;
  final bool showInput;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Location _location = Location();
  List<MessageHolder> messageList = List();
  ScrollController _scrollController;
  final focusNode = FocusNode();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  bool isLoaded = false;
  StreamSubscription<QuerySnapshot> _messageSubscription;

  InputField inputField;

  _ChatState(this.conversation, this.user, this.showInput);

  @override
  initState() {
    _handleMessageCollection();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    inputField = InputField(sendPressed: (image, text, thumb) {
      _handleSubmitted(image, text, thumb);
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
    if (_messageSubscription != null) {
      _messageSubscription.cancel();
    }
    if (_scrollController != null) {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  _handleSubmitted(File image, String text, File thumb) async {
    if (text == null || text.trim() == '') {
      return;
    }
    CollectionReference collection =
    FirebaseFirestore.instance.collection('$conversation/messages');
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentReference document = collection.doc();
      var path = '';
      var thumbPath = '';
      if (image != null) {
        _showLoading();
        path =
        '${conversation[0].toUpperCase()}${conversation.substring(1)}/${document.id}';
        String type = 'jpeg';
        type = image.path.split(".").last != null
            ? image.path.split(".").last
            : type;
        path = path + "." + type;

        thumbPath =
            '${conversation[0].toUpperCase()}${conversation.substring(1)}/${document.id}' +
                '.jpeg';

        print(path);
        await uploadFile(path, image);
        await uploadFile(thumbPath, thumb);
        _hideLoading();
      }
      await transaction.set(document, <String, dynamic>{
        'body': text,
        'authorId': user.id,
        'author': "${user['firstName']} ${user['lastName']}",
        'timestamp': FieldValue.serverTimestamp(),
        'location': widget.showLocation ? await _getLocation() : null,
        'image': image == null ? null : path
      });
    }).then((result) {
      print("Transaction result: ${result}");
      inputField.key.currentState.clearState();
    }).catchError((error) {
      print(error);
    });

  }

  uploadFile(String path, File file) async {
    final Reference ref = storage.ref().child(path);
    final UploadTask uploadTask = ref.putFile(file);

    String downloadUrl;
    await uploadTask.then((val) {
      val.ref.getDownloadURL().then((v) {
        downloadUrl = v; //Val here is Already String
      });
    });
    return downloadUrl;
  }

  _showLoading() {}

  _hideLoading() {}

  _getLocation() async {
    Map<String, double> location = new Map();
    try {
      LocationData locationData = await _location.getLocation();
      location['accuracy'] = locationData.accuracy;
      location['altitude'] = locationData.altitude;
      location['latitude'] = locationData.latitude;
      location['longitude'] = locationData.longitude;
    } catch (e) {
      location = null;
    }
    return location;
  }
  _convertDateToKey(Timestamp createdAt) {
    return createdAt.millisecondsSinceEpoch ~/ Constants.oneDay;
  }

  _handleMessageMapInsert(DocumentSnapshot shot) {
    print(shot['timestamp']);
    var day = _convertDateToKey(shot['timestamp']);

    var messages = messageMap[day];
    var message = MessageHolder(null, shot);
    if (messages == null) {
      messages = List();
      messageMap[day] = messages;
    }
    messageList.insert(0, message);
    messageMap[day].add(shot);
    setState(() {
      messageList = messageList;
    });
  }

  _handleDocumentChanges(documentChanges) {
    documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        _handleMessageMapInsert(change.document);
      } else if (change.type == DocumentChangeType.modified) {

      } else {

      }
    });
  }

  _handleMessageCollection() {
    _messageSubscription = firestore
        .collection("$conversation/messages")
        .orderBy("timestamp")
        .snapshots()
        .listen((data) {
      _handleDocumentChanges(data.docChanges);
    });
  }

  _getScreen() {
    if (messageList.length > 0) {
      return ListView.builder(
          itemCount: messageList.length,
          reverse: widget.reverseInput,
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
              name: "${document['author']}",
              phone: "${document['phone']}",
              timestamp: document['timestamp'],
              self: document['authorId'] == user.id,
              location: widget.showLocation ? document['location'] : null,
              imageUrl: document['image'],
              isVideo: document['isVideo'],
              message: document,
            );
          });
    }
    return Center(
      child: Text(localize('No messages')),
    );
  }

  @override
  build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Container(color: Colors.white, child: _getScreen()),
      ),
      this.showInput
          ? Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 14.0),
        child: inputField,
      )
          : SizedBox(width: 0.0, height: 10.0)
    ]);
  } //modified
}
