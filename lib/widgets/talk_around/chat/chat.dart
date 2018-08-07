import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/components/icon_button.dart';
import '../message/message.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat extends StatefulWidget {
  final String conversation;
  final DocumentSnapshot user;

  Chat({Key key, this.conversation, this.user}) : super(key: key);

  @override
  createState() => _ChatState(conversation, user);
}

class _ChatState extends State<Chat> {
  final TextEditingController _textController = TextEditingController();

  static FirebaseStorage storage = FirebaseStorage(storageBucket: 'gs://schoolvillage-1.appspot.com');
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
  bool isLoaded = false;
  File image;

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
      'body': _textController.text,
      'createdById': user.documentID,
      'createdBy': "${user.data['firstName']} ${user.data['lastName']}",
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'location': await _getLocation(),
      'image': image == null ? null : path,
      'reportedByPhone': "${user['phone']}"
    });
    if (image != null) {
      setState(() {
        image = null;
      });
    }
    _textController.clear();
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
      location = await _location.getLocation;
      error = null;
    } catch (e) {
      location = null;
    }
    return location;
  }

  _removeImage() {
    setState(() {
      image = null;
    });
  }

  Widget _buildImagePreview() {
    if (image == null) return SizedBox();
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.file(image, height: 120.0),
            SizedBox(width: 16.0),
            GestureDetector(
              onTap: () {
                _removeImage();
              },
              child: Icon(Icons.remove_circle_outline, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }

  static const borderRadius = const BorderRadius.all(const Radius.circular(45.0));
  static const horizontalMargin = const EdgeInsets.symmetric(horizontal: 25.0);

  _buildInput() {
    return Column(children: [
      _buildImagePreview(),
      Row(children: [
        Container(
            margin: horizontalMargin,
            child: CustomIconButton(
                padding: EdgeInsets.all(0.0),
                icon: ImageIcon(
                  AssetImage('assets/images/camera.png'),
                  color: SVColors.talkAroundAccent,
                ),
                onPressed: () => _openImagePicker(context))),
        Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width - 104,
            child: Card(
              margin: EdgeInsets.all(1.5),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              color: SVColors.talkAroundAccent,
              child: Container(
                  child: TextField(
                controller: _textController,
                maxLines: 1,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade50),
                    fillColor: Colors.transparent,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                    hintText: "Type Message..."),
              )),
            ),
          ),
        )
      ])
    ]);
  }

  _convertDateToKey(createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).millisecondsSinceEpoch ~/ Constants.oneDay;
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
          padding: horizontalMargin,
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
      child: const Text('Loading...'),
    );
  }

  @override
  build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Container(color: Colors.white, child: _getScreen()),
      ), //new
      Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 14.0),
        child: _buildInput(),
      )
    ]);
  } //modified

  void saveImage(File file) async {
    setState(() {
      image = file;
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Gallery'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.gallery);
                },
              )
            ]),
          );
        });
  }

  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      if (image != null) saveImage(image);
    });
  }
}
