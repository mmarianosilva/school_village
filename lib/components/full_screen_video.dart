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
    _controller = VideoPlayerController.network('https://www.w3schools.com/html/mov_bbb.mp4')
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Stack(
            children: <Widget>[
              Center(
                child: FutureBuilder(
                  future: _controller.initialize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              IconButton(

                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              )
            ],
          ),
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

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
