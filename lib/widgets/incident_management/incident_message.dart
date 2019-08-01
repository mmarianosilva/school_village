
import 'package:flutter/material.dart';
import 'package:school_village/model/talk_around_message.dart';
import 'package:school_village/widgets/incident_management/OnMapInterface.dart';

class IncidentMessage extends StatelessWidget {
  final TalkAroundMessage message;
  final String timestamp;
  final String targetGroup;
  final OnMapInterface onMapClicked;

  IncidentMessage({Key key, this.message, this.timestamp, this.targetGroup, this.onMapClicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          child: Row(
            children: <Widget>[
              Text("Message", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Spacer(),
              GestureDetector(
                  child: Text("Map", style: TextStyle(color: Color.fromARGB(255, 11, 48, 224))),
                  onTap: () => onMapClicked.onMapClicked(message.latitude, message.longitude)),
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
                      child: Text(message.author, style: TextStyle(color: Color.fromARGB(255, 11, 48, 224))),
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
                      child: Text(message.author, style: TextStyle(color: Color.fromARGB(255, 11, 48, 224))))
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
              TextSpan(text: message.message)
            ]
          ),
          textAlign: TextAlign.justify,
        ),
        Divider(color: Colors.red)
      ],
    );
  }
}