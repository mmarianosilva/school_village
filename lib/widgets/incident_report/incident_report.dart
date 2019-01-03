import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/widgets/incident_report/incident_details.dart';
import 'package:image_picker/image_picker.dart';

class IncidentReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IncidentState();
  }
}

class IncidentState extends State<IncidentReport> {
  var items = {
    'Abduction/Missing': false,
    'Inappropriate Clothing': false,
    'Accident/Injury': false,
    'Intruder': false,
    'Out of Class': false,
    'Bullying': false,
    'Sexual Harassment: Campus': false,
    'Cheating on Test/Classwork': false,
    'Sexual Harassment: Home': false,
    'Depression/Suicidal': false,
    'Disability Related': false,
    'Threats': false,
    'Drugs/Alcohol': false,
    'Unauthorized Vehicle on Campus': false,
    'Fight': false,
    'Use of Cell Phone': false,
    'Fire': false,
    'Vandalism': false,
    'Gang Activity': false,
    'Weapons': false,
  };

  var posItems = {
    'Act of Kindness': false,
    'Commendation': false,
    'Exceptional Class Work': false,
    'Notable Achievement': false,
    'Remarkable Improvement': false
  };

  var subjectNames = [TextEditingController(text: '')];
  var witnessNames = [TextEditingController(text: '')];

  var positiveFeedbackVisible = false;
  var other = '';
  var otherEnabled = false;
  TimeOfDay time = null;
  DateTime date = null;
  String location = '';
  String details = '';
  File image;
  bool isVideoFile;
  String name = '';

  static const textWidth = 65.0;
  static const padding = 10.0;
  static const fontSize = 11.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: BaseAppBar(
          title: Text('Incident Report',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey.shade200,
          elevation: 0.0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: Builder(
          builder: (context) => Stack(children: [
                buildSingleChildScrollView(context),
                positiveFeedbackVisible
                    ? _buildPositiveOverlay()
                    : SizedBox(
                        height: 0,
                        width: 0,
                      )
              ]),
        ));
  }

