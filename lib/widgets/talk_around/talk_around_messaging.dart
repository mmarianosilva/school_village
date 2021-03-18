import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/usecase/select_image_usecase.dart';
import 'package:school_village/usecase/upload_file_usecase.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/video_helper.dart';
import 'package:school_village/widgets/talk_around/chat/chat.dart';
import 'package:school_village/widgets/talk_around/class/talk_around_create_class.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';
import 'package:school_village/widgets/talk_around/talk_around_room_detail.dart';
import 'package:school_village/widgets/talk_around/talk_around_search.dart';
import 'package:school_village/widgets/talk_around/talk_around_user.dart';
import 'package:school_village/util/localizations/localization.dart';

class TalkAroundMessaging extends StatefulWidget {
  final TalkAroundChannel channel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TalkAroundMessaging({Key key, this.channel}) : super(key: key);

  @override
  _TalkAroundMessagingState createState() => _TalkAroundMessagingState(channel);
}

class _TalkAroundMessagingState extends State<TalkAroundMessaging>
    with TickerProviderStateMixin {
  final TalkAroundChannel channel;
  DocumentSnapshot _userSnapshot;
  String _schoolId;
  bool isLoading = true;
  bool isVideo = false;
  bool sending = false;
  File selectedImage;
  final TextEditingController messageInputController = TextEditingController();
  final SelectImageUsecase selectImageUsecase = SelectImageUsecase();
  final UploadFileUsecase uploadFileUsecase = UploadFileUsecase();

  _TalkAroundMessagingState(this.channel);

  void _getUserDetails() async {
    FirebaseUser user = await UserHelper.getUser();
    var schoolId = await UserHelper.getSelectedSchoolID();
    FirebaseFirestore.instance.doc('users/${user.uid}').get().then((user) {
      setState(() {
        _userSnapshot = user;
        _schoolId = schoolId;
        isLoading = false;
      });
    });
  }

  String _buildChannelName() {
    if (!channel.direct) {
      return "#${channel.name}";
    }
    if (_userSnapshot != null) {
      final String userId = _userSnapshot.id;
      final List<TalkAroundUser> members =
          channel.members.where((user) => user.id.id != userId).toList();
      members.sort((user1, user2) => user1.name.compareTo(user2.name));
      if (members.length == 1) {
        return members.first.name;
      }
      String name = "";
      for (int i = 0; i < members.length - 1; i++) {
        name += "${members[i].name}, ";
      }
      return "$name${members.last.name}";
    }
    return localize("Loading...");
  }

  String _buildTitle() {
    if (!channel.direct) {
      return localize("Talk-Around");
    }
    if (channel.members.length == 2) {
      return localize("Talk-Around: Direct Message");
    }
    return localize("Talk-Around: Group Message");
  }

  List<Widget> _buildChannelFooterOptions() {
    if (channel.direct) {
      return [
        GestureDetector(
          child: Icon(Icons.photo_camera, color: Colors.black54),
          onTap: _onTakePhoto,
        ),
        GestureDetector(
          child: Icon(Icons.photo_size_select_actual, color: Colors.black54),
          onTap: _onSelectPhoto,
        ),
        GestureDetector(
            child: Icon(Icons.video_call, color: Colors.black54),
            onTap: _onSelectVideo),
        GestureDetector(
          child: Icon(Icons.add_circle_outline, color: Colors.black54),
          onTap: _onAddTapped,
        ),
      ];
    }
    return [
      GestureDetector(
        child: Icon(Icons.photo_camera, color: Colors.black54),
        onTap: _onTakePhoto,
      ),
      GestureDetector(
        child: Icon(Icons.photo_size_select_actual, color: Colors.black54),
        onTap: _onSelectPhoto,
      ),
      GestureDetector(
          child: Icon(Icons.video_call, color: Colors.black54),
          onTap: _onSelectVideo),
    ];
  }

  void _onAddTapped() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TalkAroundSearch(false, channel)));
  }

  void _onChannelNameTapped() {
    if (channel.members != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TalkAroundRoomDetail(channel)));
    }
  }

  void _onTakePhoto() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final File photo = await selectImageUsecase.takeImage();
    setState(() {
      selectedImage = photo;
    });
  }

  void _onSelectPhoto() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final File photo = await selectImageUsecase.selectImage();
    setState(() {
      selectedImage = photo;
    });
  }

  void _onSelectVideo() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final File video = await selectImageUsecase.selectVideo();
    if (video != null) {
      setState(() {
        sending = true;
      });
      try {
        await VideoHelper.buildThumbnail(video);
        await VideoHelper.processVideoForUpload(video);
        File thumbnail = File(await VideoHelper.thumbnailPath(video));
        setState(() {
          selectedImage = thumbnail;
          isVideo = selectedImage != null;
        });
      } finally {
        setState(() {
          sending = false;
        });
      }
    }
  }

  void _onSend() async {
    if (messageInputController.text.isEmpty && selectedImage == null) {
      return;
    }
    setState(() {
      sending = true;
    });
    String uploadUri;
    if (selectedImage != null) {
      try {
        final UploadFileUsecase uploadFileUsecase = UploadFileUsecase();
        final bool isVideoShallow = isVideo;
        final Map<String, double> currentLocation =
            await UserHelper.getLocation();
        final String input = messageInputController.text;
        messageInputController.clear();
        final Function(String) onCompleteTask = (String url) {
          final Map<String, dynamic> messageData = {
            "image": uploadUri,
            "isVideo": isVideoShallow,
            "author": UserHelper.getDisplayName(_userSnapshot),
            "authorId": _userSnapshot.id,
            "location": currentLocation,
            "timestamp": FieldValue.serverTimestamp(),
            "body": input,
            "phone": _userSnapshot.data()["phone"]
          };
          try {
            FirebaseFirestore.instance.runTransaction((transaction) async {
              CollectionReference messages = FirebaseFirestore.instance
                  .collection("$_schoolId/messages/${channel.id}/messages");
              await transaction.set(messages.doc(), messageData);
              FirebaseFirestore.instance
                  .doc("$_schoolId/messages/${channel.id}")
                  .set({"timestamp": FieldValue.serverTimestamp()},
                      SetOptions(merge: true));
            });
          } on Exception catch (ex) {
            print("$ex");
          }
        };
        if (isVideo) {
          final String path =
              '${_schoolId[0].toUpperCase()}${_schoolId.substring(1)}/messages/${channel.id}/${DateTime.now().millisecondsSinceEpoch}.mp4';
          uploadFileUsecase.uploadFile(
              path, VideoHelper.videoForThumbnail(selectedImage),
              onComplete: onCompleteTask);
          uploadUri = path;
        } else {
          final String path =
              '${_schoolId[0].toUpperCase()}${_schoolId.substring(1)}/messages/${channel.id}/${DateTime.now().millisecondsSinceEpoch}.${selectedImage.path.split('.').last}';
          uploadFileUsecase.uploadFile(path, selectedImage,
              onComplete: onCompleteTask);
          uploadUri = path;
        }
        widget._scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
              'Your file is being uploaded in the background. This can take a long time'),
        ));
      } on Exception catch (ex) {
        setState(() {
          sending = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text(localize('An error occurred')),
                  content: Text('$ex'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(localize('Ok')),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ));
        return;
      }
    } else {
      final Map<String, dynamic> messageData = {
        "author": UserHelper.getDisplayName(_userSnapshot),
        "authorId": _userSnapshot.id,
        // "location": await UserHelper.getLocation(),
        "timestamp": FieldValue.serverTimestamp(),
        "body": messageInputController.text,
        "phone": _userSnapshot.data()["phone"]
      };
      try {
        FirebaseFirestore.instance.runTransaction((transaction) async {
          CollectionReference messages = FirebaseFirestore.instance
              .collection("$_schoolId/messages/${channel.id}/messages");
          await transaction.set(messages.doc(), messageData);
          FirebaseFirestore.instance
              .doc("$_schoolId/messages/${channel.id}")
              .set({"timestamp": FieldValue.serverTimestamp()},
                  SetOptions(merge: true));
        });
        messageInputController.clear();
      } on Exception catch (ex) {
        print("$ex");
      }
    }
    setState(() {
      selectedImage = null;
      isVideo = false;
      sending = false;
    });
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget._scaffoldKey,
        appBar: BaseAppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Color.fromARGB(255, 241, 241, 245),
          title: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_buildTitle(),
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                GestureDetector(
                  child: Text(_buildChannelName(),
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  onTap: _onChannelNameTapped,
                )
              ],
            ),
          ),
          actions: (widget.channel.isClass ?? false) &&
              ((_userSnapshot != null && (_userSnapshot.data()["associatedSchools"]["${_schoolId.substring("schools/".length)}"]["role"] == "school_admin" || _userSnapshot.data()["associatedSchools"]["${_schoolId.substring("schools/".length)}"]["role"] == "district" || _userSnapshot.data()["associatedSchools"]["${_schoolId.substring("schools/".length)}"]["role"] == "admin")) ||
              (widget.channel.admin.id ==
                      FirebaseFirestore.instance
                          .doc("users/${_userSnapshot?.id ?? "a"}")))
              ? [
                  FlatButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => TalkAroundCreateClass(
                                  group: widget.channel,
                                ))),
                    child: Text(localize('Edit').toUpperCase(),
                        style: TextStyle(
                            color: Color.fromARGB(255, 20, 195, 239),
                            fontSize: 16.0),
                        textAlign: TextAlign.end),
                  )
                ]
              : [],
        ),
        body: Builder(builder: (context) {
          if (isLoading) {
            return Center(
                child: Column(
              children: <Widget>[
                Text(localize("Loading...")),
                CircularProgressIndicator()
              ],
            ));
          } else {
            return Stack(
              children: <Widget>[
                Container(
                  color: Color.fromARGB(255, 241, 241, 245),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Chat(
                          conversation: "$_schoolId/messages/${channel.id}",
                          showLocation: channel.showLocation,
                          showInput: false,
                          user: _userSnapshot,
                          reverseInput: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16.0),
                        child: Column(
                          children: <Widget>[
                            selectedImage != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.file(
                                        selectedImage,
                                        height: 120.0,
                                        fit: BoxFit.scaleDown,
                                      )
                                    ],
                                  )
                                : SizedBox(),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.black,
                                  border: Border.all(
                                      color: Colors.white, width: 1.0)),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: messageInputController,
                                      decoration: InputDecoration(
                                          hintText:
                                              "${localize('Message')} ${_buildChannelName()}",
                                          hintStyle: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 187, 187, 187))),
                                      maxLines: null,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.send,
                                      color: Color.fromARGB(255, 187, 187, 187),
                                      size: 32.0,
                                    ),
                                    onTap: _onSend,
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: _buildChannelFooterOptions()),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                sending
                    ? Container(
                        color: Color.fromARGB(112, 0, 0, 0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(),
              ],
            );
          }
        }));
  }
}
