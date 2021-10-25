import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/icon_button.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/video_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

typedef SendPressed(img, text, isVideo);

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
      ImagePicker.platform.pickImage(source: source, maxWidth: 400.0).then((image) {
        print(image);
        if (image != null) saveImage(image, isVideo, null);
      });
    } else {
      ImagePicker.platform.pickVideo(source: source).then((value) {
        if (value != null) {
          this._transcodeVideo(value);
        }
      });

    }
  }

  _transcodeVideo(PickedFile video) async {
    setState(() {
      _loading = true;
    });

    File thumbnail = await VideoHelper.buildThumbnail(File(video.path));
    File processedVideo = await VideoHelper.processVideoForUpload(File(video.path));

    saveImageVid(processedVideo, true, thumbnail);
  }
  void saveImageVid(File file, bool isVideoFile, File thumb) async {
    setState(() {
      this.isVideoFile = isVideoFile;
      image = file;
      thumbNail = thumb;
    });
  }
  void saveImage(PickedFile file, bool isVideoFile, File thumb) async {
    setState(() {
      this.isVideoFile = isVideoFile;
      image = File(file.path);
      thumbNail = thumb;
    });
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
                Image.file(isVideoFile ? thumbNail : image,
                    height: 120.0, fit: BoxFit.scaleDown),
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
                localize('Pick an Image'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text(localize('Use Camera')),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera, false);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text(localize('Use Gallery')),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.gallery, false);
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                localize('Pick a Video'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text(localize('Use Camera')),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera, true);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
                child: Text(localize('Use Gallery')),
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
                        sendPressed(image, inputController.text, thumbNail);
                      },
                    ),
                    hintText: localize("Type Message...")),
              )),
            ),
          ),
        )
      ])
    ]);
  }
}
