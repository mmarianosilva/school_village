import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/usecase/select_image_usecase.dart';
import 'package:school_village/usecase/upload_image_usecase.dart';
import 'package:school_village/util/user_helper.dart';

class FollowupCommentBox extends StatefulWidget {
  final String _firestorePath;
  final SelectImageUsecase _imagePickerUsecase = SelectImageUsecase();

  FollowupCommentBox(this._firestorePath);

  @override
  _FollowupCommentBoxState createState() =>
      _FollowupCommentBoxState();
}

class _FollowupCommentBoxState extends State<FollowupCommentBox> {
  TextEditingController _inputController = TextEditingController();

  File _selectedPhoto;
  DocumentSnapshot _userDoc;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final _user = await UserHelper.getUser();
    Firestore.instance.document("users/${_user.uid}").get().then((snapshot) {
      setState(() {
        _userDoc = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        border: Border.all(color: Colors.grey[500], width: 1.0),
      ),
      padding: const EdgeInsets.all(8.0),
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _userDoc != null ? Text('${_userDoc['firstName']} ${_userDoc['lastName']}') : Text('...'),
            Spacer(),
            Text('Date'),
            Spacer(),
            Text('Time'),
          ],
        ),
        Container(
          child: TextField(
            controller: _inputController,
            decoration: InputDecoration(
              hintText: 'Add comment',
            ),
          ),
        ),
        _selectedPhoto != null
            ? Container(
                height: 96.0,
                child: Image.file(
                  _selectedPhoto,
                  fit: BoxFit.scaleDown,
                ),
              )
            : SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              child: Text('Clear', style: TextStyle(color: Colors.blueAccent),),
              onPressed: _onClear,
            ),
            FlatButton(
              child: Text('Add', style: TextStyle(color: Colors.blueAccent),),
              onPressed: _onAdd,
            ),
            IconButton(
              icon: Icon(Icons.add_a_photo, color: Colors.blueAccent,),
              onPressed: () {
                _onTakePhoto();
              },
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate, color: Colors.blueAccent,),
              onPressed: () {
                _onSelectPhoto();
              },
            )
          ],
        )
      ],
    ));
  }

  Future<void> _onTakePhoto() async {
    File photo = await widget._imagePickerUsecase.takeImage();
    if (photo != null) {
      _changePreviewPhoto(photo);
    }
  }

  Future<void> _onSelectPhoto() async {
    File photo = await widget._imagePickerUsecase.selectImage();
    if (photo != null) {
      _changePreviewPhoto(photo);
    }
  }

  void _changePreviewPhoto(File photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  Future<void> _onAdd() async {
    assert(_userDoc != null);
    final String body = _inputController.text;
    final String path = '${widget._firestorePath}/followup';
    String uploadUri;
    if (_selectedPhoto != null) {
      final UploadFileUsecase uploadFileUsecase = UploadFileUsecase();
      uploadUri = await uploadFileUsecase.uploadFile('$path/${DateTime.now().millisecondsSinceEpoch}', _selectedPhoto);
    }
    await Firestore.instance.collection(path).add({
      'createdById' : _userDoc.documentID,
      'createdBy' : "${_userDoc["firstName"]} ${_userDoc["lastName"]}",
      'img' : uploadUri,
      'timestamp' : FieldValue.serverTimestamp(),
      'body' : body,
    });
    _onClear();
  }

  void _onClear() {
    _inputController.clear();
    setState(() {
      _selectedPhoto = null;
    });
  }
}
