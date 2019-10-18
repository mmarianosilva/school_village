import 'package:flutter/material.dart';
import 'package:school_village/util/date_formatter.dart';
import 'package:school_village/widgets/talk_around/talk_around_channel.dart';

class TalkAroundRoomItem extends StatelessWidget {
  final TalkAroundChannel item;
  final String username;
  final VoidCallback onTap;

  const TalkAroundRoomItem({Key key, this.item, this.username, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: this.onTap,
        child: Row(
          children: <Widget>[
            Flexible(
                child: Builder(builder: (context) {
                  if (!item.direct) {
                    return Text(
                        "#",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        textAlign: TextAlign.center
                    );
                  }
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
                    item.groupConversationName(username),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white, fontSize: 16.0)
                ),
                flex: 8,
                fit: FlexFit.tight
            ),
            Flexible(
              child: Builder(builder: (context) {
                if (!item.direct) {
                  return SizedBox();
                }
                if (item.timestamp != null) {
                  return Text(
                      messageDateFormatter.format(item.timestamp.toDate()),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 12.0),
                      textAlign: TextAlign.end);
                }
                else if (item.members.length > 2) {
                  return Text(
                      "Group",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0),
                      textAlign: TextAlign.end);
                } else {
                  return Text(
                      item.members[0].name != username ? item.members[0].group : item.members[1].group,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: Color.fromARGB(255, 20, 195, 239), fontSize: 16.0),
                      textAlign: TextAlign.end);
                }
              }),
              flex: 3,
              fit: FlexFit.tight,
            )
          ],
        ),
      ),
    );
  }
}
