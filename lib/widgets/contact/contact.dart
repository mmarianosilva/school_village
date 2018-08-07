import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import '../../util/user_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => new _ContactState();
}

class _ContactState extends State<Contact> {

  final emailController = new TextEditingController();
  final fNameController = new TextEditingController();
  final lNameController = new TextEditingController();
  final schoolController = new TextEditingController();
  final phoneController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "School Village";

  onRequest() {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("Requesting in")
          ],
        ),
          duration: new Duration(milliseconds: 30000),
        )
    );

    var email = emailController.text.trim().toLowerCase();
    var fName = fNameController.text.trim().toLowerCase();
    var lName = lNameController.text.trim().toLowerCase();
    var school = schoolController.text.trim().toLowerCase();
    var phone = phoneController.text.trim().toLowerCase();

    var url = "https://us-central1-schoolvillage-1.cloudfunctions.net/api/contact";
    http.post(url, body: {
      'email': email,
      'firstName': fName,
      'lastName': lName,
      'schoolDistrict': school
    })
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new BaseAppBar(

          title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: new BackButton(color: Colors.grey.shade800)
        ),
        body: new Center(
          child: new Container(
            padding: new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: new Column(
              children: <Widget>[
                const SizedBox(height: 8.0),
//              new Image.asset('assets/images/logo.png'),
                new Flexible(
                    child: new TextField(
                      controller: emailController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'Email'),
                    )
                ),
                const SizedBox(height: 12.0),
                new Flexible(
                    child: new TextField(
                      controller: fNameController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'First Name',
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                new Flexible(
                    child: new TextField(
                      controller: lNameController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'Last Name',
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                new Flexible(
                    child: new TextField(
                      controller: phoneController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'Phone',
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                new Flexible(
                    child: new TextField(
                      controller: schoolController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'School District',
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 32.0),
                new MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: onRequest,
                    textColor: Colors.white,
                    child: new Text("Request Access")
                )
              ],
            ),
          ),
        )
    );
  }
}
