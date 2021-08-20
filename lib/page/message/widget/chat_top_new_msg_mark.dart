import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';

class ChatTopNewMsgMark extends StatefulWidget {
  final Function() onNewMsgClickListener;
  final int newMsgCount;
  final Function(Function(int newMsgCount)) setNewMsgCount;

  ChatTopNewMsgMark({Key key, this.onNewMsgClickListener, this.newMsgCount = 0, this.setNewMsgCount}) : super(key: key);

  @override
  ChatTopNewMsgMarkState createState() => ChatTopNewMsgMarkState(newMsgCount, setNewMsgCount);
}

class ChatTopNewMsgMarkState extends State<ChatTopNewMsgMark> {
  int unreadCount;
  final Function(Function(int newMsgCount)) setNewMsgCount;

  ChatTopNewMsgMarkState(this.unreadCount, this.setNewMsgCount) {
    if (setNewMsgCount != null) {
      setNewMsgCount(_setNewMsgCount);
    }
  }

  _setNewMsgCount(int unreadCount) {
    this.unreadCount = unreadCount;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return unreadCount > 0 ? getNewMsgUi() : Container();
  }

  //获取新消息条数的ui
  Widget getNewMsgUi() {
    return GestureDetector(
      onTap: () {
        unreadCount = 0;
        if (widget.onNewMsgClickListener != null) {
          widget.onNewMsgClickListener();
        }
        setState(() {});
      },
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(top: 3),
              child: Image.asset("assets/png/icon_up.png", width: 16, height: 16),
            ),
            Text(
              "$unreadCount条新消息",
              style: TextStyle(fontSize: 14, color: AppColor.mainBlue),
            ),
          ],
        ),
      ),
    );
  }
}
