import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import 'content.dart';

class Hotline extends StatefulWidget {
  @override
  _HotlineState createState() => new _HotlineState();
}

class _HotlineState extends State<Hotline> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _schoolId = '';
  String _schoolName = '';
  bool isLoaded = false;
  bool isEnglish = true;
  int numCharacters = 0;
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

  _buildText() {
    if(isEnglish){
      return new HtmlView(
        data: HotlineContent.english,
      );
    } else {
      return new HtmlView(
        data: HotlineContent.spanish,
      );
    }
  }

  _buildInputBox() {
    return new TextField(
      maxLines: 6,
      controller: customAlertController,
      onChanged: (String text) {
        setState(() {
          numCharacters = customAlertController.text.length;
        });
      },
      decoration: new InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Message'),
    );
  }

  _buildContent() {
    return new SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new SizedBox(height: 12.0),
          new Row(
            children: <Widget>[
              Text("English", style: TextStyle(color: Colors.white)),
              new Switch(value: !isEnglish, onChanged: (bool value) {
                setState(() {
                  isEnglish = !value;
                });
              }),
              Text("Español", style: TextStyle(color: Colors.white))
            ],
          ),
          _buildText(),
          _buildInputBox()
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
          title: new Text('Safety Hotline',
              textAlign: TextAlign.center,
              style: new TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: new BackButton(color: Colors.grey.shade800),
      ),

      body: new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(12.0),
        decoration: new BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          image: new DecorationImage(
            image: new AssetImage("assets/images/hotline_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoaded ? _buildContent() : Text("Loading...") /* add child content content here */,
      )
    );
  }
}
