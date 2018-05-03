import 'package:flutter/material.dart';
import '../../../util/pdf_handler.dart';

class Dashboard extends StatelessWidget {

  showSafety(context, index) {
    debugPrint("$index");
    switch(index) {
      case 0 :
        PdfHandler.showPdfFromUrl(context, "https://schoolvillage-38a50.firebaseapp.com/Safety_Plan_Centennial_H_S_20171218.pdf");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    var icons = [
      {
        'icon': new Icon(Icons.book),
        'text': "Safety Instructions"
      }
    ];

      return new Material(
        child: new CustomScrollView(
          primary: false,
          slivers: <Widget>[
            new SliverGrid(
              gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return new Container(
                    alignment: Alignment.center,
                    color: Colors.teal[100 * (index % 9)],
                    child: new Column(
                      children: <Widget>[
                        new IconButton(icon: icons[index]['icon'], iconSize: 72.0, onPressed: () => showSafety(context, index)),
                        new Text(icons[index]['text'], textDirection: TextDirection.ltr,)
                      ],
                    ),
                  );
                },
                childCount: icons.length,
              ),
            ),
          ],
        ),
      );
  }
}