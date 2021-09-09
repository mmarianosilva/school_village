import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/localizations/localization.dart';

class SelectGroups extends StatefulWidget {
  final GlobalKey<_SelectGroupsState> key = GlobalKey();
  final Function(bool) onToneSelectedCallback;

  SelectGroups(this.onToneSelectedCallback);

  @override
  _SelectGroupsState createState() =>
      new _SelectGroupsState(onToneSelectedCallback);
}

List<String> allowedGroups() {
  return [];
}

class _SelectGroupsState extends State<SelectGroups> {
  bool _isLoading = true;
  Map<String, bool> selectedGroups = {};
  List<dynamic> groups = List();
  final checkBoxHeight = 33.0;
  final textSize = 14.0;
  int numOfRows = 1;
  bool amberAlert = false;
  final Function(bool) onToneSelectedCallback;
  List<DocumentSnapshot> schoolSnapshots;
  DocumentSnapshot selectedSchool;

  _SelectGroupsState(this.onToneSelectedCallback);

  getGroups() async {
    var schoolGroups = await UserHelper.getSchoolAllGroups();
    var role = await UserHelper.getSelectedSchoolRole();
    if (role == 'school_security') {
      schoolGroups.removeWhere((item) => item["name"] == 'family');
    } else if (role == 'district' || role == 'super_admin') {
      List<Map<String, dynamic>> schools =
          (await UserHelper.getSchools()).cast<Map<String, dynamic>>();
      schools.removeWhere((item) =>
          (item["role"] != "district" && item["role"] != "super_admin"));
      List<DocumentSnapshot> unwrappedSchools =
          await _fetchSchoolSnapshots(schools);
      setState(() {
        schoolSnapshots = unwrappedSchools;
        _isLoading = false;
      });
    }

    setState(() {
      groups.addAll(schoolGroups);
      _isLoading = (role == 'district' || role == 'super_admin') &&
          schoolSnapshots == null;
    });
  }

  List<DropdownMenuItem> _districtSchools() {
    List<String> _schools = List<String>();
    _schools.add("All");
    // schoolSnapshots.removeWhere((element) {
    //   return
    // });
    schoolSnapshots.forEach((element) {
      if (element != null && element.data() != null) {
        _schools.add(element.data()["name"]);
      }
    });
    // _schools.addAll(schoolSnapshots.map((item) {
    //   return item.data()["name"];
    // }));
    return _schools
        .map((value) => DropdownMenuItem(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis),
            ))
        .toList();
  }

  Future<List<DocumentSnapshot>> _fetchSchoolSnapshots(
      List<Map<String, dynamic>> schoolRef) async {
    List<DocumentSnapshot> list = List<DocumentSnapshot>(schoolRef.length);
    for (int i = 0; i < schoolRef.length; i++) {
      list[i] = await FirebaseFirestore.instance.doc(schoolRef[i]["ref"]).get();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: Text(localize('Loading...')))
        : _getList();
  }

  Widget getGroupDropDown() {
    return DropdownButton(
      isExpanded: true,
      items: _districtSchools(),
      onChanged: (value) {
        if (schoolSnapshots
            .where((item) => item.data()["name"] == value)
            .isNotEmpty) {
          setState(() {
            selectedSchool = schoolSnapshots
                .firstWhere((item) => item.data()["name"] == value);
          });
        } else {
          setState(() {
            selectedSchool = null;
          });
        }
      },
      value: selectedSchool != null ? selectedSchool.data()["name"] : "All",
    );
  }

  _getList() {
    List<String> names = List();
    for (var dataVal in groups) {
      String name = '${dataVal["name"]}';
      names.add(name);
    }
    names.removeWhere((name) => !allowedGroups().contains(name));
    names.sort();

    final List<Widget> checkboxes = List<Widget>(names.length);
    int index = 0;
    names.forEach((name) {
      checkboxes[index] = SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        height: checkBoxHeight,
        child: Theme(
          data: ThemeData(unselectedWidgetColor: SVColors.talkAroundBlue),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: selectedGroups.containsKey(name),
                onChanged: (bool value) {
                  setState(() {
                    if (value) {
                      selectedGroups[name] = value;
                    } else {
                      selectedGroups.remove(name);
                    }
                  });
                },
              ),
              Text(
                '${name.substring(0, 1).toUpperCase()}${name.substring(1)}',
                style: TextStyle(
                    color: selectedGroups.containsKey(name)
                        ? SVColors.colorFromHex('#6d98cb')
                        : SVColors.talkAroundBlue,
                    decoration: selectedGroups.containsKey(name)
                        ? TextDecoration.underline
                        : TextDecoration.none),
              ),
            ],
          ),
        ),
      );
      index++;
    });

    return Container(
      color: SVColors.colorFromHex('#e5e5ea'),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(localize("Alert tone:")),
            SizedBox(
              height: checkBoxHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    activeColor: Colors.red,
                    checkColor: Colors.white,
                    value: amberAlert,
                    onChanged: (value) {
                      setState(() {
                        amberAlert = value;
                      });
                      onToneSelectedCallback(amberAlert);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        amberAlert = !amberAlert;
                      });
                    },
                    child: Text(
                      localize("Amber"),
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: checkBoxHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: !amberAlert,
                    onChanged: (value) {
                      setState(() {
                        amberAlert = !value;
                      });
                      onToneSelectedCallback(amberAlert);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        amberAlert = !amberAlert;
                      });
                    },
                    child: Text(localize("2-Tone")),
                  ),
                ],
              ),
            ),
          ],
        ),
        schoolSnapshots != null
            ? Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(flex: 2, child: new Text(localize("Send to: "))),
                    Flexible(flex: 3, child: getGroupDropDown()),
                  ],
                ),
              )
            : SizedBox(),
      ]),
    );
  }
}
