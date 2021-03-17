import 'package:flutter/material.dart';
import 'package:school_village/model/school_alert.dart';
import 'package:school_village/widgets/hotline/hotline.dart';
import 'package:school_village/widgets/incident_management/incident_management.dart';
import 'package:school_village/widgets/messages/broadcast_messaging.dart';
import 'package:school_village/widgets/talk_around/talk_around_home.dart';

class HeaderButtons extends StatelessWidget {
  final String role;

  static const double iconSize = 80.0;

  const HeaderButtons({Key key, this.role}) : super(key: key);

  void _openBroadcast(BuildContext context, bool editable) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BroadcastMessaging(editable: editable)));
  }

  void _openMessaging(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TalkAroundHome(),
        settings: RouteSettings(
          name: '/talk-around'
        )
    ));
  }

  void _openHotline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Hotline()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    final postAllowed = role == 'district' || role == 'school_admin' || role == 'admin' || role == 'school_security' || role == 'security';
    widgets.add(GestureDetector(
      child: Image.asset('assets/images/broadcast_btn.png', width: iconSize, height: iconSize, fit: BoxFit.fill),
      onTap: () => _openBroadcast(context, postAllowed),
    ));
    widgets.add(GestureDetector(
      child: Image.asset('assets/images/group_message_btn.png', width: iconSize, height: iconSize, fit: BoxFit.fill),
      onTap: () => _openMessaging(context),
    ));
    widgets.add(GestureDetector(
      child: Image.asset('assets/images/anonymous_img.png', width: iconSize, height: iconSize, fit: BoxFit.fill),
      onTap: () => _openHotline(context),
    ));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widgets,
    );
  }
}
