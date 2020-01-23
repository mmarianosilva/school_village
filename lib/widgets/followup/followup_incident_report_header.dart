import 'package:flutter/material.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/util/navigation_helper.dart';

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
            child: Text(
              'Incident: ${_data['flattenedIncidents']}',
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Location: ${_data['location']}',
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Text(
                      'Subject: ${_data['flattenedSubjects']}',
                      maxLines: null,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      'Witness: ${_data['flattenedWitnesses']}',
                      maxLines: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Details: ${_data['details']}',
              maxLines: null,
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
