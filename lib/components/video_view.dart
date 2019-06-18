import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String url;
  final double height;
  final double width;

  VideoView({this.url, this.height, this.width});

  @override
  State<StatefulWidget> createState() {
    return VideoViewState(url: url, height: height, width: width);
  }
}

class VideoViewState extends State<VideoView> {

  final String url;
  final double height;
  final double width;

  VideoPlayerController _controller;


  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url);
    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  VideoViewState({this.url, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      child: Stack(children: [
        _controller.value.initialized
            ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
            : Container(),
        Icon(Icons.play_circle_outline)
      ]),
    );
  }
}