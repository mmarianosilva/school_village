import 'package:flutter/material.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/widgets/incident_management/incident_management.dart';
import 'package:school_village/widgets/messages/broadcast_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_home.dart';

class HeaderButtons extends StatelessWidget {
  final String role;
  final SchoolAlert alert;

  const HeaderButtons({Key key, this.role, this.alert}) : super(key: key);

  void _openBroadcast(BuildContext context, bool editable) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BroadcastMessaging(editable: editable)));
  }

  void _openMessaging(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TalkAroundHome()));
  }

  void _openIncidentManagement(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => IncidentManagement(
          alert: this.alert,
          role: this.role
        )));
  }

  void _openHotline(BuildContext context) {

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List();

    if (role == 'school_security') {
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/group_message_btn.png', width: 80.0),
        onTap: () => _openMessaging(context),
      ));
      if (alert != null) {
        widgets.add(GestureDetector(
            child: Image.asset(
                'assets/images/incident_management_icon.png', width: 80.0),
            onTap: () => _openIncidentManagement(context)
        ));
      }
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/broadcast_btn.png', width: 80.0),
        onTap: () => _openBroadcast(context, false),
      ));
    } else if (role == 'school_admin') {
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/group_message_btn.png', width: 80.0),
        onTap: () => _openMessaging(context),
      ));
      if (alert != null) {
        widgets.add(SizedBox(width: 20.0));
        widgets.add(GestureDetector(
            child: Image.asset(
                'assets/images/incident_management_icon.png', width: 80.0),
            onTap: () => _openIncidentManagement(context)
        ));
      }
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/broadcast_btn.png', width: 80.0),
        onTap: () => _openBroadcast(context, true),
      ));
    } else if (role == 'school_staff') {
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/group_message_btn.png', width: 80.0),
        onTap: () => _openMessaging(context),
      ));
    } else {
      // Student, Family
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/broadcast_btn.png', width: 80.0),
        onTap: () => _openBroadcast(context, false),
      ));
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/group_message_btn.png', width: 80.0),
        onTap: () => _openMessaging(context),
      ));
      widgets.add(GestureDetector(
        child: Image.asset('assets/images/anonymous_img.png', width: 80.0),
        onTap: () => _openHotline(context),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widgets,
    );
  }
}
