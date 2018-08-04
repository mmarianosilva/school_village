import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/analytics_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class StudentLogin extends StatefulWidget {
  @override
  _StudentLoginState createState() => new _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {

  final codeController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "School Village";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if(schools.length == 1) {
      print("Only 1 School");
      var school = await Firestore.instance
          .document(schools[0]['ref'])
          .get();
      print(school.data["name"]);
      await UserHelper.setSelectedSchool(
          schoolId: schools[0]['ref'], schoolName: school.data["name"], schoolRole: schools[0]['role']);
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
        new SnackBar(content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("Logging in")
          ],
        ),
          duration: new Duration(days: 1),
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
            return new AlertDialog(
              title: new Text('Error logging in'),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(error.message)
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Okay'),
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

  getEmail(code) async{
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("Logging in")
          ],
        ),
          duration: new Duration(days: 1),
        )
    );
    var url = "https://us-central1-schoolvillage-1.cloudfunctions.net/api/student/code/$code";
    var response  = await http.get(url);
    print(response.body);
    return response.body;
  }

  onRequest() async{


    var code = codeController.text.trim() ;
    var email = await getEmail(code);
    if(email == null || email == "") {
      _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text('Error logging in'),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Okay'),
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

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(

            title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: new BackButton(color: Colors.grey.shade800)
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
                      controller: codeController,
                      decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'School Code'),
                    )
                ),
                const SizedBox(height: 32.0),
                new MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      onRequest();
                    },
                    textColor: Colors.white,
                    child: new Text("Login")
                )
              ],
            ),
          ),
        )
    );
  }
}
