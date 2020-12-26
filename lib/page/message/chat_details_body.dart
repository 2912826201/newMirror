import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';

class ChatDetailsBody extends StatelessWidget {
  final ScrollController sC;
  final List<ChatDataModel> chatData;
  final TickerProvider vsync;

  ChatDetailsBody({this.sC, this.chatData, this.vsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.builder(
              controller: sC,
              padding: EdgeInsets.symmetric(horizontal: 16),
              reverse: true,
              itemBuilder: (context, int index) {
                return judgeStartAnimation(chatData[index]);
              },
              itemCount: chatData.length,
              dragStartBehavior: DragStartBehavior.down,
            ),
          )),
        ],
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
            child: SendMessageView(model),
          ));
    } else {
      return SendMessageView(model);
    }
  }
}

