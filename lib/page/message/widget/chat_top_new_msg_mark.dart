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
    return unreadCount > 0 ? getAtUi() : Container();
  }

  //获取at的视图
  Widget getAtUi() {
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
        width: 114,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 12,
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