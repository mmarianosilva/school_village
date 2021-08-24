import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/model/searchable.dart';
import 'package:school_village/model/user.dart';
import 'package:school_village/util/localizations/localization.dart';
import 'package:school_village/util/permission_matrix.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/widgets/search/search_bar.dart';
import 'package:school_village/widgets/search/search_dropdown_field.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';

class TalkAroundCreateClass extends StatefulWidget {
  const TalkAroundCreateClass({Key key, this.group}) : super(key: key);

  final TalkAroundChannel group;

  @override
  _TalkAroundCreateClassState createState() => _TalkAroundCreateClassState();
}

class _TalkAroundCreateClassState extends State<TalkAroundCreateClass> {
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();

  final List<User> _users = List<User>();
  final List<User> _members = List<User>();

  User _admin;
  bool _isLoading = true;
  String _schoolId;
  String _role;

  @override
  void initState() {
    getUsers();
    if (widget.group != null) {
      _groupController.text = widget.group.name;
      _adminNameController.text = widget.group.admin.name;
    }
    super.initState();
  }

  Future<void> getUsers() async {
    _schoolId = await UserHelper.getSelectedSchoolID();
    _role = await UserHelper.getSelectedSchoolRole();
    final escapedSchoolId = _schoolId.substring("schools/".length);
    final List<String> talkAroundPermissions =
        PermissionMatrix.getTalkAroundGroupPermissions(_role);
    print("User role is $_role and perms ${talkAroundPermissions}");
    final QuerySnapshot users = await FirebaseFirestore.instance
        .collection("users")
        .where("associatedSchools.$escapedSchoolId.allowed", isEqualTo: true)
        .get();
    final List<DocumentSnapshot> modifiableUserList = [...users.docs];

    modifiableUserList.removeWhere((userSnapshot) =>
        userSnapshot.data()["associatedSchools"][escapedSchoolId] == null ||
        !talkAroundPermissions.contains(
            userSnapshot.data()["associatedSchools"][escapedSchoolId]["role"]));
    final Iterable<User> data = modifiableUserList.map((e) {
      return User.fromMapAndSchool(e, escapedSchoolId);
    });

    if (widget.group != null) {
      _admin = data.firstWhere(
          (item) =>
              FirebaseFirestore.instance.doc("users/${item.id}") ==
              widget.group.admin.id,
          orElse: () => null);
      _members.clear();
      _members.addAll(data.where((item) =>
          widget.group.members.indexWhere((member) =>
              member.id ==
              FirebaseFirestore.instance.doc("users/${item.id}")) !=
          -1));
    }
    setState(() {
      _isLoading = false;
      _users.clear();
      _users.addAll(data);
    });
  }

  Future<bool> _checkIfUnique(Map<String, dynamic> data) async {
    final query = await FirebaseFirestore.instance
        .collection("$_schoolId/messages")
        .where("name", isEqualTo: data["name"])
        .get();
    if (query.docs.isEmpty) {
      return true;
    }
    final doc = query.docs.first;
    if (widget.group != null) {
      return widget.group.id == doc.id;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: Text(localize("Talk Around")),
        backgroundColor: Color.fromARGB(255, 134, 165, 177),
      ),
      backgroundColor: Color.fromARGB(255, 7, 133, 164),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Color.fromARGB(255, 10, 104, 127),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 64.0,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/images/sv_icon_menu.png"),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SearchBar(
                          controller: _groupController,
                          displayIcon: false,
                          hint: localize('Group Name (no duplicates)'),
                          onTap: () {},
                        ),
                        const SizedBox(height: 8.0),
                        SearchDropdownField(
                          controller: _adminNameController,
                          data: _users != null ? _users : <User>[],
                          hint: localize('Instructor or Group Admin'),
                          itemBuilder: (BuildContext context, Searchable item) {
                            return Text(
                              item.display(),
                              style: TextStyle(color: Colors.white),
                            );
                          },
                          onItemTap: (Searchable searchable) {
                            _admin = searchable as User;
                            _adminNameController.text = _admin.name;
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SearchDropdownField<User>(
                      data: _users != null
                          ? _users
                              .where((candidate) =>
                                  !_members.contains(candidate) &&
                                  candidate != _admin)
                              .toList()
                          : <User>[],
                      hint: localize('Add Group Member'),
                      itemBuilder: (BuildContext context, Searchable item) {
                        return Text(
                          item.display(),
                          style: TextStyle(color: Colors.white),
                        );
                      },
                      onItemTap: (Searchable searchable) {
                        setState(() {
                          _members.add(searchable as User);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                MaterialButton(
                  onPressed: () async {
                    if (_groupController.text.isEmpty) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(localize('Error')),
                          content: Text(
                            localize('Please enter group name'),
                          ),
                          actions: [
                            FlatButton(
                              child: Text(localize('Ok').toUpperCase()),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    if (_admin == null) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(localize('Error')),
                          content: Text(
                            localize('Please select group administrator'),
                          ),
                          actions: [
                            FlatButton(
                              child: Text(localize('Ok').toUpperCase()),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    final firestore = FirebaseFirestore.instance;
                    if (_members?.isEmpty ?? true) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(localize('Error')),
                          content: Text(
                            localize(
                                'Please add at least one member to this group'),
                          ),
                          actions: [
                            FlatButton(
                              child: Text(localize('Ok').toUpperCase()),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    _members.removeWhere((item) => item.id == _admin.id);
                    _members.add(_admin);
                    final Map<String, dynamic> payload = <String, dynamic>{
                      'admin': _admin.id,
                      'adminName': _admin.name,
                      'adminRole': _admin.role,
                      'class': true,
                      'members': _members
                          .map((User member) =>
                              firestore.doc("users/${member.id}"))
                          .toList(),
                      'name': _groupController.text,
                    };
                    if (!(await _checkIfUnique(payload))) {
                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(localize("Error")),
                                content: Text(localize(
                                    "There is already a group with this name. Please choose a different one.")),
                                actions: [
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(localize("Ok").toUpperCase()),
                                  ),
                                ],
                              ));
                      return;
                    }
                    if (widget.group != null) {
                      final docRef = firestore
                          .doc("$_schoolId/messages/${widget.group.id}");
                      await docRef.set(payload);
                    } else {
                      final messages =
                          firestore.collection("$_schoolId/messages");
                      await messages.add(payload);
                    }
                    await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(localize("Success")),
                              content: Text(localize(
                                  "Operation has been completed successfully")),
                              actions: [
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(localize("Ok").toUpperCase()),
                                ),
                              ],
                            ));
                    Navigator.of(context).pop();
                  },
                  color: Color(0xff007aff),
                  padding: const EdgeInsets.all(4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Center(
                      child: Text(
                        widget.group == null
                            ? localize('Create')
                            : localize('Save'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListView.builder(
                      itemBuilder: _buildListItem,
                      itemCount: _members.length,
                      shrinkWrap: true,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _members[index].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _members.removeAt(index);
            }),
            child: Text(
              localize("remove"),
              style: TextStyle(
                  color: Color.fromARGB(255, 20, 195, 239), fontSize: 12.0),
              textAlign: TextAlign.end,
            ),
          )
        ],
      ),
    );
  }
}
