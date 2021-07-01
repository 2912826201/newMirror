import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/widget/icon.dart';

class ChatTopNewMsgMark extends StatefulWidget {
  final Function() onNewMsgClickListener;
  final int newMsgCount;

  ChatTopNewMsgMark({Key key, this.onNewMsgClickListener, this.newMsgCount = 0}) : super(key: key);

  @override
  ChatTopNewMsgMarkState createState() => ChatTopNewMsgMarkState(newMsgCount);
}

class ChatTopNewMsgMarkState extends State<ChatTopNewMsgMark> {
  int newMsgCount;

  ChatTopNewMsgMarkState(this.newMsgCount);

  @override
  Widget build(BuildContext context) {
    return newMsgCount > 0 ? getAtUi() : Container();
  }

  //获取at的视图
  Widget getAtUi() {
    return GestureDetector(
      onTap: () {
        newMsgCount = 0;
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
              "$newMsgCount条新消息",
              style: TextStyle(fontSize: 14, color: AppColor.mainBlue),
            ),
          ],
        ),
      ),
    );
  }
}
