import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/full_screen_image.dart';
import 'package:school_village/components/progress_imageview.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/talk_around/message_details/message_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification/notification.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({
    this.text,
    this.name,
    this.initial,
    this.timestamp,
    this.self,
    this.phone,
    this.location,
    this.message,
    this.imageUrl,
    this.unread = false});

  final String text;
  final String name;
  final String initial;
  final Timestamp timestamp;
  final bool self;
  final String phone;
  final dynamic location;
  final DocumentSnapshot message;
  final String imageUrl;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return _getMessageView(context);
  }

  final nameTextStyle = TextStyle(
      color: Color.fromARGB(255, 0, 122, 255), fontWeight: FontWeight.bold, fontSize: 16.0);

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
        color: unread ? Color.fromARGB(255, 226, 245, 251) : Colors.transparent,
        child: Row(
          children: [
            Flexible(
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(children: [
                              Expanded(
                                  child: Text(name, style: nameTextStyle)
                              ),
                              Container(
                                child: locationWidget,
                              )
                            ]),
                            Container(
                              child: Text(getMessageDate(timestamp), style: TextStyle(fontSize: 11.0)),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Text(text),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => showContactDialog(context, name, phone),
                    ),
                    _getImage(context)
                  ],
                ))
          ],
        ));
  }

  goToDetails(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageDetail(notification: message.data),
      ),
    );
  }

  _openImage(context, imageUrl) {

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new ImageViewScreen(
              imageUrl,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered
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
