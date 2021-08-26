import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/widget/icon.dart';

class ChatTopAtMark extends StatefulWidget {
  final Function() onAtUiClickListener;
  final bool isHaveAtMeMsg;
  final Function(Function(bool isHaveAtMeMsg)) setHaveAtMeMsg;

  ChatTopAtMark({Key key, this.onAtUiClickListener, this.isHaveAtMeMsg,this.setHaveAtMeMsg}) : super(key: key);

  @override
  ChatTopAtMarkState createState() => ChatTopAtMarkState(isHaveAtMeMsg,setHaveAtMeMsg);
}

class ChatTopAtMarkState extends State<ChatTopAtMark> {
  bool isHaveAtMeMsg;
  Function(Function(bool isHaveAtMeMsg)) setHaveAtMeMsg;


  setIsHaveAtMeMs(bool isHaveAtMeMsg) {
    this.isHaveAtMeMsg = isHaveAtMeMsg;
    setState(() {});
  }


  ChatTopAtMarkState(this.isHaveAtMeMsg,this.setHaveAtMeMsg){
    setHaveAtMeMsg(setIsHaveAtMeMs);
  }

  @override
  Widget build(BuildContext context) {
    return isHaveAtMeMsg ? getAtUi() : Container();
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
          color: AppColor.layoutBgGrey,
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
              style: AppStyle.blueRegular14,
            ),
          ],
        ),
      ),
    );
  }
}
