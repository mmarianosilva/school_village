import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum ImageDownloadState { Idle, GettingURL, Downloading, Done, Error }

class FireBaseImageThumbnail extends StatefulWidget {
  final String reference;
  final double width;
  final double height;

  FireBaseImageThumbnail(
      {Key key,
        this.reference,
        this.height,
        this.width});

  @override
  State<StatefulWidget> createState() {
    return _FireBaseImageThumbnailState(reference, height, width);
  }
}

class _FireBaseImageThumbnailState extends State<FireBaseImageThumbnail> with TickerProviderStateMixin {

  final FirebaseStorage storage = new FirebaseStorage(storageBucket: 'gs://schoolvillage-1.appspot.com');
  final double width;
  final double height;
  String reference;
  String thumbnailUrl;
  Widget placeholder;
  bool loaded = false;

  _FireBaseImageThumbnailState(this.reference, this.height, this.width) ;

  _downloadFile() async {
    storage.ref().child(reference).getDownloadURL().then((url) {
      setState(() {
        this.thumbnailUrl = url;
        this.loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if(!loaded) {
      _downloadFile();
      return new Center(child: new Container(child: new CircularProgressIndicator(),
        width: (width/4),
        height: (width/4),));
    }

    return new CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.contain,
      width: width,
      height: height,
      placeholder: new Center(child: new Container(child: new CircularProgressIndicator(),
        width: (width/4),
        height: (width/4),)),
      errorWidget: new Icon(Icons.error),
    );
  }
}
