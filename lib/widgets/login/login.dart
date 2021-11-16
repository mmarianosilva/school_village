import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/constants.dart';
import 'package:school_village/util/file_helper.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/contact/contact.dart';
import 'package:school_village/widgets/forgot/forgot.dart';
import 'package:school_village/util/analytics_helper.dart';
import 'package:school_village/widgets/sign_up/request_more_information.dart';
import 'package:school_village/widgets/sign_up/sign_up_personal.dart';
import 'package:school_village/widgets/student_login/student_login.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _checkedPolicy = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = "MarinaVillage";
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  checkIfOnlyOneSchool() async {
    var schools = await UserHelper.getSchools();
    if (schools.length == 1) {
      print("Only 1 School");
      var school =
          await FirebaseFirestore.instance.doc(schools[0]['ref']).get();
      print(school.data()["name"]);
      await UserHelper.setSelectedSchool(
          schoolId: schools[0]['ref'],
          schoolName: school.data()["name"],
          schoolRole: schools[0]['role']);
      return true;
    }
    return false;
  }

  proceed(DocumentSnapshot<Map<String, dynamic>> userSnapshot) async {
      await checkIfOnlyOneSchool();
      FileHelper.downloadRequiredDocuments();
      AnalyticsHelper.logLogin();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  RegExp emailExp = new RegExp(
      '([a-zA-Z0-9]+(?:[._+-][a-zA-Z0-9]+)*)@([a-zA-Z0-9]+(?:[.-][a-zA-Z0-9]+)*[.][a-zA-Z]{2,})',
      multiLine: false,
      caseSensitive: false);

  showErrorDialog(String error) {
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

    if (passwordController.text.trim().length < 6) {
      FocusScope.of(context).requestFocus(passwordFocusNode);
      showErrorDialog(localize('Password my be at least 6 characters'));
      return;
    }
    if (!_checkedPolicy) {
      FocusScope.of(context).unfocus();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Row(
          children: <Widget>[
            Flexible(
               child: Text(localize("You must accept our Terms and Privacy Policy"))),
          ],
        ),
        duration: Duration(seconds: 2),
      ));

      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Text(localize("Logging in"))
        ],
      ),
      duration: Duration(days: 1),
    ));

    UserHelper.signIn(
            email: emailController.text.trim().toLowerCase(),
            password: passwordController.text)
        .then((auth) {
      if (auth.user != null) {
        String userPath = "/users/${auth.user.uid}";
        print(auth.user);
        DocumentReference userRef = FirebaseFirestore.instance.doc(userPath);
        userRef.get().then((userSnapshot) {
          final Map<String,dynamic> _originalData = userSnapshot.data();
          print("User data is ${userSnapshot.data()}");
          String error = '';
          if(_originalData['vendor']==true){
            if(_originalData['account_status']!='reviewed'){
              error = 'Your account was rejected due to illicit content. Please contact admin';
              _scaffoldKey.currentState
                  .hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
              showErrorDialog(error);
            }
            if(!auth.user.emailVerified){
              error = 'Kindly verify your email address on your registered email address.';
              _scaffoldKey.currentState
                  .hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
              showErrorDialog(error);
            }
          }
          if(error.isEmpty){

            proceed(userSnapshot);
          }

        });
      }
    }).catchError((error) {
      _scaffoldKey.currentState
          .hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Image.asset('assets/images/splash_text.png', height: 120),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: TextField(
                  autocorrect: false,
                  controller: emailController,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                  focusNode: emailFocusNode,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: localize('Email'),
                    icon: const Icon(Icons.email),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: passwordController,
                  obscureText: true,
                  focusNode: passwordFocusNode,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: localize('Password'),
                    labelStyle: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: Theme.of(context).primaryColorDark),
                    icon: const Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: termsAndConditionsText(),
                value: _checkedPolicy,
                onChanged: (val) {
                  setState(() {
                    _checkedPolicy = val;
                  });
                },
                selected: false,
              ),
              const SizedBox(height: 8.0),
              MaterialButton(
                minWidth: 200.0,
                color: Theme.of(context).accentColor,
                onPressed: onLogin,
                textColor: Colors.white,
                child: Text(localize("Login").toUpperCase()),
              ),
              FlatButton(
                onPressed: onForgot,
                child: Text(localize("Forgot Password?")),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SignUpPersonal()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    localize("Sign Up"),
                    style: TextStyle(
                      color: Color(0xff0a7aff),
                      fontSize: 17.0,
                      letterSpacing: 0.39,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RequestMoreInformation()));
                  },
                  child: Text(
                    localize("Request more information"),
                    style: TextStyle(
                      color: Color(0xff0a7aff),
                      fontSize: 17.0,
                      letterSpacing: 0.39,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ));
  }

  Widget termsAndConditionsText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Color(0xff323339),
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          height: 18.0 / 14.0,
          letterSpacing: 0.62,
        ),
        children: [
          TextSpan(
            text: localize("By continuing you accept our "),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () async {
                if (await canLaunch(Constants.termsOfServiceUrl)) {
                  launch(Constants.termsOfServiceUrl);
                }
              },
              child: Text(
                localize("Terms"),
                style: TextStyle(
                  color: Color(0xff0a7aff),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  height: 18.0 / 14.0,
                  letterSpacing: 0.62,
                ),
              ),
            ),
          ),
          TextSpan(
            text: localize(" and "),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () async {
                if (await canLaunch(Constants.privacyPolicyUrl)) {
                  launch(Constants.privacyPolicyUrl);
                }
              },
              child: Text(
                localize("Privacy Policy"),
                style: TextStyle(
                  color: Color(0xff0a7aff),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  height: 18.0 / 14.0,
                  letterSpacing: 0.62,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}
