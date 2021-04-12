import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/localizations/localization.dart';

class SignUpVendor extends StatefulWidget {
  @override
  _SignUpVendorState createState() => _SignUpVendorState();
}

class _SignUpVendorState extends State<SignUpVendor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        backgroundColor: Color(0xffefedea),
        title: Column(
          children: [
            Text(
              localize("MarinaVillage"),
              style: TextStyle(
                color: Color(0xff323339),
                fontSize: 20.0,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              localize("User Sign-Up"),
              style: TextStyle(
                color: Color(0xff323339),
                fontSize: 16.0,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffe5e5ea),
      body: Column(
        children: [],
      ),
    );
  }
}
