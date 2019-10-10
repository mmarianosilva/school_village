import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

//import 'package:photo_view/photo_view_scale_boundary.dart';
import 'package:school_village/components/full_screen_image.dart';
import 'package:school_village/components/full_screen_video.dart';
import 'package:school_village/components/progress_imageview.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastMessage extends StatelessWidget {
  BroadcastMessage(
      {this.text,
      this.name,
      this.initial,
      this.timestamp,
      this.self,
      this.groups,
      this.message,
      this.imageUrl,
      this.isVideo});

  final String text;
  final String name;
  final String imageUrl;
  final String initial;
  final Timestamp timestamp;
  final bool self;
  final List<String> groups;
  final DocumentSnapshot message;
  final bool isVideo;

  @override
  build(BuildContext context) {
    return _getMessageView(context);
  }

  final groupTextStyle =
      TextStyle(color: SVColors.talkAroundBlue, fontSize: 12.0);

  _getGroups() {
    var groupStr = 'To:';
    for (var i = 0; i < groups.length; i++) {
      final name = groups[i];
      groupStr += ' ${name.substring(0, 1).toUpperCase()}${name.substring(1)}';
      if (i < groups.length - 1) {
        groupStr += ',';
      }
    }
    return Text(groupStr, style: groupTextStyle);
  }

  final nameTextStyle = TextStyle(
      color: SVColors.talkAroundBlue,
      fontWeight: FontWeight.bold,
      fontSize: 14.0,
      letterSpacing: 1.1);

  _getMessageView(context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: nameTextStyle),
                    _getGroups(),
                    Container(
                      child: Text(getMessageDate(timestamp),
                          style: TextStyle(fontSize: 11.0)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: Text(text),
                    ),
                  ],
                ),
              ),
              _getImage(context)
            ],
          )),
          SizedBox(width: 32.0)
        ],
      ),
    );
  }

  _openImage(context, imageUrl) {
    if (!isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new ImageViewScreen(imageUrl,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FullScreenVideoView(url: imageUrl, message: text)),
      );
    }
  }

  _getImage(context) {
    if (imageUrl == null || imageUrl.trim() == '') {
      return SizedBox();
    }

    return ProgressImage(
      height: 160.0,
      firebasePath: imageUrl,
      isVideo: isVideo,
      onTap: (imgUrl) {
        _openImage(context, imgUrl);
      },
    );
  }
}
