import 'package:flutter/material.dart';
import '../../../util/pdf_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  showSafety(context, url) {
    print(url);
    PdfHandler.showPdfFromUrl(context, url);
  }

  @override
  Widget build(BuildContext context) {
    var ref = "schools/eH0twSteQXFpNYRi9nzU";

    var icons = [
      {'icon': new Icon(Icons.book), 'text': "Safety Instructions"}
    ];

    return new FutureBuilder(
        future: Firestore.instance.document(ref).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Loading...');
            case ConnectionState.waiting:
              return new Text('Loading...');
            case ConnectionState.active:
              return new Text('Loading...');
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return new ListView.builder(
                    padding: new EdgeInsets.all(8.0),
//                    itemExtent: 20.0,
                    itemBuilder: (BuildContext context, int index) {
                      return new Column(
                        children: <Widget>[
                          const SizedBox(height: 28.0),
                          new GestureDetector(
                            onTap: () {
                              showSafety(
                                  context,
                                  snapshot.data.data["Documents"][index]
                                      ["Location"]);
                            },
                            child: new Row(
                              children: <Widget>[
                                new Image.asset('assets/images/logo.png',
                                    width: 48.0),
                                new Expanded(
                                    child: new Text(
                                  snapshot.data.data["Documents"][index]
                                      ["Type"],
                                  textAlign: TextAlign.left,
                                  style: new TextStyle(fontSize: 16.0),
                                )),
                                new Icon(Icons.chevron_right)
                              ],
                            ),
                          )
                        ],
                      );
                    },
                    itemCount: snapshot.data.data["Documents"].length);
          }
        });
  }
}
