import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_village/components/icon_button.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';

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

  static const borderRadius = const BorderRadius.all(const Radius.circular(45.0));

  _InputFieldState({this.sendPressed});

  @override
  build(BuildContext context) {
    return _buildInput();
  }

  _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      if (image != null) saveImage(image);
    });
  }

  void saveImage(File file) async {
    setState(() {
      image = file;
    });
  }


  _buildImagePreview() {
    if (image == null) return SizedBox();
    return Container(
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
                textColor: SVColors.talkAroundAccent,
                child: Text('Use Camera'),
                onPressed: () {
                  Navigator.pop(context);
                  _getImage(context, ImageSource.camera);
                },
              ),
              FlatButton(
                textColor: SVColors.talkAroundAccent,
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
