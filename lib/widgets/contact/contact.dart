import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => new _ContactState();
}

class _ContactState extends State<Contact> {

  final emailController = new TextEditingController();
  final fNameController = new TextEditingController();
  final lNameController = new TextEditingController();
  final schoolController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "School Village";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  onRequest() {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("Requesting in")
          ],
        ),
          duration: new Duration(milliseconds: 1000),
        )
    );

    var email = emailController.text.trim().toLowerCase();
    var fName = emailController.text.trim().toLowerCase();
    var lName = emailController.text.trim().toLowerCase();
    var school = emailController.text.trim().toLowerCase();

    CollectionReference collection  = Firestore.instance.collection('requests');
    final DocumentReference document = collection.document();


    document.setData(<String, dynamic>{
      'email': email,
      'firstName': fName,
      'lastName': lName,
      'school': school,
      'createdAt' : new DateTime.now().millisecondsSinceEpoch
    });
    print("Added Request " + document.documentID);

    Navigator.of(context).pop();
  }

  onForgot() {

  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(

          title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade400,
          elevation: 0.0,
        ),
        body: new Center(
          child: new Container(
            padding: new EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
            child: new Column(
              children: <Widget>[
                const SizedBox(height: 18.0),
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
