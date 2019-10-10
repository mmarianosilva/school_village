import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showContactDialog(BuildContext context, String name, String phone) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Contact'),
          content: new Text("Do you want to contact $name?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('SMS'),
              onPressed: () {
                Navigator.of(context).pop();
                launch(Uri.encodeFull("sms:$phone"));
              },
            ),
            new FlatButton(
              child: new Text('Phone'),
              onPressed: () {
                Navigator.of(context).pop();
                launch(Uri.encodeFull("tel:$phone"));
              },
            )
          ],
        );
      }
  );
}