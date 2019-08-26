
import 'package:flutter/material.dart';
import 'package:school_village/model/talk_around_message.dart';
import 'package:school_village/widgets/incident_management/on_map_interface.dart';

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
              Flexible(
                  child: Text("${message.origin}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  flex: 2,
                  fit: FlexFit.tight
              ),
              Flexible(
                  child: GestureDetector(
                    child: Text("Map", style: TextStyle(color: Color.fromARGB(255, 11, 48, 224)), textAlign: TextAlign.end),
                    onTap: () => onMapClicked.onMapClicked(message.latitude, message.longitude)),
                  flex: 1,
                  fit: FlexFit.tight
              ),
              Flexible(
                  child: Text(timestamp, textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  flex: 2,
                  fit: FlexFit.tight
              )
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
                      flex: 2,
                      fit: FlexFit.tight),
                  Flexible(
                      child: Text(message.author, style: TextStyle(color: Color.fromARGB(255, 11, 48, 224))),
                      flex: 8,
                      fit: FlexFit.tight),
                  Flexible(
                      child: Text("To: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                      fit: FlexFit.tight),
                  Flexible(
                      child: Text(targetGroup),
                      flex: 8,
                      fit: FlexFit.tight)
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