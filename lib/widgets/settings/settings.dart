import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/components/base_appbar.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../../model/main_model.dart';
import '../../util/token_helper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentSnapshot _userSnapshot;
  bool isLoaded = false;
  String name = '';
  String _userId;
  String _version;
  String _build;

  getUserDetails(MainModel model) async {
    FirebaseUser user = await UserHelper.getUser();
    print("ID: " + user.uid);
    DocumentSnapshot userSnapshot = await model.getUser();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
      _build = buildNumber;
      _version = version;
      _userSnapshot = userSnapshot;
      name =
      "${_userSnapshot.data['firstName']} ${_userSnapshot.data['lastName']}";
      isLoaded = true;
      _userId = user.uid;
    });
  }
  
  _logout(context, MainModel model) async{
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logging out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text("Logging out")
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
    String token = model.getToken();
    print(token);
    print(_userId);
    await TokenHelper.deleteToken(token, _userId);
    await UserHelper.logout(token);
    model.setUser(null);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', (Route<dynamic> route) => false);
  }

  navigateToSchoolList(BuildContext context) async {
    print('navigateToSchoolList');
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SchoolList()),
    );
    if(result){
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (!isLoaded) {
          getUserDetails(model);
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: BaseAppBar(
            title: Text('Settings',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0,
            leading: BackButton(color: Colors.grey.shade800),
          ),
          body: Column(
            children: <Widget>[
              SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Text(name,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800)),
                ],
              ),
              SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.school, size: 32.0),
                    label: Text('Change School',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _auth.signOut().then((nothing) {
                        navigateToSchoolList(context);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.exit_to_app, size: 32.0),
                    label: Text('Logout',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _logout(context, model);
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    child: Text('Version: $_version Build: $_build',
                        style: TextStyle(
                            fontSize: 8.0, fontWeight: FontWeight.bold)),
                    onPressed: () {
                    },
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }
}
