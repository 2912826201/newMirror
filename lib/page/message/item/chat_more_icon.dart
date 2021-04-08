import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/icon.dart';

import 'commom_button.dart';

///底部按钮是图片还是发送按钮
//发送和图片按钮--消息界面底部

class ChatMoreIcon extends StatefulWidget {

  final bool isMore;
  final bool isComMomButton;
  final VoidCallback onTap;
  final GestureTapCallback moreTap;
  final TextEditingController textController;

  ChatMoreIcon({
    this.isMore = false,
    this.isComMomButton = false,
    this.onTap,
    this.moreTap,
    this.textController,
  });

  @override
  _ChatMoreIconState createState() => _ChatMoreIconState(isComMomButton);
}

class _ChatMoreIconState extends State<ChatMoreIcon> {

  bool isComMomButton;


  _ChatMoreIconState(this.isComMomButton);

  @override
  void initState() {
    super.initState();
    EventBus.getDefault().registerNoParameter(_resetMoreBtn, EVENTBUS_CHAT_PAGE,registerName: CHAT_BOTTOM_MORE_BTN);
  }

  _resetMoreBtn(){
    isComMomButton=StringUtil.strNoEmpty(widget.textController.text) && Application.platform == 0;
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE,registerName: CHAT_BOTTOM_MORE_BTN);
  }

  @override
  Widget build(BuildContext context) {
    if (isComMomButton) {
      return UnconstrainedBox(
        child: ComMomButton(
          text: '发送',
          height: 32,
          style: TextStyle(color: Colors.white),
          width: 50.0,
          margin: EdgeInsets.only(left:6,right: 16),
          radius: 4.0,
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap();
            }
          },
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: AppIconButton(
          onTap: (){
            if (widget.moreTap != null) {
              widget.moreTap();
            }
          },
          iconSize: 24,
          buttonWidth: 36,
          buttonHeight: 36,
          svgName: AppIcon.input_gallery,
        ),
      );
    }
  }
}

