import 'package:flutter/material.dart';
import './dashboard/dashboard.dart';
import './settings/settings.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {

  int index = 0;

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: new AppBar(
        title: new Text("School Village")
      ),
      body: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: index != 0,
            child: new TickerMode(
              enabled: index == 0,
              child: new MaterialApp(home: new Dashboard()),
            ),
          ),
          new Offstage(
            offstage: index != 1,
            child: new TickerMode(
              enabled: index == 1,
              child: new Settings()
            ),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: index,
        onTap: (int index) { setState((){ this.index = index; }); },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text("Home"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            title: new Text("Settings"),
          ),
        ],
      ),
    );
  }
}