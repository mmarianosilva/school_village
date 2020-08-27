import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:school_village/util/analytics_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class StudentLogin extends StatefulWidget {

  final String role;
  StudentLogin({Key key, this.role}) : super(key: key);

  @override
  _StudentLoginState createState() => new _StudentLoginState(role: role);
}

class _StudentLoginState extends State<StudentLogin> {

  _StudentLoginState({this.role});

  final codeController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = "School Village";
  final String role;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if(schools.length == 1) {
      print("Only 1 School");
      var school = await FirebaseFirestore.instance
          .doc(schools[0]['ref'])
          .get();
      print(school.data()["name"]);
      await UserHelper.setSelectedSchool(
          schoolId: schools[0]['ref'], schoolName: school.data()["name"], schoolRole: schools[0]['role']);
      return true;
    }
    return false;
  }

  proceed() async {
    await checkIfOnlyOneSchool();
    AnalyticsHelper.logLogin();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', (Route<dynamic> route) => false);
  }

  login(email, code) async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content:
        Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text(localize("Logging in"))
          ],
        ),
          duration: Duration(days: 1),
        )
    );

    UserHelper.signIn(
        email: email,
        password: code).then((user) {
          print(user);
          proceed();
    }).catchError((error)  {
      _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localize('Error logging in')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(error.message)
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(localize('Okay')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
      print(error);
    });
  }

  getEmail(code) async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content:
        Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text(localize("Logging in"))
          ],
        ),
          duration: Duration(days: 1),
        )
    );
    var url = "https://us-central1-schoolvillage-1.cloudfunctions.net/api/student/code/$code";
    var response  = await http.get(url);
    print(response.body);
    return response.body;
  }

  onRequest() async {
    var code = codeController.text.trim() ;
    var email = await getEmail(code);
    if(email == null || email == "") {
      _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localize('Error logging in')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(localize('Okay')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
    } else {
      login(email, code);
    }
  }

  onForgot() {

  }

  @override
  Widget build(BuildContext context) {

    UserHelper.setAnonymousRole(role);
    print(role + "Role");

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800)
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 18.0),
//              new Image.asset('assets/images/logo.png'),
                Flexible(
                    child: TextField(
                      autofocus: true,
                      controller: codeController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: localize('School Code')),
                    )
                ),
                const SizedBox(height: 32.0),
                MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      onRequest();
                    },
                    textColor: Colors.white,
                    child: Text(localize("Login"))
                )
              ],
            ),
          ),
        )
    );
  }
}
