import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:school_village/components/icon_button.dart';
import 'package:school_village/util/localizations/localization.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageAddress;

  ImageViewScreen(this.imageAddress);

  @override
  build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      picView(context),
      Container(
          margin: EdgeInsets.only(left: 15.0, top: 30.0),
          child: Card(
            color: Colors.transparent,
            shape: CircleBorder(),
            child: CustomIconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ))
    ]));
  }

  Widget picView(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(imageAddress),
      loadingBuilder: (context, event) => Center(
        child: Text(localize("Loading", context),
            style: TextStyle(color: Colors.white)),
      ),
      // loadingChild: Text(localize("Loading", context),
      //     style: TextStyle(color: Colors.white)),
      minScale: PhotoViewComputedScale.covered,
    );
  }
}
