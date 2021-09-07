import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/followup/followup.dart';
import 'package:school_village/util/localizations/localization.dart';

class HotLineList extends StatefulWidget {
  @override
  _HotLineListState createState() => new _HotLineListState();
}

class _HotLineListState extends State<HotLineList> {
  User _userId;
  String name = '';
  String _schoolId = '';
  bool isLoaded = false;
  DocumentReference _userRef;
  DocumentSnapshot _userSnapshot;
  List<String> _groups = new List<String>();

  getUserDetails() async {
    _userId = await UserHelper.getUser();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = FirebaseFirestore.instance.doc("users/${_userId.uid}");
    _userRef.get().then((user) {
      var keys = user["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = new List<String>();
      for (int i = 0; i < keys.length; i++) {
        if (user["associatedSchools"][schoolId]["groups"]
                [keys.elementAt(i)] ==
            true) {
          groups.add(keys.elementAt(i));
        }
      }
      setState(() {
        _schoolId = schoolId;
        _userSnapshot = user;
        _groups = groups;
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    print(_groups);
    print("/$_schoolId/hotline");
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(localize('Anonymous Hotline Log'),
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: !isLoaded
          ? Text(localize("Loading..."))
          : Stack(
              children: <Widget>[
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("schools/$_schoolId/hotline")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (!snapshot.hasData) return Text(localize('Loading...'));
                      final int messageCount = snapshot.data.documents.length;
                      print(messageCount);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ListView.builder(
                          itemCount: messageCount,
                          itemBuilder: (_, int index) {
                            final DocumentSnapshot document =
                                snapshot.data.documents[index];
                            debugPrint(document['body']);

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => Followup(
                                          localize('Anonymous Hotline Log'),
                                          document.reference.path))),
                              child: Card(
                                margin: EdgeInsets.all(4.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text('Anonymous',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Spacer(),
                                          Text(
                                              dateFormatting.dateFormatter.format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          document['createdAt'])),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Spacer(),
                                          Text(
                                              dateFormatting.timeFormatter.format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          document['createdAt'])),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(document['body']),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              child: FutureBuilder<DocumentSnapshot>(
                                                future: FirebaseFirestore.instance
                                                    .doc(
                                                        document.data()['schoolId'] ??
                                                            '')
                                                    .get(),
                                                initialData: document,
                                                builder: (BuildContext context,
                                                        schoolData) =>
                                                    Text(
                                                        schoolData.hasData
                                                            ? schoolData.data[
                                                                    'name'] ??
                                                                ''
                                                            : '',
                                                        style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: FutureBuilder(
                                                future: FirebaseFirestore.instance
                                                    .collection(
                                                        '${document.reference.path}/followup')
                                                    .get(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        data) {
                                                  if (data.hasData) {
                                                    return Text(
                                                      'Follow-up ${data.data.docs.length}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.blueAccent),
                                                    );
                                                  }
                                                  return Text('');
                                                },
                                              ),
                                            ),
                                          ),
                                          document['media'] != null
                                              ? document['isVideo'] ?? false
                                                  ? Icon(
                                                      Icons.videocam,
                                                      color: Colors.blueAccent,
                                                      size: 24.0,
                                                    )
                                                  : Icon(
                                                      Icons
                                                          .photo_size_select_actual,
                                                      color: Colors.blueAccent,
                                                      size: 24.0,
                                                    )
                                              : SizedBox(
                                                  width: 24.0,
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    child: Container(
                      height: 96.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(0, 255, 255, 255),
                            Color.fromARGB(255, 255, 255, 255)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
