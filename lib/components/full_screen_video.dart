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
  Future<void> _initializeVideoPlayer;
  final String url;
  final String message;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  bool _warningDisplayed = false;

  _VideoAppState({this.url, this.message});

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url);
    _initializeVideoPlayer = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: this.message,
      home: Scaffold(
        key: _scaffold,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          child: Stack(
            children: <Widget>[
              Center(
                child: FutureBuilder(
                  future: _initializeVideoPlayer,
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
          onPressed: () async {
            if (!_warningDisplayed) {
              _scaffold.currentState.showSnackBar(
                SnackBar(
                  content: Text(
                    'Depending on the size of the video, it might take up to a minute to start.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
              _warningDisplayed = true;
            }
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
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
