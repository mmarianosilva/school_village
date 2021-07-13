import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';

class Forgot extends StatefulWidget {
  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final emailController = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final schoolController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = "Marina Village";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  onRequest() async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Text(localize("Requesting password change"))
        ],
      ),
      duration: Duration(milliseconds: 1000),
    ));

    var email = emailController.text.trim().toLowerCase();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _scaffoldKey.currentState
          .hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localize('Email Sent')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [Text(localize('Please check your email and follow the instructions to reset your password.'))],
                ),
              ),
              actions: [
                FlatButton(
                  child: Text(localize('Okay')),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } catch (e) {
      _scaffoldKey.currentState
          .hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showErrorDialog(e.message);
    }
  }

  showErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Error Resetting Password')),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(error)],
              ),
            ),
            actions: [
              FlatButton(
                child: Text(localize('Okay')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  onForgot() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: BaseAppBar(
            title: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800)),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 18.0),
//              Image.asset('assets/images/logo.png'),
                Flexible(
                    child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: localize('Email')),
                )),
                const SizedBox(height: 32.0),
                MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: onRequest,
                    textColor: Colors.white,
                    child: Text(localize("Reset Password")))
              ],
            ),
          ),
        ));
  }
}
