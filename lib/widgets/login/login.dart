import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  onLogin() {
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

//    UserHelper.signIn(
//        email: emailController.text.trim().toLowerCase(),
//        password: passwordController.text).

    UserHelper.signIn(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text).then((user) {
          print(user);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        }).catchError((error)  {
          _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
          _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content:
              new Row(
                children: <Widget>[
                  new Text(error.details)
                ],
              ),
              )
          );
          print(error);
        });
  }

  onForgot() {

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Center(
        child: new Container(
          padding: new EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
          child: new Column(
            children: <Widget>[
              const SizedBox(height: 72.0),
              new Image.asset('assets/images/logo.png'),
              new Flexible(
                  child: new TextField(
                    controller: emailController,
                    decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Email', icon: new Icon(Icons.email)),
                  )
              ),
              const SizedBox(height: 12.0),
              new Flexible(
                  child: new TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: new InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Password', icon: new Icon(Icons.lock)),
                  )
              ),
              const SizedBox(height: 32.0),
              new OutlineButton(
                  onPressed: onLogin,
                  textColor: Colors.white,
                  child: new Text("LOGIN"),
                  highlightedBorderColor: Colors.blue.shade900,
                  borderSide: new BorderSide(color: Colors.blue.shade900, width: 5.0)
              ),
              const SizedBox(height: 18.0),
              new FlatButton(
                  onPressed: onForgot,
                  child: new Text("Forgot Password?")
              )
            ],
          ),
        ),
      )
    );
  }
}
