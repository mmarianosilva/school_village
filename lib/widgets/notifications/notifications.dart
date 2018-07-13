import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../schoollist/school_list.dart';
import '../../util/user_helper.dart';
import '../notification/notification.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/main_model.dart';
import 'notifications_list.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => new _NotificationsState();
}

class _NotificationsState extends State<Notifications> with TickerProviderStateMixin{
  String _schoolId = '';
  bool isLoaded = false;

  getTitle(alert) {
    switch(alert) {
      case 'medical' : return 'Medical';
      case 'intruder' : return 'Intruders';
      case 'other': return 'Other';
      case 'fire': return 'Fire';
      case 'fight': return 'Fights';
      case 'armed': return 'Armed Assailant';
      default : return alert;
    }
  }

  getUserDetails() async {
    String schoolId = await UserHelper.getSelectedSchoolID();
      setState(() {
        _schoolId = schoolId;
        isLoaded = true;
      });
  }

  _getTabs (alerts) {
    List<Widget> tabs = [];
    alerts.forEach((alert) {
      tabs.add(new Tab(text: getTitle(alert)));
    });
    return tabs;
  }

  _getTabWidgets (alerts) {
    List<Widget> tabs = [];
    alerts.forEach((alert) {
      tabs.add(new NotificationsList(schoolId: _schoolId.split("/")[1], alertType: alert));
    });
    return tabs;
  }


  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      getUserDetails();
    }
    return new ScopedModelDescendant<MainModel>(
        builder: (context, child, model) {
          if(_schoolId.split("/").length < 2) {
            return Text('Loading');
          }
          return new FutureBuilder(future: model.getAlertGroups(_schoolId.split("/")[1]),
              builder: (context, alertGroups) {
                if(alertGroups.connectionState != ConnectionState.done || alertGroups.data.length == 0 ){
                  return SizedBox();
                }
                TabController tabController = new TabController(length: alertGroups.data.length , vsync: this);
                return new DefaultTabController(
                  length: alertGroups.data.length,
                  child: Scaffold(
                    backgroundColor: Colors.grey.shade100,
                    appBar: AppBar(
                      bottom: TabBar(
                        isScrollable: true,
                        labelColor: Colors.black,
                        tabs: _getTabs(alertGroups.data),
                        controller: tabController,
                      ),
                      title: new Text('Notifications', textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.black)),
                      backgroundColor: Colors.grey.shade200,
                      elevation: 0.0,
                      leading: new BackButton(color: Colors.grey.shade800),
                    ),
                    body: TabBarView(
                      children: _getTabWidgets(alertGroups.data),
                      controller: tabController,
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
