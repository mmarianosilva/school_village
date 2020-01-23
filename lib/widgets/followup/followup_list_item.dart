import 'package:flutter/material.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/util/navigation_helper.dart';

class FollowupListItem extends StatelessWidget {
  final Map<String, dynamic> _data;

  FollowupListItem(this._data);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        border: Border.all(color: Colors.grey[500], width: 1.0),
      ),
      padding: const EdgeInsets.all(8.0),
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
                dateFormatter.format(_data['timestamp'].toDate()),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                timeFormatter.format(_data['timestamp'].toDate()),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _data['body'],
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: _data['img'] != null
                ? GestureDetector(
                    onTap: () =>
                        NavigationHelper.openMedia(context, _data['img']),
                    child: Image.network(
                      _data['img'],
                      height: 96.0,
                      fit: BoxFit.scaleDown,
                    ),
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }
}
