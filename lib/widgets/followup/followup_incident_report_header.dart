import 'package:flutter/material.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/util/navigation_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class FollowupIncidentReportHeader extends StatelessWidget {
  final Map<String, dynamic> _data;

  FollowupIncidentReportHeader(this._data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                _data['createdBy'],
                style: TextStyle(color: Colors.blueAccent),
              ),
              Spacer(),
              Text(
                dateFormatter.format(
                    DateTime.fromMillisecondsSinceEpoch(_data['createdAt'])),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                timeFormatter.format(
                    DateTime.fromMillisecondsSinceEpoch(_data['createdAt'])),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: localize('Incident: ', context),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${_data['flattenedIncidents']}'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: localize('Location: ', context),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${_data['location']}'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                              text: localize('Subject: ', context),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: '${_data['flattenedSubjects']}'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: localize('Witness: ', context),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '${_data['flattenedWitnesses']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: localize('Details: ', context),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${_data['details']}'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _data['flattenedImageUrl'] != null
                    ? GestureDetector(
                        onTap: () => NavigationHelper.openMedia(
                            context, _data['flattenedImageUrl']),
                        child: Image.network(
                          _data['flattenedImageUrl'],
                          height: 96.0,
                          fit: BoxFit.scaleDown,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
