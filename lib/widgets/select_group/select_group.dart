import 'package:flutter/material.dart';
import '../../util/user_helper.dart';
import '../broadcast/broadcast.dart';

class SelectGroups extends StatefulWidget {
  @override
  _SelectGroupsState createState() => new _SelectGroupsState();
}

class _SelectGroupsState extends State<SelectGroups> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  BuildContext _context;
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
    _context = context;

    if(_isLoading) {
      getGroups();
    }

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Select Groups", style: new TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        leading: new BackButton(color: Colors.grey.shade800),
      ),
      body: _isLoading ?  new Text('Loading...') : getList(groups),

    );
  }

  writeMessage() {
    print("Navigating");
    Navigator.of(context).pop();
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => new Broadcast(groups: selectedGroups)),
    );
  }

  getList(data) {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if(index == data.length) {
          return  new Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            child: new MaterialButton(
              color: Theme.of(context).accentColor,
              child: new Text("Next"),
              onPressed: selectedGroups.length > 0 ? writeMessage : null,
            ),
          );
        }
        return new CheckboxListTile(
            title: new Text(data[index]["name"]),
            value: selectedGroups.containsKey(data[index]["name"]),
            onChanged: (bool value) {
              setState(() {
                if(!value) {
                  selectedGroups.remove(data[index]["name"]);
                } else {
                  selectedGroups.addAll({data[index]["name"] : true});
                }
              });
            });
      },
      itemCount: data.length + 1,
    );
  }
}
