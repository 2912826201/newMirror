import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';

import 'item/chat_system_bottom_bar.dart';
import 'message_view/currency_msg.dart';

// ignore: must_be_immutable
class ChatDetailsBody extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatDataModel> chatDataList;
  final TickerProvider vsync;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final String chatUserName;
  final bool isPersonalButler;
  final GestureTapCallback onTap;

  ChatDetailsBody(
      {this.scrollController,
      this.chatDataList,
      this.vsync,
      this.chatUserName,
      this.onTap,
      this.isPersonalButler = false,
      this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack});

  List<ChatDataModel> chatData = <ChatDataModel>[];

  @override
  Widget build(BuildContext context) {
    chatData.clear();
    chatData.addAll(chatDataList);

    if (isPersonalButler) {
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.content = "私人管家";
      chatData.insert(0, chatDataModel);
    }

    return Stack(
      children: [
        Positioned(

          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // 注册通知回调
              if (notification is ScrollStartNotification) {
                // FocusScope.of(context).requestFocus(new FocusNode());
                // if (onTap != null) {
                //   onTap();
                // }
                // 滚动开始
                // print('滚动开始');
              } else if (notification is ScrollUpdateNotification) {
                // 滚动位置更新
                // print('滚动位置更新');
                // 当前位置
                // print("当前位置${metrics.pixels}");
              } else if (notification is ScrollEndNotification) {
                // 滚动结束
                // print('滚动结束');
              }
              return false;
            },
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
          ),
        ),
        Positioned(
          child: Offstage(
            offstage: !isPersonalButler,
            child: ChatSystemBottomBar(voidMessageClickCallBack),
          ),
          left: 0,
          right: 0,
          bottom: 0,
        )
      ],
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
    if (judgePersonalButler(model)) {
      return Container(
        width: double.infinity, height: 48, color: AppColor.transparent,);
    }


    return SendMessageView(
        model, position, voidMessageClickCallBack, voidItemLongClickCallBack,
        chatUserName);
  }

  bool judgePersonalButler(ChatDataModel model) {
    return model.content != null && model.content.isNotEmpty &&
        model.content == "私人管家";
  }
}

