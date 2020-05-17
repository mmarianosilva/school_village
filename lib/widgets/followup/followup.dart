import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/followup/followup_comment_box.dart';
import 'package:school_village/widgets/followup/followup_header_item.dart';
import 'package:school_village/widgets/followup/followup_incident_report_header.dart';
import 'package:school_village/widgets/followup/followup_list_item.dart';
import 'package:school_village/util/localizations/localization.dart';

class Followup extends StatefulWidget {
  final String _title;
  final String _firestorePath;

  Followup(this._title, this._firestorePath);

  @override
  _FollowupState createState() => _FollowupState();
}

class _FollowupState extends State<Followup> {
  Map<String, dynamic> _originalData;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .document(widget._firestorePath)
        .get()
        .then((snapshot) async {
      if (widget._title.toLowerCase() == 'incident report') {
        // Flatten incidents
        await UserHelper.loadIncidentTypes();
        final Map<String, String> positiveIncidents =
            UserHelper.positiveIncidents;
        final Map<String, String> negativeIncidents =
            UserHelper.negativeIncidents;
        String flattenedIncidents = '';
        for (String incident in snapshot.data['incidents']) {
          if (positiveIncidents.containsKey(incident)) {
            flattenedIncidents =
                '$flattenedIncidents${positiveIncidents[incident]}, ';
          } else if (negativeIncidents.containsKey(incident)) {
            flattenedIncidents =
                '$flattenedIncidents${negativeIncidents[incident]}, ';
          }
        }
        if (flattenedIncidents.length > 2) {
          snapshot.data['flattenedIncidents'] =
              flattenedIncidents.substring(0, flattenedIncidents.length - 2);
        } else {
          snapshot.data['flattenedIncidents'] = 'Missing data';
        }
        // Flatten subjects
        String flattenedSubjects = '';
        for (String subject in snapshot.data['subjects']) {
          flattenedSubjects = '$flattenedSubjects$subject, ';
        }
        if (flattenedSubjects.length > 2) {
          snapshot.data['flattenedSubjects'] =
              flattenedSubjects.substring(0, flattenedSubjects.length - 2);
        } else {
          snapshot.data['flattenedSubjects'] = 'Missing data';
        }
        // Flatten witnesses
        String flattenedWitnesses = '';
        for (String witness in snapshot.data['witnesses']) {
          flattenedWitnesses = '$flattenedWitnesses$witness, ';
        }
        if (flattenedWitnesses.length > 2) {
          snapshot.data['flattenedWitnesses'] =
              flattenedWitnesses.substring(0, flattenedWitnesses.length - 2);
        } else {
          snapshot.data['flattenedWitnesses'] = 'Missing data';
        }
        // Flatten image URL
        if (snapshot.data['image'] != null &&
            snapshot.data['image'].isNotEmpty) {
          try {
            String url = await FirebaseStorage.instance
                .ref()
                .child(snapshot.data['image'])
                .getDownloadURL();
            snapshot.data['flattenedImageUrl'] = url;
          } on PlatformException catch (ex) {
            if (ex.code == 'FIRStorageErrorDomain') {
              debugPrint('Unable to retrieve photo from storage');
            }
          }
        }
      }
      setState(() {
        _originalData = snapshot.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white70,
        title: Column(
          children: <Widget>[
            Text(
              widget._title,
              style: TextStyle(color: Colors.black),
            ),
            Text(
              localize('Follow-up Reporting'),
              style: TextStyle(color: Colors.blueAccent),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('${widget._firestorePath}/followup')
                      .orderBy('timestamp')
                      .snapshots(),
                  initialData: null,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState != ConnectionState.none) {
                      if (!snapshot.hasData ||
                          snapshot.data.documents.isEmpty) {
                        return Column(
                          children: <Widget>[
                            _originalData != null
                                ? widget._title.toLowerCase() !=
                                        'incident report'
                                    ? FollowupHeaderItem(_originalData)
                                    : FollowupIncidentReportHeader(
                                        _originalData)
                                : Center(child: CircularProgressIndicator()),
                            Text(localize('No followup reports found')),
                          ],
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                            itemCount: snapshot.data.documents.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return _originalData != null
                                    ? widget._title.toLowerCase() !=
                                            'incident report'
                                        ? FollowupHeaderItem(_originalData)
                                        : FollowupIncidentReportHeader(
                                            _originalData)
                                    : CircularProgressIndicator();
                              }
                              final DocumentSnapshot item =
                                  snapshot.data.documents[index - 1];
                              return FollowupListItem(item.data);
                            }),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ),
            SafeArea(child: Container(
              color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: FollowupCommentBox(this.widget._firestorePath))),
          ],
        ),
      ),
    );
  }
}
