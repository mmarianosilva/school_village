import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_village/util/user_helper.dart';
import 'package:school_village/util/date_formatter.dart' as dateFormatting;
import 'package:school_village/widgets/followup/followup.dart';

class HotLineList extends StatefulWidget {
  @override
  _HotLineListState createState() => new _HotLineListState();
}

class _HotLineListState extends State<HotLineList> {
  FirebaseUser _userId;
  String name = '';
  String _schoolId = '';
  bool isLoaded = false;
  DocumentReference _userRef;
  DocumentSnapshot _userSnapshot;
  List<String> _groups = new List<String>();

  getUserDetails() async {
    _userId = await UserHelper.getUser();
    var schoolId = (await UserHelper.getSelectedSchoolID()).split("/")[1];
    _userRef = Firestore.instance.document("users/${_userId.uid}");
    _userRef.get().then((user) {
      var keys = user.data["associatedSchools"][schoolId]["groups"].keys;
      List<String> groups = new List<String>();
      for (int i = 0; i < keys.length; i++) {
        if (user.data["associatedSchools"][schoolId]["groups"]
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
        title: Text('Anonymous Hotline Log',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
        elevation: 0.0,
        leading: BackButton(color: Colors.grey.shade800),
      ),
      body: !isLoaded
          ? Text("Loading...")
          : StreamBuilder(
              stream: Firestore.instance
                  .collection("schools/$_schoolId/hotline")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                final int messageCount = snapshot.data.documents.length;
                print(messageCount);
                return ListView.builder(
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
                                  'Anonymous Hotline Log',
                                  document.reference.path))),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(document['createdBy'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Spacer(),
                                Text(
                                    dateFormatting.dateFormatter.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            document['createdAt'])),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Spacer(),
                                Text(
                                    dateFormatting.timeFormatter.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            document['createdAt'])),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(document['body']),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: FutureBuilder(
                                      future: Firestore.instance
                                          .document(document['schoolId'] ?? '')
                                          .get(),
                                      initialData: document,
                                      builder: (BuildContext context,
                                              schoolData) =>
                                          Text(
                                              schoolData.hasData
                                                  ? schoolData.data['name'] ?? ''
                                                  : '',
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: FutureBuilder(
                                      future: Firestore.instance
                                          .collection(
                                              '${document.reference.path}/followup')
                                          .getDocuments(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot> data) {
                                        if (data.hasData) {
                                          return Text(
                                            'Follow-up ${data.data.documents.length}',
                                            style:
                                                TextStyle(color: Colors.blueAccent),
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
                                          )
                                        : Icon(Icons.photo_size_select_actual,
                                            color: Colors.blueAccent)
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                      ),
                    );
                  },
                );
              }),
    );
  }
}
