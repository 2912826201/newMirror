import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';

import 'message_view/currency_msg.dart';

class ChatDetailsBody extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatDataModel> chatData;
  final TickerProvider vsync;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  ChatDetailsBody(
      {this.scrollController,
      this.chatData,
      this.vsync,
      this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack});

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        reverse: true,
        itemBuilder: (context, int index) {
          return judgeStartAnimation(chatData[index], index);
        },
        itemCount: chatData.length,
        dragStartBehavior: DragStartBehavior.down,
      ),
    );
  }

  //判断有没有动画
  Widget judgeStartAnimation(ChatDataModel model, int position) {
    if (model.isHaveAnimation) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 200),
        vsync: vsync,
      );
      Future.delayed(Duration(milliseconds: 100), () {
        animationController.forward();
      });
      model.isHaveAnimation = false;
      return SizeTransition(
          sizeFactor: CurvedAnimation(
              parent: animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
            child: getBodyItem(model, position),
          ));
    } else {
      return getBodyItem(model, position);
    }
  }

  //获取每一个item
  Widget getBodyItem(ChatDataModel model, int position) {
    return SendMessageView(
        model, position, voidMessageClickCallBack, voidItemLongClickCallBack);
  }
}

