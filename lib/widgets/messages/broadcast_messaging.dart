import 'dart:collection';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mime/mime.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/components/messages_input_field.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/widgets/messages/broadcast_message.dart';
import 'package:school_village/widgets/select_group/select_group.dart';
import '../../util/user_helper.dart';
import 'package:school_village/util/constants.dart';

class BroadcastMessaging extends StatefulWidget {
  final bool editable;

  BroadcastMessaging({Key key, this.editable}) : super(key: key);

  @override
  _BroadcastMessagingState createState() => _BroadcastMessagingState();
}

class _BroadcastMessagingState extends State<BroadcastMessaging> {
  static FirebaseStorage storage = FirebaseStorage();
  FirebaseUser _user;
  String _userId;
  String name = '';
  String _schoolId = '';
  String phone = '';
  var isLoaded = false;
  DocumentReference _userRef;
  List<String> _groups = List<String>();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  List<MessageHolder> messageList = List();
  var disposed = false;
  ScrollController _scrollController;
  final focusNode = FocusNode();
  InputField inputField;
  final selectGroups = SelectGroups();

  getUserDetails() async {
    _user = await UserHelper.getUser();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = Firestore.instance.document("users/${_user.uid}");
    _userRef.get().then((user) {
      var keys = user.data["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = List<String>();
      for (int i = 0; i < keys.length; i++) {
        if (user.data["associatedSchools"][schoolId]["groups"]
        [keys.elementAt(i)] ==
            true) {
          groups.add(keys.elementAt(i));
        }
      }
      setState(() {
        _userId = user.documentID;
        name = "${user.data['firstName']} ${user.data['lastName']}";
        _schoolId = schoolId;
        phone = '${user.data['phone']}';
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
    return DateTime.fromMillisecondsSinceEpoch(createdAt)
        .millisecondsSinceEpoch ~/
        Constants.oneDay;
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
      // messageList.insert(0, _getHeaderItem(day));
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
    inputField = InputField(sendPressed: (image, text, isVideo) {
      _sendMessage(image, text, isVideo);
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
    Firestore.instance
        .collection("schools/$_schoolId/broadcasts")
        .orderBy("createdAt")
        .snapshots()
        .listen((data) {
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
    if (messageList.length == 0) {
      return Center(
        child: Text('No messages'),
      );
    }
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
            final groups = List<String>();

            for (var value in (document['groups'].keys)) {
              groups.add(value);
            }

            return BroadcastMessage(
              text: document['body'],
              name: "${document['createdBy']}",
              timestamp: document['createdAt'],
              groups: groups,
              imageUrl: document['image'],
              message: document,
              isVideo: document['isVideo'] ?? false,
            );
          });
    }
    return Center(
      child: Text('Loading...'),
    );
  }

  showErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error sending broadcast'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(error)],
              ),
            ),
            actions: [
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _sendMessage(File image, text, isVideo) {
    if (selectGroups.key.currentState.selectedGroups.length < 1) {
      showErrorDialog("Please select group to send the broadcast message");
      return;
    }

    if (text.length < 8) {
      showErrorDialog("Text length should be at least 8 characters");
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to send this message?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text('This cannot be undone')],
              ),
            ),
            actions: [
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveBroadcast(image, text, isVideo);
                },
              )
            ],
          );
        });
  }

  _showLoading() {}

  _hideLoading() {}

  _saveBroadcast(image, alertBody, bool isVideo) async {
    final broadcastPath = 'schools/$_schoolId/broadcasts';
    CollectionReference collection =
    Firestore.instance.collection(broadcastPath);
    final DocumentReference document = collection.document();

    var path = '';
    if (image != null) {
      _showLoading();
      path =
      '${broadcastPath[0].toUpperCase()}${broadcastPath.substring(1)}/${document.documentID}';
      String type = 'jpeg';
      type = lookupMimeType(image.path).split("/").length > 1
          ? lookupMimeType(image.path).split("/")[1]
          : type;

      path = path + "." + type;
      print(path);
      await uploadFile(path, image);
      _hideLoading();
    }

    print('saveBroadcast is vidoe ' + isVideo.toString());

    document.setData(<String, dynamic>{
      'body': alertBody,
      'groups': selectGroups.key.currentState.selectedGroups,
      'createdById': _userId,
      'createdBy': name,
      'image': image == null ? null : path,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'reportedByPhone': phone,
      'isVideo': isVideo
    });
    inputField.key.currentState.clearState();
  }

  uploadFile(String path, File file) async {
    final StorageReference ref = storage.ref().child(path);
    final StorageUploadTask uploadTask = ref.putFile(file);

    String downloadUrl;
    await uploadTask.onComplete.then((val) {
      val.ref.getDownloadURL().then((v) {
        downloadUrl = v; //Val here is Already String
      });
    });

//    final Uri downloadUrl = (await uploadTask.onComplete).downloadUrl;
    return downloadUrl;
  }

  @override
  build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: Text('Broadcast Messaging',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Column(children: [
          selectGroups,
          Expanded(
            child: Container(color: Colors.white, child: _getScreen()),
          ),
          SizedBox(
            width: 0.0,
            height: 5.0,
          ), //new
          widget.editable 
              ? Column(children: [
            // selectGroups,
            Container(
              color: SVColors.colorFromHex('#e5e5ea'),
              padding: EdgeInsets.only(bottom: 14.0),
              child: inputField,
            )
          ])
              : SizedBox(
            width: 0.0,
            height: 0.0,
          )
        ]));
  }
}
