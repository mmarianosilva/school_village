import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Forgot extends StatefulWidget {
  @override
  _ForgotState createState() => new _ForgotState();
}

class _ForgotState extends State<Forgot> {

  final emailController = new TextEditingController();
  final fNameController = new TextEditingController();
  final lNameController = new TextEditingController();
  final schoolController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "School Village";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  onRequest() async{
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("Requesting password change")
          ],
        ),
          duration: new Duration(milliseconds: 1000),
        )
    );

    var email = emailController.text.trim().toLowerCase();


    await _auth.sendPasswordResetEmail(email: email);

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
                const SizedBox(height: 32.0),
                new MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: onRequest,
                    textColor: Colors.white,
                    child: new Text("Reset Password")
                )
              ],
            ),
          ),
        )
    );
  }
}
