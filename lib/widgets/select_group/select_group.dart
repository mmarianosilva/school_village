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
  Map<String, bool> allMarinas = Map();
  List<DocumentSnapshot> schoolSnapshots;
  List<DocumentSnapshot> selectedSchools;

  _SelectGroupsState(this.onToneSelectedCallback);
  String truncateString(String data, int length) {
    return (data.length >= length) ? '${data.substring(0, length)}...' : data;
  }

  String getRecipients() {
    if (allMarinas['All'] == true) {
      print(" All is on");
      return 'Send to: All';
    } else {
      print(" All is not on");
      String x = '';
      allMarinas.forEach((key, value) {
        if (value == true) {
          if (x == '') {
            x = key;
          } else {
            x = x + "," + key;
          }
        }
      });
      return 'Send to: ${x}';
    }
  }
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
        allMarinas = _districtSchools();
        if (allMarinas['All'] == true) {
          selectedSchools = schoolSnapshots;
        } else {
          selectedSchools = schoolSnapshots.where((element) {
            return (element != null) &&
                (element.data() != null) &&
                (allMarinas[element.data()["name"]] == true);
          }).toList();
        }
        _isLoading = false;
      });
    }

    setState(() {
      groups.addAll(schoolGroups);
      _isLoading = (role == 'district' || role == 'super_admin') &&
          schoolSnapshots == null;
    });
  }

  Map<String, bool> _districtSchools() {
    List<String> _schools = List<String>();
    _schools.add("All");
    schoolSnapshots.forEach((element) {
      if (element != null && element.data() != null) {
        _schools.add((element.data() as Map<String, dynamic>)['name']);
      }
    });

    return Map<String, bool>.fromIterable(_schools,
        key: (e) => e, value: (e) => true);
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

  Future<Map<String, bool>> _chooseMarinas() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Choose Marinas'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: Text('Cancel'),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        if (allMarinas['All'] == true) {
                          selectedSchools = schoolSnapshots;
                        } else {
                          selectedSchools = schoolSnapshots.where((element) {
                            return (element != null) &&
                                (element.data() != null) &&
                                (allMarinas[element.data()["name"]] == true);
                          }).toList();
                        }
                      });
                      Navigator.pop(context, null);
                      //Navigator.pop(context, cityList);
                    },
                    child: Text('Done'),
                  ),
                ],
                content: Container(
                  width: double.minPositive,
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allMarinas.length,
                    itemBuilder: (BuildContext context, int index) {
                      String _key = allMarinas.keys.elementAt(index);
                      return CheckboxListTile(
                        value: allMarinas[_key],
                        title: Text(_key),
                        checkColor: Colors.white,
                        onChanged: (val) {
                          print("value changing $_key and $val");
                          setState(() {
                            allMarinas[_key] = val;
                            if (_key == "All" && val == true) {
                              //toggleAll(true);
                              allMarinas.updateAll((key, value) => true);
                            } else if (_key == "All" && val == false) {
                              allMarinas.updateAll((key, value) => false);
                              //toggleAll(false);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        });
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
          decoration: BoxDecoration(color: Colors.blue, boxShadow: [
            BoxShadow(
                color: Colors.grey, blurRadius: 4, offset: Offset(0, 2))
          ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //Text(localize("Send to: ")),
                    //getGroupDropDown(),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                        width: 10,
                      ),
                    ),
                    Flexible(
                        flex: 9,
                        child: InkWell(
                          onTap: () async {
                            final data = await _chooseMarinas();
                            setState(() {});
                          },
                          child: new Text(truncateString(getRecipients(), 40)),
                        )),

                  ],
                ),
              )
            : SizedBox(),
      ]),
    );
  }
}
