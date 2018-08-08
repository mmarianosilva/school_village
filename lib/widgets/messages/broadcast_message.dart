import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_scale_boundary.dart';
import 'package:school_village/components/full_screen_image.dart';
import 'package:school_village/components/progress_imageview.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastMessage extends StatelessWidget {
  BroadcastMessage(
      {this.text, this.name, this.initial, this.timestamp, this.self, this.location, this.message, this.imageUrl});

  final String text;
  final String name;
  final String imageUrl;
  final String initial;
  final int timestamp;
  final bool self;
  final dynamic location;
  final DocumentSnapshot message;

  @override
  build(BuildContext context) {
    return _getMessageView(context);
  }

  final nameTextStyle = TextStyle(
      color: Color.fromRGBO(25, 24, 24, 1.0), fontWeight: FontWeight.bold, fontSize: 14.0, letterSpacing: 1.1);

  _getMessageView(context) {
    Widget locationWidget = SizedBox(width: 0.0, height: 0.0);
    if (location != null) {
      locationWidget = GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "Map",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 122, 255, 1.0),
                        fontWeight: nameTextStyle.fontWeight,
                        fontSize: nameTextStyle.fontSize,
                        letterSpacing: nameTextStyle.letterSpacing),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          launch(
              "https://www.google.com/maps/search/?api=1&map_action=map&basemap=satellite&query=${location["latitude"]},${location["longitude"]}");
        },
      );
    }
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
                  children:[
                    Row(children: [
                      Text(name, style: nameTextStyle),
                      Container(
                        child: locationWidget,
                        margin: const EdgeInsets.only(left: 40.0),
                      )
                    ]),
                    Container(
                      child: Text(getMessageDate(timestamp), style: TextStyle(fontSize: 11.0)),
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new ImageViewScreen(
                imageUrl,
                minScale: PhotoViewScaleBoundary.contained,
                maxScale: PhotoViewScaleBoundary.covered,
              )),
    );
  }

  _getImage(context) {
    if (imageUrl == null || imageUrl.trim() == '') {
      return SizedBox();
    }

    return ProgressImage(
      height: 160.0,
      firebasePath: imageUrl,
      onTap: (imgUrl) {
        _openImage(context, imgUrl);
      },
    );
  }
}
