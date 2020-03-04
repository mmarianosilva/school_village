import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {

  final emailController = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final schoolController = TextEditingController();
  final phoneController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = "School Village";

  onRequest() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content:
        Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text(localize("Requesting in"))
          ],
        ),
          duration: Duration(milliseconds: 30000),
        )
    );

    var email = emailController.text.trim().toLowerCase();
    var fName = fNameController.text.trim().toLowerCase();
    var lName = lNameController.text.trim().toLowerCase();
    var school = schoolController.text.trim().toLowerCase();
    var phone = phoneController.text.trim().toLowerCase();

    var url = "https://us-central1-schoolvillage-1.cloudfunctions.net/api/contact";
    http.post(url, body: {
      'email': email,
      'firstName': fName,
      'lastName': lName,
      'schoolDistrict': school
    })
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      Navigator.of(context).pop();
    });
  }

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
            leading: BackButton(color: Colors.grey.shade800)
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8.0),
//              Image.asset('assets/images/logo.png'),
                Flexible(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: localize('Email')),
                    )
                ),
                const SizedBox(height: 12.0),
                Flexible(
                    child: TextField(
                      controller: fNameController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: localize('First Name'),
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                Flexible(
                    child: TextField(
                      controller: lNameController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: localize('Last Name'),
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                Flexible(
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: localize('Phone'),
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 12.0),
                Flexible(
                    child: TextField(
                      controller: schoolController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: localize('School District'),
                          labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).primaryColorDark)),
                    )
                ),
                const SizedBox(height: 32.0),
                MaterialButton(
                    minWidth: 200.0,
                    color: Theme.of(context).accentColor,
                    onPressed: onRequest,
                    textColor: Colors.white,
                    child: Text(localize("Request Access"))
                )
              ],
            ),
          ),
        )
    );
  }
}
