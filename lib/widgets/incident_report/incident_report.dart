import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/incident_report/incident_details.dart';

class IncidentReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IncidentState();
  }
}

class IncidentState extends State<IncidentReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: BaseAppBar(
        title: Text('Incident Report',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
            constraints:  BoxConstraints.expand(height: 1200.0, width: MediaQuery.of(context).size.width),

            decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage('assets/images/incident_type.png'),
              fit: BoxFit.fill),
        )),
        RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IncidentDetails()),
              );
            },
            color: SVColors.colorFromHex('#12c3ee'),
            child: Text("REVIEW / SIGN REPORT",
                style: TextStyle(color: Colors.white)))
      ])),
    );
  }
}
