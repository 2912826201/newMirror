import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
import 'package:mirror/widget/icon.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'item/chat_system_bottom_bar.dart';
import 'message_view/currency_msg.dart';

///消息展示body主体 简单进行包装一下
// ignore: must_be_immutable
class ChatDetailsBody extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatDataModel> chatDataList;
  final TickerProvider vsync;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final String chatName;
  final bool isShowChatUserName;
  final bool isPersonalButler;
  final GestureTapCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onAtUiClickListener;
  final RefreshController refreshController;
  final FirstEndCallback firstEndCallback;
  final int isHaveAtMeMsgIndex;
  final int conversationDtoType;
  final bool isHaveAtMeMsg;
  final String loadText;
  final String chatId;
  final LoadingStatus loadStatus;
  final bool isShowTop;
  final bool isShowHaveAnimation;

  ChatDetailsBody(
      {this.scrollController,
      this.chatDataList,
      this.chatId,
      this.conversationDtoType,
      this.loadText,
      this.loadStatus,
      this.isShowChatUserName,
      this.isHaveAtMeMsgIndex,
      this.isHaveAtMeMsg,
      this.firstEndCallback,
      this.vsync,
      this.chatName,
      this.onTap,
      this.isShowTop = false,
      this.isShowHaveAnimation = false,
      this.isPersonalButler = false,
      this.voidMessageClickCallBack,
      this.onRefresh,
      this.refreshController,
      this.onAtUiClickListener,
      this.voidItemLongClickCallBack});

  List<ChatDataModel> chatData = <ChatDataModel>[];

  bool isScroll = false;

  @override
  Widget build(BuildContext context) {
    chatData.clear();
    chatData.addAll(chatDataList);

    if (isPersonalButler) {
      ChatDataModel model = new ChatDataModel();
      model.content = "私人管家";
      chatData.insert(0, model);
    }

    if (loadStatus != LoadingStatus.STATUS_COMPLETED && !isShowTop) {
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.content = "加载动画";
      chatData.add(chatDataModel);
    }
    return Stack(
      children: [
        Positioned(
          child: getNotificationListener(),
        ),
        Positioned(
          child: isPersonalButler ? ChatSystemBottomBar(voidMessageClickCallBack) : Container(),
          left: 0,
          right: 0,
          bottom: 0,
        ),
        Positioned(
          child: Visibility(
            visible: isHaveAtMeMsg,
            child: Container(
              child: getAtUi(),
            ),
          ),
          top: 24,
          right: 0,
        ),
      ],
    );
  }

  Widget getNotificationListener() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 注册通知回调
        if (notification is ScrollStartNotification) {
          // FocusScope.of(context).requestFocus(new FocusNode());
          // if (onTap != null) {
          //   onTap();
          // }
          // 滚动开始
          // print('滚动开始');
          isScroll = true;
        } else if (notification is ScrollUpdateNotification) {
          // 滚动位置更新
          // print('滚动位置更新');
          // 当前位置
          // print("当前位置${metrics.pixels}");
          isScroll = true;
        } else if (notification is ScrollEndNotification) {
          // 滚动结束
          // print('滚动结束');
          isScroll = false;
        }
        return false;
      },
      child: getListView(),
    );
  }

  Widget getListView() {
    return ListView.custom(
      cacheExtent: 0.0,
      physics: BouncingScrollPhysics(),
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      reverse: true,
      shrinkWrap: isShowTop,
      childrenDelegate: FirstEndItemChildrenDelegate(
        (BuildContext context, int index) {
          if (index == chatData.length - 1 && loadStatus != LoadingStatus.STATUS_COMPLETED && !isShowTop) {
            return getLoadingUi();
          } else {
            return Container(
              margin: index == 0
                  ? const EdgeInsets.only(bottom: 16)
                  : (index == chatData.length - 2)
                      ? const EdgeInsets.only(top: 8)
                      : null,
              child: judgeStartAnimation(chatData[index], index),
            );
          }
        },
        firstEndCallback: (int firstIndex, int lastIndex) {
          if (isScroll) {
            firstEndCallback(firstIndex, lastIndex);
          }
        },
        childCount: chatData.length,
      ),
      dragStartBehavior: DragStartBehavior.down,
    );
  }

  Widget getLoadingUi() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: loadStatus == LoadingStatus.STATUS_LOADING ? true : false,
              child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
                  // loading 大小
                  strokeWidth: 2,
                ),
                width: 12.0,
                height: 12.0,
              ))
        ],
      ),
    );
  }

  //获取at的视图
  Widget getAtUi() {
    return GestureDetector(
      onTap: () {
        if (onAtUiClickListener != null) {
          onAtUiClickListener();
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

  //判断有没有动画
  Widget judgeStartAnimation(ChatDataModel model, int position) {
    if (model.isHaveAnimation && isShowHaveAnimation) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 100),
        vsync: vsync,
      );
      Future.delayed(Duration(milliseconds: 100), () {
        animationController.forward();
      });
      model.isHaveAnimation = false;
      return SizeTransition(
          sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
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
        width: double.infinity,
        height: 48,
        color: AppColor.transparent,
      );
    }

    return SendMessageView(model, chatId, position, voidMessageClickCallBack, voidItemLongClickCallBack, chatName,
        isShowChatUserName, conversationDtoType);
  }

  bool judgePersonalButler(ChatDataModel model) {
    return model.content != null && model.content.isNotEmpty && model.content == "私人管家";
  }
}
