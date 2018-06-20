import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../util/user_helper.dart';
import '../contact/contact.dart';
import '../forgot/forgot.dart';

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
              new FlatButton(
                  onPressed: onForgot,
                  child: new Text("Forgot Password?")
              ),
              const SizedBox(height: 18.0),
              new FlatButton(
                  onPressed: createAccount,
                  child: new Text("Create Account")
              )
            ],
          ),
        ),
      )
    );
  }
}
