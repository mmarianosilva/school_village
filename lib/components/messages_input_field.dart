import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/icon_button.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';
import 'package:video_player/video_player.dart';

typedef SendPressed(img, text);

class InputField extends StatefulWidget {
  final SendPressed sendPressed;
  final GlobalKey<_InputFieldState> key = GlobalKey();

  InputField({this.sendPressed}) : super();

  @override
  createState() => _InputFieldState(sendPressed: sendPressed);
}

class _InputFieldState extends State<InputField> {
  final TextEditingController inputController = TextEditingController();
  final SendPressed sendPressed;
  File image;
  bool isVideoFile;
  VideoPlayerController _controller;

  static const borderRadius = const BorderRadius.all(const Radius.circular(45.0));

  _InputFieldState({this.sendPressed});

  @override
  build(BuildContext context) {
    return _buildInput();
  }

  _getImage(BuildContext context, ImageSource source, bool isVideo) {
    if (!isVideo) {
      ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
        if (image != null) saveImage(image, isVideo);
      });
    } else {
      ImagePicker.pickVideo(source: source).then((File video) {
        if (video != null) saveImage(video, isVideo);
      });
    }
  }

  initState() {
    super.initState();
//    _controller = VideoPlayerController.file(
//      'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
//    )
//      ..addListener(() {
////        final bool isPlaying = _controller.value.isPlaying;
////        if (isPlaying != _isPlaying) {
////          setState(() {
////            _isPlaying = isPlaying;
////          });
////        }
//      });
  }

  void saveImage(File file, bool isVideoFile) async {
    setState(() {
      this.isVideoFile = isVideoFile;
      image = file;
    });
  }

  _buildImagePreview() {
    if (image == null) return SizedBox();

    if (isVideoFile) {
      return _buildVideoPreview();
    }

    return Stack(
      children: [
        Container(
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
        ),
      ],
    );
  }

  _getVideoController() {
    return VideoPlayerController.file(image)
      ..addListener(() => {

      })
      ..initialize().then((_) => {});
  }

  _buildVideoPreview() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(4.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoPlayer(_getVideoController()),
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
        ),
        Center(child: Icon(Icons.play_circle_outline, color: Colors.grey.shade800))
      ],
    );
  }

  clearState() {
    _removeImage();
    inputController.clear();
  }

  _removeImage() {
    setState(() {
      image = null;
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 160.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera, false);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Gallery'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.gallery, false);
                },
              ),
              SizedBox(
                height: 20.0,
              ),
//              Text(
//                'Pick a Video',
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              FlatButton(
//                textColor: SVColors.talkAroundAccent,
//                child: Text('Use Camera'),
//                onPressed: () {
//                  Navigator.pop(context);
//                  _getImage(context, ImageSource.camera, true);
//                },
//              ),
//              FlatButton(
//                textColor: SVColors.talkAroundAccent,
//                child: Text('Use Gallery'),
//                onPressed: () {
//                  Navigator.pop(context);
//                  _getImage(context, ImageSource.gallery, true);
//                },
//              )
            ]),
          );
        });
  }

  _buildInput() {
    return Column(children: [
      _buildImagePreview(),
      Row(children: [
        Container(
            margin: Constants.messagesHorizontalMargin,
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
                  height: 40.0,
                  child: TextField(
                    controller: inputController,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey.shade50),
                        fillColor: Colors.transparent,
                        filled: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            sendPressed(image, inputController.text);
                          },
                        ),
                        hintText: "Type Message..."),
                  )),
            ),
          ),
        )
      ])
    ]);
  }
}
