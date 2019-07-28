
import 'package:flutter/material.dart';

class IncidentMessage extends StatelessWidget {
  final String message;
  final String author;
  final String title;
  final String timestamp;
  final String targetGroup;

  IncidentMessage({Key key, this.title, this.author, this.message, this.timestamp, this.targetGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          child: Row(
            children: <Widget>[
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Spacer(),
              Text("Map", style: TextStyle(color: Colors.blue)),
              Spacer(),
              Text(timestamp, textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
          child: Builder(builder: (context) {
            if (targetGroup.isNotEmpty) {
              return Row(
                children: <Widget>[
                  Flexible(
                      child: Text("From: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 2),
                  Flexible(
                      child: Text(author, style: TextStyle(color: Colors.blue)),
                      flex: 4),
                  Spacer(),
                  Flexible(
                      child: Text("To: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1),
                  Flexible(
                      child: Text(targetGroup),
                      flex: 5)
                ],
              );
            } else {
              return Row(
                children: <Widget>[
                  Flexible(
                      child: Text("From: ", style: TextStyle(fontWeight: FontWeight.bold))),
                  Flexible(
                      child: Text(author, style: TextStyle(color: Colors.blue)))
                ],
              );
            }
          }),
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: "Message: ", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: message)
            ]
          ),
          textAlign: TextAlign.justify,
        ),
        Divider(color: Colors.red)
      ],
    );
  }
}