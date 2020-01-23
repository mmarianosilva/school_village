import 'package:flutter/material.dart';
import 'package:school_village/components/full_screen_image.dart';
import 'package:school_village/components/full_screen_video.dart';

class NavigationHelper {
  static openMedia(BuildContext context, String imageUrl,
      {bool isVideo = false, String title = ''}) {
    if (!isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewScreen(imageUrl),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FullScreenVideoView(url: imageUrl, message: title)),
      );
    }
  }
}
