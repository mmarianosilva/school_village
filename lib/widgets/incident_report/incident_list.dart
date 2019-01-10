import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/incident_report/incident_details.dart';
import 'package:scoped_model/scoped_model.dart';

class IncidentList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IncidentListState();
  }
}

class IncidentListState extends State<IncidentList> {
  String _schoolId = '';
  String _schoolName = '';
  String name = '';
  DocumentReference _school;
  DocumentSnapshot _schoolSnapshot;
  bool isLoaded = false;
  List<DocumentSnapshot> reports = [];

  @override
  void initState() {

    super.initState();
  }

  getUserDetails(MainModel model) async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _school = Firestore.instance.document(_schoolId);
    _handleMessageCollection();
    setState(() {
      isLoaded= true;
    });
  }

  _handleMessageCollection() {
    Firestore.instance
        .collection("$_schoolId/incident_reports")
        .orderBy("createdAt")
        .snapshots()
        .listen((data) {
      _handleDocumentChanges(data.documentChanges);
    });
  }

  _handleDocumentChanges(documentChanges) {
    documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        print(change.document);
        reports.add(change.document);
      }
    });

  }

  Widget _buildList() {




    reports.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, int index) {
        final DocumentSnapshot document = reports[index];
//        print(document['witnesses']);
        List<String> subjectNames = List<String>.from(document['subjects']);
        List<String> witnessNames = List<String>.from(document['witnesses']);

        final Map<String, bool> items = Map<String,bool>.from(document['incidents']);
        final Map<String, bool> posItems = Map<String,bool>.from(document['positiveIncidents']);

        return Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(
                document['details'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "${DateTime.fromMillisecondsSinceEpoch(document['createdAt'])}"),
              trailing: FlatButton(
                child: Text('VIEW'),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => IncidentDetails(
                        demo: false,
                        details: document['details'],
                        date: DateTime.fromMillisecondsSinceEpoch(document['date']),
                        name: document['createdBy'],
                        location: document['location'],
                        witnessNames: witnessNames,
                        subjectNames: subjectNames,
                        items: items,
                        posItems: posItems,
                        imgUrl: document['image']
                      ),
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
            title: Text('Incident Reports',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800),
          ),
          body: !isLoaded ? Text("Loading..") : _buildList());
    });
  }
}
