
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
  final String url;
  final String message;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  bool _isPlaying = false;

  _VideoAppState({this.url, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: this.message,
      home: Scaffold(
          key: _scaffold,
          body: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 24.0),
              child: Stack(
                  children: <Widget>[centeredPlayer(url),

              IconButton(
              onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.close),
    )],
    ),
    ),
    ),
    );
    }
//TODO test this throughly
  Widget centeredPlayer(String url) {
    final options = VideoPlayerOptions(mixWithOthers: false);
    final controller = VideoPlayerController.network(
        url, videoPlayerOptions: options);
    controller.initialize();
    controller.addListener(() {});

    return VideoPlayer(controller);
  }


}
