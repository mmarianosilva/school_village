import 'package:flutter/material.dart';
import 'package:school_village/model/talk_around_message.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/incident_management/on_map_interface.dart';
import 'package:school_village/util/localizations/localization.dart';

class IncidentMessage extends StatelessWidget {
  final TalkAroundMessage message;
  final String timestamp;
  final String targetGroup;
  final OnMapInterface onMapClicked;

  IncidentMessage(
      {Key key,
      this.message,
      this.timestamp,
      this.targetGroup,
      this.onMapClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "${message.origin}",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Builder(
                builder: (context) {
                  if (message.latitude != null && message.longitude != null) {
                    return GestureDetector(
                        child: Text(localize("Map", context),
                            style: TextStyle(
                                color: Color.fromARGB(255, 11, 48, 224)),
                            textAlign: TextAlign.end),
                        onTap: () => onMapClicked.onMapClicked(message));
                  } else {
                    return SizedBox();
                  }
                },
              ),
              const SizedBox(width: 16.0),
              Text(timestamp,
                  textAlign: TextAlign.end,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
          child: Builder(builder: (context) {
            if (targetGroup.isNotEmpty) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        Text(localize("From:", context),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                            onTap: () => showContactDialog(context,
                                message.author, message.reportedByPhone),
                            child: Text(
                              message.author,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 11, 48, 224)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Text(
                          localize("To:", context),
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                        Expanded(
                            child: Text(
                          targetGroup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: <Widget>[
                  Text(localize("From: ", context),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                      child: GestureDetector(
                          onTap: () => showContactDialog(
                              context, message.author, message.reportedByPhone),
                          child: Text(message.author,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 11, 48, 224)))))
                ],
              );
            }
          }),
        ),
        RichText(
          text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text: localize("Message: ", context),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: message.message)
              ]),
          textAlign: TextAlign.justify,
        ),
        Divider(color: Colors.red)
      ],
    );
  }
}
