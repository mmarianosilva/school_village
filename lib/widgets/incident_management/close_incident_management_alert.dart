import 'package:flutter/material.dart';
import 'package:school_village/util/localizations/localization.dart';

class CloseIncidentManagementAlert extends StatelessWidget {
  final TextEditingController _incidentReportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0)
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          color: Color.fromARGB(255, 233, 229, 229),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image(image: AssetImage("assets/images/warning_sign.png"), width: 64, height: 64),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              localize("This will terminate the Incident Management Phase", context),
                              maxLines: 2,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500))
                      )
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(localize("This will declare the Incident Management phase of this event to be complete. The Management Dashboard will close and the tracking of Incident Management communications will terminate. Any final instructions to Responders should be broadcasted via Broadcast Messaging prior to terminating.", context), maxLines: null),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(localize("Do you wish to Terminate?", context), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextField(
                  controller: _incidentReportController,
                  decoration: InputDecoration(
                    hintText: localize("Describe the incident resolution to let others know why it's being closed", context),
                  ),
                  maxLines: null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Container(
                        decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            color: Colors.black
                        ),
                        padding: EdgeInsets.all(4.0),
                        width: 80.0,
                        child: Center(
                            child: Text(localize("No", context).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18.0),)
                        ),
                      )
                  ),
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, _incidentReportController.text),
                      child: Container(
                        decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            color: Colors.black
                        ),
                        padding: EdgeInsets.all(4.0),
                        width: 80.0,
                        child: Center(
                            child: Text(localize("Yes", context).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18.0),)
                        ),
                      )
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}
