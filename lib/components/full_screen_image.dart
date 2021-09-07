import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_scale_boundary.dart';
import 'package:photo_view/photo_view_scale_state.dart';
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
      loadingChild: Text(localize("Loading", context),
          style: TextStyle(color: Colors.white)),
      minScale: PhotoViewScaleState.contained,
    );
  }
// Widget oldpicView() {
//   return  PhotoView(
//     imageProvider: NetworkImage(imageAddress),
//     loadingBuilder: (context, imageChunkEvent) => Text(localize("Loading", context), style: TextStyle(color: Colors.white)),
//     initialScale:  PhotoViewComputedScale.covered * 6.0,
//     minScale: PhotoViewComputedScale.contained,
//   );
// }
}
