import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:photo_view/photo_view.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/components/full_screen_image.dart';
import 'package:school_village/components/progress_imageview.dart';
import 'package:school_village/util/colors.dart';
import 'package:intl/intl.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final dateFormatter = DateFormat('M / dd / y');
final timeFormatter = DateFormat('hh:mm a');

class IncidentDetails extends StatefulWidget {
  final List<String> items;
  final List<String> posItems;
  final String other;
  final List<String> subjectNames;
  final List<String> witnessNames;
  final DateTime date;
  final String location;
  final String details;
  final bool demo;
  final File imageFile;
  final String name;
  final String imgUrl;

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
      this.imageFile,
      this.name,
      this.imgUrl})
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
        demo: demo,
        name: name,
        imgUrl: imgUrl);
  }
}

class IncidentDetailsState extends State<IncidentDetails> {
  static FirebaseStorage storage = FirebaseStorage();

  final List<String> items;
  final List<String> posItems;
  final String other;
  final List<String> subjectNames;
  final List<String> witnessNames;
  final DateTime date;
  final String location;
  final String details;
  final bool demo;
  final File imageFile;
  String name = '';
  String schoolId;
  String userId;
  String imgUrl = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() async {
    FirebaseUser _user = await UserHelper.getUser();
    DocumentReference _userRef =
        Firestore.instance.document("users/${_user.uid}");
    var schoolId = await UserHelper.getSelectedSchoolID();
    _userRef.get().then((user) {
      userId = user.documentID;
      setState(() {
        if (demo) name = "${user.data['firstName']} ${user.data['lastName']}";
        this.schoolId = schoolId;
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
      this.imageFile,
      this.name,
      this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text('Incident Report: Review/Send',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: ModalProgressHUD(child: _renderBody(), inAsyncCall: loading));
  }

  _renderBody() {
    var incident = '';
    items.forEach((value) {
        incident += UserHelper.negativeIncidents[value] + ', ';

    });
    posItems.forEach((value) {
        incident += UserHelper.positiveIncidents[value] + ', ';
    });

    if (other == null || other.isEmpty) {
      incident = incident.substring(0, incident.length - 2);
    } else {
      incident += other;
    }

    var subject = '';
    for (var i = 0; i < subjectNames.length; i++) {
      subject += subjectNames[i];
      if (i < subjectNames.length - 1) {
        subject += ', ';
      }
    }

    var witness = '';
    for (var i = 0; i < witnessNames.length; i++) {
      witness += witnessNames[i];
      if (i < witnessNames.length - 1) {
        witness += ', ';
      }
    }
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              demo
                  ? Center(
                      child: RaisedButton(
                          onPressed: () {
                            _sendReport();
                          },
                          color: SVColors.incidentReportRed,
                          child: Text("SEND REPORT",
                              style: TextStyle(color: Colors.white))))
                  : SizedBox.fromSize(size: Size(0, 0)),
              SizedBox.fromSize(size: Size(0, 15.0)),
            ])));
  }

  _sendReport() async {
    setState(() {
      loading = true;
    });
    CollectionReference collection =
        Firestore.instance.collection('$schoolId/incident_reports');
    final DocumentReference document = collection.document();
    var path = '';

    if (imageFile != null) {
      path = 'Schools/$schoolId/incident_reports/${document.documentID}';
      String type = 'jpeg';
      type = lookupMimeType(imageFile.path).split("/").length > 1
          ? lookupMimeType(imageFile.path).split("/")[1]
          : type;
      path = path + "." + type;
      print(path);
      await uploadFile(path, imageFile);
    }

    document.setData(<String, dynamic>{
      'positiveIncidents': posItems,
      'incidents': items,
      'createdBy': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'createdById': userId,
      'location': location,
      'details': details,
      'date': date.millisecondsSinceEpoch,
      'subjects': subjectNames,
      'witnesses': witnessNames,
      'image': path,
      'other': other
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  uploadFile(String path, File file) async {
    final StorageReference ref = storage.ref().child(path);
    final StorageUploadTask uploadTask = ref.putFile(file);

    String downloadUrl;
    await uploadTask.onComplete.then((val) {
      val.ref.getDownloadURL().then((v) {
        downloadUrl = v;
      });
    });
    return downloadUrl;
  }

  _openImage(context, imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new ImageViewScreen(imageUrl,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered)),
    );
  }

  _buildImagePreview() {
    if (imageFile == null && imgUrl == null) {
      return SizedBox();
    }
    if (imgUrl != null) {
      return ProgressImage(
        height: 160.0,
        firebasePath: imgUrl,
        isVideo: false,
        onTap: (imgUrl) {
          _openImage(context, imgUrl);
        },
      );
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
          child: Text(value == null ? '' : value,
              style:
                  TextStyle(color: SVColors.incidentReportGray, fontSize: 16)))
    ]);
  }
}
