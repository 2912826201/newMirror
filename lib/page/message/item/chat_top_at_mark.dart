
import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/widget/icon.dart';

class ChatTopAtMark extends StatefulWidget {
  final Function() onAtUiClickListener;
  final bool isHaveAtMeMsg;


  ChatTopAtMark({
    Key key,
    this.onAtUiClickListener,
    this.isHaveAtMeMsg
  }):super(key: key);

  @override
  ChatTopAtMarkState createState() => ChatTopAtMarkState(isHaveAtMeMsg);
}

class ChatTopAtMarkState extends State<ChatTopAtMark> {
  bool isHaveAtMeMsg;



  setIsHaveAtMeMs(bool isHaveAtMeMsg){
    this.isHaveAtMeMsg=isHaveAtMeMsg;
    setState(() {

    });
  }

  ChatTopAtMarkState(this.isHaveAtMeMsg);

  @override
  Widget build(BuildContext context) {
    return isHaveAtMeMsg?getAtUi():Container();
  }

  //获取at的视图
  Widget getAtUi() {
    return GestureDetector(
      onTap: () {
        if (widget.onAtUiClickListener != null) {
          widget.onAtUiClickListener();
        }
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
              width: 8,
            ),
            Container(
              alignment: Alignment.center,
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColor.mainBlue,
                shape: BoxShape.circle,
              ),
              child: AppIcon.getAppIcon(AppIcon.at_16, 16),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              "有人@你",
              style: TextStyle(fontSize: 14, color: AppColor.mainBlue),
            ),
          ],
        ),
      ),
    );
  }
}
