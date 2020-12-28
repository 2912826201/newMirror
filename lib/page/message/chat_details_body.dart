import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';

class ChatDetailsBody extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatDataModel> chatData;
  final TickerProvider vsync;

  ChatDetailsBody({this.scrollController, this.chatData, this.vsync});

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        reverse: true,
        itemBuilder: (context, int index) {
          return judgeStartAnimation(chatData[index]);
        },
        itemCount: chatData.length,
        dragStartBehavior: DragStartBehavior.down,
      ),
    );
  }

  //判断有没有动画
  Widget judgeStartAnimation(ChatDataModel model) {
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
            child: getBodyItem(model),
          ));
    } else {
      return getBodyItem(model);
    }
  }

  //获取每一个item
  Widget getBodyItem(ChatDataModel model) {
    return SendMessageView(model);
  }
}

