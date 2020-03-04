import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/contact/contact.dart';
import 'package:school_village/widgets/forgot/forgot.dart';
import 'package:school_village/util/analytics_helper.dart';
import 'package:school_village/widgets/student_login/student_login.dart';
import 'package:school_village/util/localizations/localization.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = "School Village";
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if (schools.length == 1) {
      print("Only 1 School");
      var school = await Firestore.instance.document(schools[0]['ref']).get();
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
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  RegExp emailExp = new RegExp('([a-zA-Z0-9]+(?:[._+-][a-zA-Z0-9]+)*)@([a-zA-Z0-9]+(?:[.-][a-zA-Z0-9]+)*[.][a-zA-Z]{2,})',
      multiLine: false, caseSensitive: false);

  showErrorDialog(String error){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localize('Error logging in')),
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

  onLogin() async {
    if (!emailExp.hasMatch(emailController.text.trim())) {
      FocusScope.of(context).requestFocus(emailFocusNode);
      showErrorDialog(localize('Please enter valid email'));
      return;
    }

    if(passwordController.text.trim().length < 6){
      FocusScope.of(context).requestFocus(passwordFocusNode);
      showErrorDialog(localize('Password my be at least 6 characters'));
      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[CircularProgressIndicator(), Text(localize("Logging in"))],
      ),
      duration: Duration(days: 1),
    ));

    UserHelper.signIn(email: emailController.text.trim().toLowerCase(), password: passwordController.text).then((user) {
      print(user);
      proceed();
    }).catchError((error) {
      _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      showErrorDialog(error.message);
    });
  }

  onForgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Forgot()),
    );
  }

  createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Contact()),
    );
  }

  studentLogin(role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentLogin(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: BaseAppBar(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo.png'),
          ),
          title: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
        ),
        body: Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
              child: SingleChildScrollView(
                child:Column(
                  children: [
                    const SizedBox(height: 18.0),
//              Image.asset('assets/images/logo.png'),
                    Container(
                        width: MediaQuery.of(context).size.width - 40.0,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocusNode,
                          decoration:
                          InputDecoration(border: const UnderlineInputBorder(), hintText: 'Email', icon: Icon(Icons.email)),
                        )),
                    const SizedBox(height: 12.0),
                    Container(
                        width: MediaQuery.of(context).size.width - 40.0,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          focusNode: passwordFocusNode,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: localize('Password'),
                              labelStyle:
                              Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark),
                              icon: Icon(Icons.lock)),
                        )),
                    const SizedBox(height: 32.0),
                    MaterialButton(
                        minWidth: 200.0,
                        color: Theme.of(context).accentColor,
                        onPressed: onLogin,
                        textColor: Colors.white,
                        child: Text(localize("LOGIN"))),
                    const SizedBox(height: 18.0),
                    MaterialButton(
                        minWidth: 200.0,
                        color: Colors.grey.shade300,
                        onPressed: () {
                          studentLogin("student");
                        },
                        child: Text(localize("STUDENT LOGIN"))),
                    const SizedBox(height: 18.0),
                    MaterialButton(
                        minWidth: 200.0,
                        color: Colors.grey.shade300,
                        onPressed: () {
                          studentLogin("family");
                        },
                        child: Text(localize("FAMILY LOGIN"))),
                    const SizedBox(height: 18.0),
                    FlatButton(onPressed: onForgot, child: Text(localize("Forgot Password?"))),
                    const SizedBox(height: 18.0),
                    FlatButton(onPressed: createAccount, child: Text(localize("Create Account"))),
                  ],
                ),
              ),
            )));
  }
}
