import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/usecase/select_image_usecase.dart';
import 'package:school_village/usecase/upload_file_usecase.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class FollowupCommentBox extends StatefulWidget {
  final String _firestorePath;
  final SelectImageUsecase _imagePickerUsecase = SelectImageUsecase();

  FollowupCommentBox(this._firestorePath);

  @override
  _FollowupCommentBoxState createState() => _FollowupCommentBoxState();
}

class _FollowupCommentBoxState extends State<FollowupCommentBox> {
  TextEditingController _inputController = TextEditingController();

  File _selectedPhoto;
  DocumentSnapshot _userDoc;
  bool _busy = false;

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
        color: Colors.white,
        border: Border.all(color: Colors.grey[500], width: 1.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _userDoc != null
                      ? Text('${_userDoc['firstName']} ${_userDoc['lastName']}')
                      : Text('...'),
                  Spacer(),
                  Text(localize('Date')),
                  Spacer(),
                  Text(localize('Time')),
                ],
              ),
              Container(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: localize('Add comment'),
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
                    child: Text(
                      localize('Clear'),
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onPressed: _onClear,
                  ),
                  FlatButton(
                    child: Text(
                      localize('Add'),
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onPressed: _onAdd,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      _onTakePhoto();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      _onSelectPhoto();
                    },
                  )
                ],
              )
            ],
          ),
          _busy
              ? Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
              : SizedBox(),
        ],
      ),
    );
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
    if (_inputController.text.isEmpty && _selectedPhoto == null) {
      return;
    }
    setState(() {
      _busy = true;
    });
    try {
      final String body = _inputController.text;
      final String path = '${widget._firestorePath}/followup';
      String uploadUri;
      if (_selectedPhoto != null) {
        final UploadFileUsecase uploadFileUsecase = UploadFileUsecase();
        uploadUri = await uploadFileUsecase.uploadFile(
            '$path/${DateTime.now().millisecondsSinceEpoch}', _selectedPhoto);
      }
      await Firestore.instance.collection(path).add({
        'createdById': _userDoc.documentID,
        'createdBy': "${_userDoc["firstName"]} ${_userDoc["lastName"]}",
        'img': uploadUri,
        'timestamp': FieldValue.serverTimestamp(),
        'body': body,
      });
    } on Exception catch (ex) {
      debugPrint('${ex.toString()}');
    } finally {
      _onClear();
    }
  }

  void _onClear() {
    _inputController.clear();
    setState(() {
      _busy = false;
      _selectedPhoto = null;
    });
  }
}