  _buildPositiveOverlay() {
    return Container(
        color: Colors.transparent,
        child: Center(
            child: Stack(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: _buildPositiveOverlayContent(),
            height: 260,
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: SVColors.incidentReport,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(2.0))),
          ),
          Positioned(
            right: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: SVColors.incidentReport),
              onPressed: () {
                setState(() {
                  positiveFeedbackVisible = false;
                });
              },
            ),
          ),
        ])));
  }

  _buildPositiveOverlayContent() {
    List<Widget> widgets = [];
    posItems.forEach((key, value) {
      widgets.add(_buildCheckBox(key, posItems));
    });

    return (Column(
      children: widgets,
    ));
  }

  SingleChildScrollView buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        constraints: BoxConstraints.expand(
            height: 38.0, width: MediaQuery.of(context).size.width),
        color: SVColors.incidentReport,
        child: Center(
            child: Text(
          'Incident Type',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        )),
      ),
      Container(child: _buildCheckBoxes()),
      _buildLastRow(),
      Container(
        height: 2,
        color: SVColors.incidentReport,
        margin: EdgeInsets.symmetric(vertical: 25.0),
      ),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _buildReporter()),
      SizedBox.fromSize(size: Size(0, 27)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(
                Icons.photo,
                color: SVColors.incidentReportGray,
                size: 36,
              ),
              onPressed: () {
                _getImage(context, ImageSource.gallery, false);
              }),
          IconButton(
              icon: Icon(
                Icons.photo_camera,
                color: SVColors.incidentReportGray,
                size: 36,
              ),
              onPressed: () {
                _getImage(context, ImageSource.camera, false);
              }),
        ],
      ),
      _buildImagePreview(),
      SizedBox.fromSize(size: Size(0, 22)),
      Center(
          child: RaisedButton(
              onPressed: () {
                if (_validateContent(context)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IncidentDetails(
                              items: items,
                              posItems: posItems,
                              other: other,
                              subjectNames: subjectNames,
                              witnessNames: witnessNames,
                              date: date,
                              location: location,
                              details: details,
                              imageFile: image,
                              demo: true,
                            )),
                  );
                }
              },
              color: SVColors.incidentReport,
              child: Text("REVIEW REPORT",
                  style: TextStyle(color: Colors.white)))),
      SizedBox.fromSize(size: Size(0, 31))
    ]));
  }

  _getImage(BuildContext context, ImageSource source, bool isVideo) {
    if (!isVideo) {
      ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
        if (image != null) saveImage(image, isVideo);
      });
    } else {
      ImagePicker.pickVideo(source: source).then((File video) {
        if (video != null) saveImage(video, isVideo);
      });
    }
  }

  void saveImage(File file, bool isVideoFile) async {
    setState(() {
      this.isVideoFile = isVideoFile;
      image = file;
    });
  }

  _showSnackBar(message, context) {
    print(message);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  _validateContent(context) {
    bool atLeastOneSelected = false;
    items.forEach((key, val) {
      if (items[key]) atLeastOneSelected = true;
    });

    bool atLeastOnePosSelected = false;
    posItems.forEach((key, val) {
      if (posItems[key]) atLeastOnePosSelected = true;
    });

    if (!atLeastOnePosSelected && !atLeastOneSelected) {
      _showSnackBar('Please select incident type', context);
      return false;
    }

    if (subjectNames[0].text.isEmpty) {
      _showSnackBar('Enter subject name', context);
      return false;
    }

    return true;
  }

  _buildReporter() {
    const rightMargin = 90.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNames('Subject Name:', subjectNames),
        _buildNames('Witness Name:', witnessNames),
        Row(
          children: [
            Container(
                margin: EdgeInsets.only(top: 10.0),
                width: textWidth + 10.0,
                child: Text(
                  'Time/Date of Incident:',
                  style: TextStyle(fontSize: fontSize),
                )),
            SizedBox(width: padding),
            Flexible(
                child: ButtonTheme(
              minWidth: double.infinity,
              child: OutlineButton(
                  child: Text(date == null
                      ? 'Select Time and Date'
                      : date.toString().substring(0, 16)),
                  onPressed: () {
                    _selectDate();
                  }),
            )),
            SizedBox(width: rightMargin),
          ],
        ),
        Row(
          children: [
            Container(
                margin: EdgeInsets.only(top: 10.0),
                width: textWidth + 10.0,
                child: Text('Location:', style: TextStyle(fontSize: fontSize))),
            SizedBox(width: padding),
            Flexible(child: TextField(onChanged: (val) {
              setState(() {
                this.location = val;
              });
            })),
            SizedBox(width: rightMargin),
          ],
        ),
        SizedBox(
          height: padding,
        ),
        Text(
          'Details:',
          style: TextStyle(fontSize: fontSize),
        ),
        SizedBox(
          height: padding,
        ),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)))),
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          onChanged: (val) {
            this.details = val;
          },
        )
      ],
    );
  }

  _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2010, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != date) {
      _selectTime(picked);
    }
  }

  _buildImagePreview() {
    if (image == null) return SizedBox();

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(image, height: 120.0),
                SizedBox(width: 16.0),
                GestureDetector(
                  onTap: () {
                    _removeImage();
                  },
                  child: Icon(Icons.remove_circle_outline, color: Colors.red),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _removeImage() {
    setState(() {
      image = null;
    });
  }

  _selectTime(DateTime date) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != time) {
      var newDate =
          DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
      print(newDate.toString());
      setState(() {
        this.date = newDate;
      });
    }
  }

  _buildNames(title, names) {
    List<Widget> widgets = [];
    for (int i = 0; i < names.length; i++) {
      widgets.add(Row(
        children: [
          Container(
              margin: EdgeInsets.only(top: 10.0),
              width: textWidth + 10.0,
              child: Text(
                title,
                style: TextStyle(fontSize: fontSize),
              )),
          SizedBox(width: padding),
          Flexible(
              child: TextField(
                  controller: names[i],
                  onChanged: (val) {
                    setState(() {});
                  })),
          Opacity(
              opacity: i > 0 ? 1.0 : 0.0,
              child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    fillColor: Colors.redAccent,
                    elevation: 0.0,
                    child: Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                    onPressed: i > 0
                        ? () {
                            setState(() {
                              names.removeAt(i);
                            });
                          }
                        : null,
                  ))),
          Container(
              width: 25.0,
              height: 25.0,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: RawMaterialButton(
                shape: CircleBorder(),
                fillColor: Colors.green,
                elevation: 0.0,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    names.add(TextEditingController(text: ''));
                  });
                },
              )),
        ],
      ));
    }
    return Column(children: widgets);
  }

  _buildLastRow() {
    return Container(
        height: 55,
        child: Row(
          children: [
            SizedBox(
              width: 26,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      positiveFeedbackVisible = !positiveFeedbackVisible;
                    });
                  },
                  color: SVColors.incidentReport,
                  child: Text("Positive Feedback",
                      style: TextStyle(color: Colors.white))),
            ),
            SizedBox(
              width: 6,
            ),
            Checkbox(
              value: otherEnabled,
              onChanged: (val) {
                setState(() {
                  otherEnabled = val;
                });
              },
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 80,
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    other = val;
                  });
                },
                decoration: InputDecoration(hintText: 'Other'),
              ),
            )
          ],
        ));
  }

  _buildCheckBoxes() {
    List<Widget> widgets = [];
    items.forEach((key, value) {
      widgets.add(_buildCheckBox(key, items));
    });

    List<Widget> rows = [];
    for (var i = 0; i < items.length; i += 2) {
      var row = Row(children: <Widget>[widgets[i], widgets[i + 1]]);
      var box = Container(
        width: MediaQuery.of(context).size.width,
        height: 55.0,
        child: row,
      );
      rows.add(box);
    }

    return Column(children: rows);
  }

  _buildCheckBox(title, items) {
    var val = items[title];
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: CheckboxListTile(
          value: val,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              items[title] = value;
            });
          },
          title: Text(title)),
    );
  }
}
