import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/constants.dart';
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

  static FirebaseStorage storage = new FirebaseStorage(storageBucket: 'gs://schoolvillage-1.appspot.com');
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
    if(image != null) {
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
      'image' : image == null ? null : path,
      'reportedByPhone': "${user['phone']}"
    });
    if(image != null) {
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


  _showLoading() {

  }

  _hideLoading() {

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

  _removeImage() {
    setState(() {
      image = null;
    });
  }

  Widget _buildImagePreview() {
    if (image == null) return SizedBox();
    print("iamge");
    return new Container(
      padding: EdgeInsets.all(4.0),
      child: new Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image.file(image, height: 120.0),
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

  Widget _buildTextComposer() {
    print(conversation);
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
          children: <Widget>[
            _buildImagePreview(),
            new Row(
              children: <Widget>[
                new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                        icon: new Icon(Icons.add_a_photo,
                            color: Colors.grey.shade700),
                        onPressed: () => _openImagePicker(context))),
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
                        onPressed: () =>
                            _handleSubmitted(_textController.text))),
              ],
            )
          ],
        ),
      ), //new
    );
  }

  static const borderRadius = const BorderRadius.all(const Radius.circular(45.0));

  _buildInput() {
    return Container(
        child: Card(
      elevation: 5.0,

      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Container(
        color: Colors.white,
        child: Card(
          margin: EdgeInsets.all(2.0),
          shape: RoundedRectangleBorder(
              borderRadius: borderRadius),
          color: Colors.grey.shade800,
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
          ),
        ),
      ),
    ));
  }

  _buildInputBox() {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: TextField(
        maxLines: 1,
        controller: _textController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            filled: true,
            hintStyle: TextStyle(color: Colors.grey.shade50, fontSize: 14.0),
            fillColor: Colors.grey.shade800,
            border: const OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide:
                    const BorderSide(color: Colors.white, style: BorderStyle.solid, width: 5.0)),
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () => _handleSubmitted(_textController.text)),
            hintText: "Type Message..."),
      ),
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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
  build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(color: Colors.white, child: _getScreen()),
        ), //new
        Container(
          margin: EdgeInsets.only(left: 30.0, right: 20.0, bottom: 10.0),
          decoration: BoxDecoration(color: Colors.white), //new
          child: _buildInput(), //modified
  void saveImage(File file) async {
    print("Saving image");
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
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera);
                },
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
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

  @override
  Widget build(BuildContext context) {
    return new Column(
      //modified
      children: <Widget>[
        //new
        new Flexible(
            //new
            child: new StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("$conversation/messages")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  final int messageCount = snapshot.data.documents.length;
                  return new ListView.builder(
                    itemCount: messageCount,
                    reverse: true,
                    padding: new EdgeInsets.all(8.0),
                    itemBuilder: (_, int index) {
                      final DocumentSnapshot document =
                          snapshot.data.documents[index];
                      var createdBy = document['createdBy'].split(" ");
                      var initial =
                          createdBy[0].length > 0 ? createdBy[0][0] : '';
                      if (createdBy.length > 1) {
                        initial = createdBy[1].length > 0
                            ? "$initial${createdBy[1][0]}"
                            : "$initial";
                      }
                      return new ChatMessage(
                        text: document['body'],
                        name: "${document['createdBy']}",
                        initial: "$initial",
                        timestamp: document['createdAt'],
                        self: document['createdById'] == user.documentID,
                        location: document['location'],
                        message: document,
                        imageUrl: document['image'],
                      );
                    },
                  );
                }) //new
            ), //new
        new Divider(height: 1.0), //new
        new Container(
          //new
          decoration:
              new BoxDecoration(color: Theme.of(context).cardColor), //new
          child: _buildTextComposer(), //modified
        ), //new
      ], //new
    );
  }
}
