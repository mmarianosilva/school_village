import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:school_village/components/icon_button.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageAddress;

  final maxScale;
  final minScale;

  ImageViewScreen(this.imageAddress, {this.minScale, this.maxScale});

  @override
  build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      PhotoView(
        imageProvider: NetworkImage(imageAddress),
        loadingChild: Text("Loading", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.white,
        minScale: minScale,
        maxScale: maxScale,
      ),
      Container(
          margin: EdgeInsets.only(left: 15.0, top: 30.0),
          child: Card(
            color: Colors.transparent,
            shape: CircleBorder(),
            child: CustomIconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ))
    ]));
  }
}
