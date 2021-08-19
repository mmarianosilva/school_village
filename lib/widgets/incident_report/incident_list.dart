import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/incident_report/incident_details.dart';
import 'package:school_village/util/localizations/localization.dart';

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
  String _role = '';
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<DocumentSnapshot> reports = [];
  StreamSubscription<QuerySnapshot> _incidentListSubscription;

  IncidentListState({this.id});

  getUserDetails(MainModel model) async {
    id = (await UserHelper.getUser()).uid;
    _schoolId = await UserHelper.getSelectedSchoolID();
    _schoolSnapshot = await FirebaseFirestore.instance.doc(_schoolId).get();
    _schoolName = _schoolSnapshot.data()['name'];
    _role = await UserHelper.getSelectedSchoolRole();
    _handleMessageCollection();
    await UserHelper.loadIncidentTypes();
    setState(() {
      isLoaded = true;
    });
  }

  _handleMessageCollection() async {
    if (_role == 'security') {
      String escapedSchoolId = _schoolId.substring("schools/".length);
      final List<DocumentSnapshot> securityUsers = (await FirebaseFirestore.instance.collection("users").where("associatedSchools.$escapedSchoolId.role", isEqualTo: "school_security").get()).docs;
      _incidentListSubscription = FirebaseFirestore.instance
          .collection("$_schoolId/incident_reports")
          .where("createdById", whereIn: securityUsers.map((security) => security.id).toList())
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((data) {
            setState(() {
              reports = data.docs;
            });
      });
    } else if (_role != 'boater' && _role !='vendor' && _role!='maintenance') {
      _incidentListSubscription = FirebaseFirestore.instance
          .collection("$_schoolId/incident_reports")
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((data) {
        setState(() {
          reports = data.docs;
        });
      });
    } else {
      final List<DocumentSnapshot> documents = (await FirebaseFirestore.instance
          .collection("$_schoolId/incident_reports")
          .where("createdById", isEqualTo: id)
          .orderBy("createdAt", descending: true)
          .get()).docs;
      setState(() {
        reports = documents;
      });
    }
  }


  Widget _buildList() {


    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, int index) {
        final DocumentSnapshot document = reports[index];
        List<String> subjectNames = List<String>.from(document.data()['subjects']);
        List<String> witnessNames = List<String>.from(document.data()['witnesses']);

        List<String> items = List<String>.from(document.data()['incidents']);
        List<String> posItems =
        List<String>.from(document.data()['positiveIncidents']);

        var report = '';

        items.forEach((value) {
          print(value);
          report += '${UserHelper.negativeIncidents[value] ?? 'Unknown incident'}' + ', ';
        });
        posItems.forEach((value) {
          report += '${UserHelper.positiveIncidents[value] ?? 'Unknown incident'}' + ', ';
        });

        var other = document.data()['other'];
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
                  "${dateTimeFormatter.format(DateTime.fromMillisecondsSinceEpoch(document.data()['createdAt']))}"),
              trailing: FlatButton(
                child: Text(localize('VIEW')),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => IncidentDetails(
                          firestoreDocument: document,
                          demo: false,
                          details: document.data()['details'],
                          date: DateTime.fromMillisecondsSinceEpoch(
                              document.data()['date']),
                          name: document.data()['createdBy'],
                          reportedById: document.data()['createdById'],
                          location: document.data()['location'],
                          witnessNames: witnessNames,
                          subjectNames: subjectNames,
                          items: items,
                          posItems: posItems,
                          imgUrl: document.data()['image'],
                          other: document.data()['other'],),
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
            title: Column(
              children: <Widget>[
                Text(localize('Incident Report Log'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
                Text(_schoolName,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16.0)),
              ],
            ),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800),
          ),
          body: !isLoaded ? Text(localize("Loading..")) : _buildList());
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
