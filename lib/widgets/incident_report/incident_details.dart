import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/components/progress_imageview.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/util/navigation_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/contact/contact_dialog.dart';
import 'package:school_village/widgets/followup/followup.dart';
import 'package:school_village/util/localizations/localization.dart';

class IncidentDetails extends StatefulWidget {
  final DocumentSnapshot firestoreDocument;
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
  final String reportedById;
  final String imgUrl;

  IncidentDetails(
      {Key key,
      this.firestoreDocument,
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
      this.reportedById,
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
        reportedById: reportedById,
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
  final String reportedById;
  String name;
  String phone;
  String schoolId;
  String userId;
  String imgUrl = '';
  bool loading = true;

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
        if (demo) {
          name = "${user.data['firstName']} ${user.data['lastName']}";
          this.loading = false;
        }
        this.schoolId = schoolId;
      });
    });
    if (!demo) {
      final DocumentSnapshot snapshot =
          await Firestore.instance.document("users/$reportedById").get();
      setState(() {
        this.phone = snapshot["phone"];
        this.loading = false;
      });
    }
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
      this.reportedById,
      this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text(localize('Incident Report'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
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
              Text(localize('Details'),
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
              !demo
                  ? GestureDetector(
                      child: Text(
                        localize('Contact'),
                        style: TextStyle(color: SVColors.talkAroundBlue),
                      ),
                      onTap: () => showContactDialog(context, name, phone),
                    )
                  : SizedBox(),
              SizedBox.fromSize(size: Size(0, 26.0)),
              demo
                  ? Center(
                      child: RaisedButton(
                          onPressed: () {
                            _sendReport();
                          },
                          color: SVColors.incidentReportRed,
                          child: Text(localize("SEND REPORT"),
                              style: TextStyle(color: Colors.white))))
                  : FlatButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Followup(
                              localize('Incident Report'),
                              widget.firestoreDocument.reference.path),
                        ),
                      ),
                      child: Text(
                        localize('Follow-up'),
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
              SizedBox.fromSize(size: Size(0, 15.0)),
            ]),),);
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
      type = imageFile.path.split(".").last != null
          ? imageFile.path.split(".").last
          : type;
      path = path + "." + type;
      print(path);
      await uploadFile(path, imageFile);
    }

    await document.setData(<String, dynamic>{
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



  _buildImagePreview() {
    if (imageFile == null && (imgUrl == null || imgUrl.isEmpty)) {
      return SizedBox();
    }
    if (imgUrl != null) {
      return ProgressImage(
        height: 160.0,
        firebasePath: imgUrl,
        isVideo: false,
        onTap: (imgUrl) {
          NavigationHelper.openMedia(context, imgUrl);
        },
      );
    }

    return Center(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Image.file(
              imageFile,
              height: 150,
              fit: BoxFit.scaleDown,
            )));
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
