import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_village/components/base_appbar.dart';
import 'package:school_village/widgets/followup/followup_comment_box.dart';
import 'package:school_village/widgets/followup/followup_header_item.dart';
import 'package:school_village/widgets/followup/followup_list_item.dart';

class Followup extends StatefulWidget {
  final String _title;
  final String _firestorePath;

  Followup(this._title, this._firestorePath);

  @override
  _FollowupState createState() => _FollowupState();
}

class _FollowupState extends State<Followup> {
  Map<String, dynamic> _originalData;

  @override
  void initState() {
    super.initState();
    Firestore.instance.document(widget._firestorePath).get().then((snapshot) {
      setState(() {
        _originalData = snapshot.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white70,
        title: Column(
          children: <Widget>[
            Text(widget._title, style: TextStyle(color: Colors.black),),
            Text('Follow-up Reporting', style: TextStyle(color: Colors.blueAccent),),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.grey[100],
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _originalData != null
                  ? FollowupHeaderItem(_originalData)
                  : CircularProgressIndicator(),
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                .collection('${widget._firestorePath}/followup')
                .orderBy('timestamp')
                .snapshots(),
                initialData: null,
                builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState != ConnectionState.none) {
                if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Text('No followup reports found'),
                  );
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0,),
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot item = snapshot.data.documents[index];
                      return FollowupListItem(item.data);
                    }),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return CircularProgressIndicator();
                },
              ),
              FollowupCommentBox(this.widget._firestorePath),
            ],
          ),
        ),
      ),
    );
  }
}
