import 'package:flutter/material.dart';
import 'package:school_village/util/checkbox.dart';
import 'package:school_village/util/colors.dart';
import 'package:school_village/util/constants.dart';
import '../../util/user_helper.dart';

class SelectGroups extends StatefulWidget {
  final GlobalKey<_SelectGroupsState> key = GlobalKey();

  @override
  _SelectGroupsState createState() => new _SelectGroupsState();
}

class _SelectGroupsState extends State<SelectGroups> {
  bool _isLoading = true;
  Map<String, bool> selectedGroups = {};
  List<dynamic> groups = List();
  final List<Widget> columns = List();
  final checkBoxHeight = 33.0;
  final textSize = 14.0;
  int numOfRows = 1;

  getGroups() async {
    var schoolGroups = await UserHelper.getSchoolAllGroups();

    setState(() {
      groups.addAll(schoolGroups);
      if (groups.length > 2) {
        numOfRows = groups.length <= 4 ? 2 : 3;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      getGroups();
    }
    return _isLoading ? Center(child: Text('Loading...')) : _getList();
  }

  _getHeight() {
    if (numOfRows > 3) {
      return 3;
    }
    return numOfRows;
  }

  _getList() {
    List<String> names = List();
    columns.clear();
    for (var dataVal in groups) {
      String name = '${dataVal["name"]}';
      names.add(name);
    }
    names.sort();

    for (var i = 0; i < names.length; i++) {
      var j = 0;
      List<Widget> columnChildren = List();

      while (j < numOfRows && i < names.length) {
        final name = names[i];
        columnChildren.add(SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: checkBoxHeight,
            child: Theme(
                data: ThemeData(unselectedWidgetColor: SVColors.talkAroundBlue),
                child: CheckboxListTile(
                    isThreeLine: false,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(name.substring(0, 1).toUpperCase() + name.substring(1),
                        style: TextStyle(
                            color: selectedGroups.containsKey(name)
                                ? SVColors.colorFromHex("#6d98cb")
                                : SVColors.talkAroundBlue,
                            decoration:
                                selectedGroups.containsKey(name) ? TextDecoration.underline : TextDecoration.none)),
                    value: selectedGroups.containsKey(name),
                    onChanged: (bool value) {
                      setState(() {
                        if (!value) {
                          selectedGroups.remove(name);
                        } else {
                          selectedGroups.addAll({name: true});
                        }
                      });
                    }))));
        if (j < numOfRows - 1) {
          i++;
        }
        j++;
      }

      while (columnChildren.length < numOfRows) {
        columnChildren.add(SizedBox(width: MediaQuery.of(context).size.width / 2, height: checkBoxHeight));
      }

      columns.add(Column(
        children: columnChildren,
      ));
    }

    return Container(
      color: SVColors.colorFromHex('#e5e5ea'),
      child: Column(children: [
        Align(
          child: Container(
              padding: EdgeInsets.only(top: 3.0),
              child: Text("Select group:",
                  style: TextStyle(
                      color: Color.fromRGBO(50, 51, 57, 1.0),
                      letterSpacing: 1.2,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold))),
        ),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: columns)),
      ]),
      height: (checkBoxHeight * _getHeight()) + 30.0,
    );
  }
}
