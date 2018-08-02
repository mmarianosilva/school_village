import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import '../contact/contact.dart';
import '../forgot/forgot.dart';
import '../../util/analytics_helper.dart';
import '../student_login/student_login.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "School Village";

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

  onLogin() async {
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
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text).then((user) {
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

  onForgot() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Forgot()),
    );
  }

  createAccount() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Contact()),
    );
  }

  studentLogin() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new StudentLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Image.asset('assets/images/logo.png'),
        ),
        title: new Text(title, textAlign: TextAlign.center, style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Email',
                        icon: new Icon(Icons.email)),
                  )
              ),
              const SizedBox(height: 12.0),
              new Flexible(
                  child: new TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Password',
                        labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark),
                        icon: new Icon(Icons.lock)),
                  )
              ),
              const SizedBox(height: 32.0),
              new MaterialButton(
                  minWidth: 200.0,
                  color: Theme.of(context).accentColor,
                  onPressed: onLogin,
                  textColor: Colors.white,
                  child: new Text("LOGIN")
              ),
              const SizedBox(height: 18.0),
              new MaterialButton(
                  minWidth: 200.0,
                  color: Colors.grey.shade300,
                  onPressed: studentLogin,
                  child: new Text("STUDENT LOGIN")
              ),
              const SizedBox(height: 18.0),
              new FlatButton(
                  onPressed: onForgot,
                  child: new Text("Forgot Password?")
              ),
              const SizedBox(height: 18.0),
              new FlatButton(
                  onPressed: createAccount,
                  child: new Text("Create Account")
              ),

            ],
          ),
        ),
      )
    );
  }
}
