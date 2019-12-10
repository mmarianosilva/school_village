import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/incident_report/incident_details.dart';
import 'package:scoped_model/scoped_model.dart';

final dateTimeFormatter = dateFormatting.messageDateFormatter;

class IncidentList extends StatefulWidget {
  final String id;

  IncidentList({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IncidentListState(id: id);
  }
}

class IncidentListState extends State<IncidentList> {
  String id;
  String _schoolId = '';
  String _schoolName = '';
  String name = '';
  DocumentReference _school;
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<DocumentSnapshot> reports = [];
  StreamSubscription<QuerySnapshot> _incidentListSubscription;

  IncidentListState({this.id});

  getUserDetails(MainModel model) async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _school = Firestore.instance.document(_schoolId);
    _handleMessageCollection();
    await UserHelper.loadIncidentTypes();
    setState(() {
      isLoaded = true;
    });
  }

  _handleMessageCollection() {
    _incidentListSubscription = Firestore.instance
        .collection("$_schoolId/incident_reports")
        .orderBy("createdAt")
        .snapshots()
        .listen((data) {
          List<DocumentSnapshot> updatedList = data.documents;
          updatedList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
          setState(() {
            reports = updatedList;
          });
    });
  }


  Widget _buildList() {


    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, int index) {
        final DocumentSnapshot document = reports[index];
        List<String> subjectNames = List<String>.from(document['subjects']);
        List<String> witnessNames = List<String>.from(document['witnesses']);

        List<String> items = List<String>.from(document['incidents']);
        List<String> posItems =
        List<String>.from(document['positiveIncidents']);

        var report = '';

        items.forEach((value) {
          print(value);
          report += '${UserHelper.negativeIncidents[value] ?? 'Unknown incident'}' + ', ';
        });
        posItems.forEach((value) {
          report += '${UserHelper.positiveIncidents[value] ?? 'Unknown incident'}' + ', ';
        });

        var other = document['other'];
        if (other == null || other.isEmpty) {
          report = report.substring(0, report.length - 2);
        } else {
          report += other;
        }

        return Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(
                report,
                maxLines: 3,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "${dateTimeFormatter.format(DateTime.fromMillisecondsSinceEpoch(document['createdAt']))}"),
              trailing: FlatButton(
                child: Text('VIEW'),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => IncidentDetails(
                          demo: false,
                          details: document['details'],
                          date: DateTime.fromMillisecondsSinceEpoch(
                              document['date']),
                          name: document['createdBy'],
                          location: document['location'],
                          witnessNames: witnessNames,
                          subjectNames: subjectNames,
                          items: items,
                          posItems: posItems,
                          imgUrl: document['image'],
                          other: document['other'],),
                    ),
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      if (!isLoaded) {
        getUserDetails(model);
      }

      return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: BaseAppBar(
            title: Text('Incident Report Log',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800),
          ),
          body: !isLoaded ? Text("Loading..") : _buildList());
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_incidentListSubscription != null) {
      _incidentListSubscription.cancel();
    }
  }
}
