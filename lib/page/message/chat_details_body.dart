import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
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
  final VoidCallback onLoading;
  final VoidCallback onAtUiClickListener;
  final RefreshController refreshController;
  final FirstEndCallback firstEndCallback;
  final int isHaveAtMeMsgIndex;
  final int conversationDtoType;
  final bool isHaveAtMeMsg;
  final String chatId;
  final bool isShowTop;

  ChatDetailsBody(
      {this.scrollController,
      this.chatDataList,
      this.chatId,
      this.conversationDtoType,
      this.isShowChatUserName,
      this.isHaveAtMeMsgIndex,
      this.isHaveAtMeMsg,
      this.firstEndCallback,
      this.vsync,
      this.chatName,
      this.onTap,
      this.isShowTop=false,
      this.isPersonalButler = false,
      this.voidMessageClickCallBack,
      this.onLoading,
      this.refreshController,
      this.onAtUiClickListener,
      this.voidItemLongClickCallBack});

  List<ChatDataModel> chatData = <ChatDataModel>[];


  bool isScroll=false;

  @override
  Widget build(BuildContext context) {
    chatData.clear();
    chatData.addAll(chatDataList);

    if (isPersonalButler) {
      ChatDataModel model = new ChatDataModel();
      model.content = "私人管家";
      chatData.insert(0, model);
    }

    // ChatDataModel chatDataModel = new ChatDataModel();
    // chatDataModel.content = "加载动画";
    // chatData.add(chatDataModel);
    return Stack(
      children: [
        Positioned(
          child: getChatBodyUi(),
        ),

        Positioned(
          child: isPersonalButler?ChatSystemBottomBar(voidMessageClickCallBack):Container(),
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

  Widget getChatBodyUi(){
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
          isScroll=true;
        } else if (notification is ScrollUpdateNotification) {
          // 滚动位置更新
          // print('滚动位置更新');
          // 当前位置
          // print("当前位置${metrics.pixels}");
          isScroll=true;
        } else if (notification is ScrollEndNotification) {
          // 滚动结束
          // print('滚动结束');
          isScroll=false;
        }
        return false;
      },
      child: getSmartRefresherUi(),
    );
  }


  Widget getSmartRefresherUi(){
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: footerWidget(),
      controller: refreshController,
      onLoading: onLoading,
      child: getListViewUi(),
    );
  }



  Widget getListViewUi(){
    return ListView.custom(
      cacheExtent: 0.0,
      physics: BouncingScrollPhysics(),
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      reverse: true,
      shrinkWrap: isShowTop,
      childrenDelegate: FirstEndItemChildrenDelegate((BuildContext context, int index) {
        return Container(
          margin: index == 0 ? const EdgeInsets.only(bottom: 16) :
          (index == chatData.length - 2) ? const EdgeInsets.only(top: 8) : null,
          child: judgeStartAnimation(chatData[index], index),
        );
      },
        firstEndCallback: (int firstIndex, int lastIndex){
          if(isScroll){
            firstEndCallback(firstIndex,lastIndex);
          }
        },
        childCount: chatData.length,
      ),
      dragStartBehavior: DragStartBehavior.down,
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
        ),
        child: Row(
          children: [
            SizedBox(width: 8,),
            getUserImage("", 28, 28),
            SizedBox(width: 11,),
            Text("有人@你",
              style: TextStyle(fontSize: 14, color: AppColor.mainBlue),),
          ],
        ),
      ),
    );
  }

  //底部或滑动
  Widget footerWidget() {
    double height=55.0;
    if(refreshController.footerStatus==LoadStatus.noMore){
      height=0.0;
    }
    return CustomFooter(
      height:height,
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("");
        } else if (mode == LoadStatus.loading) {
          body = Container(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth:3,
            ),
          );
        } else if (mode == LoadStatus.failed) {
          body = Text("");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("");
        } else {
          body = Text("");
        }
        return Container(
          height: height,
          child: Center(child: body),
        );
      },
    );
  }
  //判断有没有动画
  Widget judgeStartAnimation(ChatDataModel model, int position) {
    if (model.isHaveAnimation && !isShowTop) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 200),
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
        width: double.infinity, height: 48, color: AppColor.transparent,);
    }


    return SendMessageView(
        model,
        chatId,
        position,
        voidMessageClickCallBack,
        voidItemLongClickCallBack,
        chatName,
        isShowChatUserName,
        conversationDtoType);
  }

  bool judgePersonalButler(ChatDataModel model) {
    return model.content != null && model.content.isNotEmpty &&
        model.content == "私人管家";
  }
}

