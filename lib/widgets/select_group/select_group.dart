import 'package:flutter/material.dart';
import 'package:school_village/util/colors.dart';
import '../../util/user_helper.dart';

class SelectGroups extends StatefulWidget {
  final GlobalKey<_SelectGroupsState> key = GlobalKey();

  @override
  _SelectGroupsState createState() => new _SelectGroupsState();
}

class _SelectGroupsState extends State<SelectGroups> {
  bool _isLoading = true;
  Map<String, bool> selectedGroups = {};
  List<dynamic> groups;

  getGroups() async {
    var schoolGroups = await UserHelper.getSchoolAllGroups();
    setState(() {
      _isLoading = false;
      groups = schoolGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      getGroups();
    }
    return _isLoading ? Text('Loading...') : getList(groups);
  }

  getList(data) {
    List<Widget> rows = List();
    List<String> names = List();

    for (var dataVal in data) {
      String name = '${dataVal["name"]}';
      names.add(name);
    }

    for (var i = 0; i < names.length; i++) {
      var j = 0;
      List<Widget> row = List();
      print('j=0');
      while (j < 2 && i < names.length) {
        row.add(Container(padding: EdgeInsets.symmetric(vertical: 16.0),child:Expanded(
            child: CheckboxListTile(
                title: Text(names[i].substring(0, 1).toUpperCase() + names[i].substring(1),
                    style: TextStyle(color: SVColors.talkAroundBlue)),
                value: selectedGroups.containsKey(names[i]),
                onChanged: (bool value) {
                  setState(() {
                    if (!value) {
                      selectedGroups.remove(names[i]);
                    } else {
                      selectedGroups.addAll({names[i]: true});
                    }
                  });
                }))));
        print('index= $i');
        if(j < 1){
          i++;
        }
        j++;
      }
      rows.add(Container(
        height: 16.0,
          child: Row(
        children: row,
      )));
    }
    print('column length = ${rows.length}');

    return Container(
      child: Column(
        children: rows,
      ),
      height: 80.0,
    );
  }
}
