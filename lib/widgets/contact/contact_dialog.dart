import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:url_launcher/url_launcher.dart';

void showContactDialog(BuildContext context, String name, String phone) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationHelper.of(context).localized('Contact')),
          content: Text("${LocalizationHelper.of(context).localized('Do you want to contact')} $name?"),
          actions: <Widget>[
            FlatButton(
              child: Text(LocalizationHelper.of(context).localized('Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(LocalizationHelper.of(context).localized('SMS')),
              onPressed: () {
                Navigator.of(context).pop();
                launch(Uri.encodeFull("sms:$phone"));
              },
            ),
            FlatButton(
              child: Text(LocalizationHelper.of(context).localized('Phone')),
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