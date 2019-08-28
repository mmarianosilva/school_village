import 'package:flutter/material.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';

class TalkAroundRoomItem extends StatelessWidget {
  final TalkAroundChannel item;
  final String username;

  const TalkAroundRoomItem({Key key, this.item, this.username}) : super(key: key);

  String _buildDirectMessageName(TalkAroundChannel item) {
    List<String> names = item.members.map((item) => item.name).toList();
    names.removeWhere((name) => name == username);
    names.sort((name1, name2) => name1.compareTo(name2));
    String output = "";
    int i = 0;
    while (i < names.length - 1) {
      output += "${names[i]}, ";
      i++;
    }
    output += names[names.length - 1];
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: Builder(builder: (context) {
                if (item.members.length > 2) {
                  return Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(const Radius.circular(4.0))
                      ),
                      child: Text(
                          "${item.members.length - 1}",
                          style: TextStyle(color: Color.fromARGB(255, 10, 104, 127), fontSize: 16.0),
                          textAlign: TextAlign.center),
                    ),
                  );
                } else {
                  return Text(
                      "•",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                      textAlign: TextAlign.center
                  );
                }
              }),
              flex: 1,
              fit: FlexFit.tight
          ),
          Flexible(
              child: Text(
                  _buildDirectMessageName(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white, fontSize: 16.0)
              ),
              flex: 12,
              fit: FlexFit.tight
          ),
          Flexible(
            child: Builder(builder: (context) {
              if (item.members.length > 2) {
                return Text(
                    "Group",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0));
              } else {
                return Text(
                    item.members[0].name != username ? item.members[0].group : item.members[1].group,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0));
              }
            }),
            flex: 3,
            fit: FlexFit.tight,
          )
        ],
      ),
    );
  }
}
