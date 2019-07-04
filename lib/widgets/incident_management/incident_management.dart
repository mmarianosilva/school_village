import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class IncidentManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: BaseAppBar(
            title: Text("Incident Management",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, letterSpacing: 1.29)),
            leading: BackButton(color: Colors.grey.shade800),
            backgroundColor: Colors.grey.shade200,
            elevation: 0.0
          ),
          body: Image.asset("assets/images/dummy_incident_management.png"),
        );
      },
    );
  }
}
