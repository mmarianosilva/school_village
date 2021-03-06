import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

typedef void ProgressImageTapCallBack(String imgUrl);

class ProgressImage extends StatefulWidget {
  final String url;
  final String firebasePath;
  final double height, width;
  final ProgressImageTapCallBack onTap;

  ProgressImage({Key key, this.url, this.firebasePath, this.height, this.width, this.onTap}) : super(key: key);

  @override
  createState() =>
      _ProgressImageState(url: url, firebasePath: firebasePath, height: height, width: width, onTap: onTap);
}

class _ProgressImageState extends State<ProgressImage> {
  String url;
  final String firebasePath;
  final loading = true;
  final double height, width;
  final ProgressImageTapCallBack onTap;
  var isDisposed = false;

  _ProgressImageState({this.url, this.firebasePath, this.height, this.width, this.onTap});

  static FirebaseStorage storage = FirebaseStorage();

  @override
  void initState() {
    super.initState();
    if (firebasePath != null) {
      storage.ref().child(firebasePath).getDownloadURL().then((furl) {
        if (!isDisposed)
          setState(() {
            url = furl;
          });
      });
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        color: Colors.grey.shade500,
        child: _buildImageContainer());
  }

  _buildImageContainer() {
    if (url == null) {
      return Container(
          height: height,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    }
    return GestureDetector(
        child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage, image: url, height: height, fit: BoxFit.fitHeight),
        onTap: () {
          this.onTap(url);
        });
  }

  final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ]);
}
