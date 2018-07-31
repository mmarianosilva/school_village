import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';

class Hotline extends StatefulWidget {
  @override
  _HotlineState createState() => new _HotlineState();
}

class _HotlineState extends State<Hotline> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _schoolId = '';
  String _schoolName = '';
  bool isLoaded = false;
  final customAlertController = new TextEditingController();

  getUserDetails() async {
    var schoolId = await UserHelper.getSelectedSchoolID();
    var schoolName = await UserHelper.getSchoolName();
    setState(() {
      _schoolId = schoolId;
      _schoolName = schoolName;
      isLoaded = true;
    });
  }

  _buildContent() {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          new SizedBox(height: 32.0),

        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }

    return new Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: new AppBar(
          title: new Text('Alert',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: new BackButton(color: Colors.grey.shade800),
      ),

      body:
        isLoaded ? _buildContent() : Text("Loading..")
    );
  }
}
