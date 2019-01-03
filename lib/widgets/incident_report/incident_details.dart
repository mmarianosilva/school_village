import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/colors.dart';
import 'package:intl/intl.dart';
import 'package:school_village/util/user_helper.dart';

final dateFormatter = DateFormat('M / DD / y');
final timeFormatter = DateFormat('hh:mm a');

class IncidentDetails extends StatefulWidget {
  final Map<String, bool> items;
  final Map<String, bool> posItems;
  final String other;
  final List<TextEditingController> subjectNames;
  final List<TextEditingController> witnessNames;
  final DateTime date;
  final String location;
  final String details;
  final bool demo;
  final File imageFile;

  IncidentDetails(
      {Key key,
      this.items,
      this.posItems,
      this.other,
      this.subjectNames,
      this.witnessNames,
      this.date,
      this.location,
      this.details,
      this.demo,
      this.imageFile})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IncidentDetailsState(
        items: items,
        posItems: posItems,
        other: other,
        subjectNames: subjectNames,
        witnessNames: witnessNames,
        date: date,
        location: location,
        details: details,
        imageFile: imageFile,
        demo: demo);
  }
}

class IncidentDetailsState extends State<IncidentDetails> {
  final Map<String, bool> items;
  final Map<String, bool> posItems;
  final String other;
  final List<TextEditingController> subjectNames;
  final List<TextEditingController> witnessNames;
  final DateTime date;
  final String location;
  final String details;
  final bool demo;
  final File imageFile;
  String name = '';

  @override
  void initState() {
    super.initState();
    if (demo) getName();
  }

  getName() async {
    FirebaseUser _user = await UserHelper.getUser();

    DocumentReference _userRef =
        Firestore.instance.document("users/${_user.uid}");
    _userRef.get().then((user) {
      setState(() {
        name = "${user.data['firstName']} ${user.data['lastName']}";
      });
    });
  }

  IncidentDetailsState(
      {this.items,
      this.posItems,
      this.other,
      this.subjectNames,
      this.witnessNames,
      this.date,
      this.location,
      this.details,
      this.demo,
      this.imageFile});

  @override
  Widget build(BuildContext context) {
    var incident = '';
    items.forEach((key, value) {
      if (items[key]) {
        incident += key + ', ';
      }
    });
    posItems.forEach((key, value) {
      if (posItems[key]) {
        incident += key + ', ';
      }
    });

    if (!other.isEmpty) {
      incident = incident.substring(0, incident.length - 2);
    } else {
      incident += other;
    }

    var subject = '';
    for (var i = 0; i < subjectNames.length; i++) {
      subject += subjectNames[i].text;
      if (i < subjectNames.length - 1) {
        subject += ', ';
      }
    }

    var witness = '';
    for (var i = 0; i < witnessNames.length; i++) {
      witness += witnessNames[i].text;
      if (i < witnessNames.length - 1) {
        witness += ', ';
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: BaseAppBar(
        title: Text('Incident Report: Review/Send',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKeyValueText('Incident', incident),
                    SizedBox.fromSize(size: Size(0, 10.0)),
                    _buildKeyValueText('Subject', subject),
                    SizedBox.fromSize(size: Size(0, 10.0)),
                    _buildKeyValueText('Witness', witness),
                    SizedBox.fromSize(size: Size(0, 10.0)),
                    _buildKeyValueText('Date', dateFormatter.format(date)),
                    SizedBox.fromSize(size: Size(0, 10.0)),
                    _buildKeyValueText('Time', timeFormatter.format(date)),
                    SizedBox.fromSize(size: Size(0, 10.0)),
                    _buildKeyValueText('Location', location),
                    Container(
                      height: 1,
                      color: SVColors.incidentReport,
                      margin: EdgeInsets.symmetric(vertical: 15),
                    ),
                    Text('Details',
                        style: TextStyle(
                            color: SVColors.incidentReportGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        details,
                      ),
                    ),
                    _buildImagePreview(),
                    _buildKeyValueText('Reported by', name),
                    SizedBox.fromSize(size: Size(0, 26.0)),
                    Center(
                        child: RaisedButton(
                            onPressed: () {},
                            color: SVColors.incidentReportRed,
                            child: Text("SEND REPORT",
                                style: TextStyle(color: Colors.white)))),
                    SizedBox.fromSize(size: Size(0, 30.0)),
                    Center(
                        child: RaisedButton(
                            onPressed: () {
                              if (demo) {
                                Navigator.pop(context);
                              }
                            },
                            color: SVColors.incidentReport,
                            child: Text("EDIT REPORT",
                                style: TextStyle(color: Colors.white))))
                  ]))),
    );
  }

  _buildImagePreview() {
    if (imageFile == null) {
      return SizedBox();
    }
    return Center(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Image.file(imageFile, height: 150)));
  }

  _buildKeyValueText(key, value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(key + ':  ',
          style: TextStyle(
              color: SVColors.incidentReportGray,
              fontWeight: FontWeight.bold,
              fontSize: 16)),
      Expanded(
          child: Text(value,
              style:
                  TextStyle(color: SVColors.incidentReportGray, fontSize: 16)))
    ]);
  }
}
