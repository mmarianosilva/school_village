import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';

class IncidentDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IncidentDetailsState();
  }
}

class IncidentDetailsState extends State<IncidentDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: BaseAppBar(
        title: Text('Incident Details',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
            constraints: BoxConstraints.expand(
                height: 1100.0, width: MediaQuery.of(context).size.width),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('assets/images/incident_details.png'),
                  fit: BoxFit.fill),
            ))
      ])),
    );
  }
}
