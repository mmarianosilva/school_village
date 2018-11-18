import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class FullScreenVideoView extends StatefulWidget {
  final String url;
  final String message;

  FullScreenVideoView({this.url, this.message});

  @override
  _VideoAppState createState() => _VideoAppState(url: url, message: message);
}

class _VideoAppState extends State<FullScreenVideoView> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  final String url;
  final String message;

  _VideoAppState({this.url, this.message});

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url)
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: this.message,
      home: Scaffold(
        body: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _controller.value.isPlaying
              ? _controller.pause
              : _controller.play,
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}
