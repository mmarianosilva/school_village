import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/icon_button.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';
import 'package:video_player/video_player.dart';

typedef SendPressed(img, text, isVideo);

class InputField extends StatefulWidget {
  final SendPressed sendPressed;
  final GlobalKey<_InputFieldState> key = GlobalKey();

  InputField({this.sendPressed}) : super();

  @override
  createState() => _InputFieldState(sendPressed: sendPressed);
}

class _InputFieldState extends State<InputField> {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final TextEditingController inputController = TextEditingController();
  final SendPressed sendPressed;
  File image;
  bool isVideoFile;
  VideoPlayerController _controller;
  File thumbNail;
  bool _loading = false;

  static const borderRadius =
      const BorderRadius.all(const Radius.circular(45.0));

  _InputFieldState({this.sendPressed});

  @override
  build(BuildContext context) {
    return _buildInput();
  }

  _getImage(BuildContext context, ImageSource source, bool isVideo) {
    if (!isVideo) {
      ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
        print(image);
        if (image != null) saveImage(image, isVideo, null);
      });
    } else {
      ImagePicker.pickVideo(source: source).then((File video) {
        if (video != null) {
          this._transcodeVideo(video);
        }
      });
    }
  }

  _transcodeVideo(File video) async {
    String path = "${video.path}.mp4";
    String thumbPath = "${video.path}_thumb.jpg";
    setState(() {
      _loading = true;
    });

    _flutterFFmpeg
        .execute("-ss 1 -i ${video.path} -vframes 1 $thumbPath")
        .then((r) {
      saveImage(File(path), true, File(thumbPath));

      _flutterFFmpeg.execute("-i ${video.path} -s hd480 $path").then((rc) {
        setState(() {
          _loading = false;
        });
      });
    });
  }

  void saveImage(File file, bool isVideoFile, File thumb) async {
    setState(() {
      this.isVideoFile = isVideoFile;
      image = file;
      thumbNail = thumb;
    });
    _initVideoController();
  }

  _buildImagePreview() {
    if (image == null) return SizedBox();

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(4.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.file(isVideoFile ? thumbNail : image, height: 120.0),
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
        _loading
            ? Container(
                height: 300,
                color: SVColors.incidentReportGray,
                margin: EdgeInsets.symmetric(horizontal: 20),
              )
            : SizedBox()
      ],
    );
  }

  _initVideoController() {
    _controller = VideoPlayerController.file(image);
    _controller.initialize().then((_) {
      setState(() {});
    });
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
                Container(
                    height: 120,
                    child: _buildVideoView()),
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

  _buildVideoView() {
    return Center(
        child: _controller.value.initialized
            ? GestureDetector(
                onTap: () {
                  print('onVideoTap');
                },
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ))
            : Container());
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
            height: 280.0,
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
              Text(
                'Pick a Video',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera, true);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Gallery'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.gallery, true);
                },
              )
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
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width - 104,
            child: Card(
              elevation: 10.0,
              margin: EdgeInsets.all(1.5),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              color: SVColors.talkAroundAccent,
              child: Container(
                  child: TextField(
                    controller: inputController,
                    maxLines: null,
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
                            sendPressed(
                                image, inputController.text, thumbNail);
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
