import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../util/user_helper.dart';
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
  _ChatState createState() => new _ChatState(conversation, user);
}

class _ChatState extends State<Chat> {

  static FirebaseStorage storage = new FirebaseStorage(storageBucket: 'gs://schoolvillage-1.appspot.com');
  final TextEditingController _textController = new TextEditingController();
  final String conversation;
  final DocumentSnapshot user;
  final Firestore firestore = Firestore.instance;
  bool isLoaded = false;
  Location _location = new Location();
  File image;

  _ChatState(this.conversation, this.user);

  void _handleSubmitted(String text) async {
    if (text == null || text.trim() == '') {
      return;
    }
    CollectionReference collection =
        Firestore.instance.collection('$conversation/messages');
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
      'createdAt': new DateTime.now().millisecondsSinceEpoch,
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
