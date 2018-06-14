import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.initial, this.timestamp, this.self});
  final String text;
  final String name;
  final String initial;
  final int timestamp;
  final bool self;
  @override
  Widget build(BuildContext context) {
    if(!self) return _getMessageView(context);
    else return _getMyMessageView(context);
  }

  _getMessageView(context){
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(initial), backgroundColor: Colors.redAccent),
          ),
          new Flexible(child: new Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(name, style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text("${time.month}/${time.day} ${time.hour}:${time.minute}", style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
            decoration: new BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: new EdgeInsets.all(8.0),
          )),
          new SizedBox(width: 32.0)
        ],
      ),
    );
  }

  _getMyMessageView(context) {
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.centerRight,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
        new SizedBox(width: 32.0),
          new Flexible(child: new Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text(name, style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text,textAlign: TextAlign.end,),
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text("${time.month}/${time.day} ${time.hour}:${time.minute}", style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
            decoration: new BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: new EdgeInsets.all(8.0),
          )
          ),
          new Container(
            margin: const EdgeInsets.only(left: 16.0),
            child: new CircleAvatar(child: new Text(initial), backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }
}