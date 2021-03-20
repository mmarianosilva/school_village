import 'dart:collection';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/components/messages_input_field.dart';
import 'package:school_village/model/message_holder.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/messages/broadcast_message.dart';
import 'package:school_village/widgets/select_group/select_group.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/localizations/localization.dart';

class BroadcastMessaging extends StatefulWidget {
  final bool editable;

  BroadcastMessaging({Key key, @required this.editable}) : super(key: key);

  @override
  _BroadcastMessagingState createState() => _BroadcastMessagingState(editable);
}

class _BroadcastMessagingState extends State<BroadcastMessaging> {
  _BroadcastMessagingState(this._editable) {
    this.selectGroups = SelectGroups((value) => amberAlert = value);
  }

  static FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseUser _user;
  String _userId;
  String name = '';
  String _schoolId = '';
  String phone = '';
  String role;
  var isLoaded = false;
  DocumentReference _userRef;
  List<String> _groups = List<String>();
  Map<int, List<DocumentSnapshot>> messageMap = LinkedHashMap();
  List<MessageHolder> messageList = List();
  var disposed = false;
  ScrollController _scrollController;
  final focusNode = FocusNode();
  InputField inputField;
  SelectGroups selectGroups;
  final bool _editable;
  bool amberAlert = false;

  getUserDetails() async {
    _user = await UserHelper.getUser();
    role = await UserHelper.getSelectedSchoolRole();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = FirebaseFirestore.instance.doc("users/${_user.uid}");
    _userRef.get().then((user) {
      var keys = user.data()["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = List<String>();
      for (int i = 0; i < keys.length; i++) {
        if (user.data()["associatedSchools"][schoolId]["groups"]
                [keys.elementAt(i)] ==
            true) {
          groups.add(keys.elementAt(i));
        }
      }
      setState(() {
        _userId = user.id;
        name = "${user.data()['firstName']} ${user.data()['lastName']}";
        _schoolId = schoolId;
        phone = '${user.data()['phone']}';
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

  _handleMessageMapInsert(shot) {
    // if (!belongsToGroup(shot.data()['groups'].keys)) {
    //   return;
    // }
    var day = _convertDateToKey(shot.data()['createdAt']);

    var messages = messageMap[day];
    var message = MessageHolder(null, shot);
    if (messages == null) {
      messages = List();
      messageMap[day] = messages;
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
    FirebaseFirestore.instance
        .collection("schools/$_schoolId/broadcasts")
        .orderBy("createdAt")
        .snapshots()
        .listen((data) {
      _handleDocumentChanges(data.docChanges);
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
        child: Text(localize('No messages')),
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
                        ),
                      ),
                    ),
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
              text: document.data()['body'],
              name: "${document.data()['createdBy']}",
              timestamp: document.data()['createdAt'] is Timestamp
                  ? document.data()['createdAt']
                  : Timestamp.fromMillisecondsSinceEpoch(
                      document.data()['createdAt']),
              imageUrl: document.data()['image'],
              message: document,
              isVideo: document.data()['isVideo'] ?? false,
            );
          });
    }
    return Center(
      child: Text(localize('Loading...')),
    );
  }

  showErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Error sending broadcast')),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(error)],
              ),
            ),
            actions: [
              FlatButton(
                child: Text(localize('Okay')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _sendMessage(File image, text, isVideo) {
    // if (selectGroups.key.currentState.selectedGroups.length < 1) {
    //   showErrorDialog(
    //       localize("Please select group to send the broadcast message"));
    //   return;
    // }

    if (text.length < 8) {
      showErrorDialog(localize("Text length should be at least 8 characters"));
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Send Message?')),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(localize(
                      'This message will be sent to all Users of the App in the Marina.')),
                  Text(localize("Do You want to continue?")),
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text(localize('No')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(localize('Yes')),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendBroadcasts(image, text, isVideo);
                },
              )
            ],
          );
        });
  }

  _sendBroadcasts(image, alertBody, isVideo) {
    if (role == 'district' || role == 'superadmin') {
      DocumentSnapshot selectedSchool =
          selectGroups.key.currentState.selectedSchool;
      if (selectedSchool == null) {
        selectGroups.key.currentState.schoolSnapshots.forEach((schoolDocument) {
          _saveBroadcast(image, alertBody, isVideo, schoolDocument.id);
        });
      } else {
        _saveBroadcast(image, alertBody, isVideo, selectedSchool.id);
      }
    } else {
      _saveBroadcast(image, alertBody, isVideo);
    }
  }

  _showLoading() {}

  _hideLoading() {}

  _saveBroadcast(image, alertBody, bool isVideo, [String schoolId]) async {
    if (schoolId == null) {
      schoolId = _schoolId;
    }
    final broadcastPath = 'schools/$schoolId/broadcasts';
    CollectionReference collection =
        FirebaseFirestore.instance.collection(broadcastPath);
    final DocumentReference document = collection.doc();

    var path = '';
    if (image != null) {
      _showLoading();
      path =
          '${broadcastPath[0].toUpperCase()}${broadcastPath.substring(1)}/${document.id}';
      String type = 'jpeg';
      type = image.path.split(".").last != null
          ? image.path.split(".").last
          : type;

      path = path + "." + type;
      print(path);
      await uploadFile(path, image);
      _hideLoading();
    }

    document.set(<String, dynamic>{
      'body': alertBody,
      'createdById': _userId,
      'createdBy': name,
      'image': image == null ? null : path,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'reportedByPhone': phone,
      'isVideo': isVideo,
      'amberAlert': amberAlert,
    });
    inputField.key.currentState.clearState();
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

  @override
  build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: Text(localize('Broadcast Messaging'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Column(children: [
          _editable
              ? selectGroups
              : SizedBox(
                  width: 0.0,
                  height: 0.0,
                ),
          Expanded(
            child: Container(color: Colors.white, child: _getScreen()),
          ),
          SizedBox(
            width: 0.0,
            height: 5.0,
          ), //new
          _editable
              ? Column(children: [
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
