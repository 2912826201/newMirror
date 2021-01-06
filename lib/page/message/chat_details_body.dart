import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/send_message_view.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  final VoidCallback onRefresh;
  final VoidCallback onAtUiClickListener;
  final RefreshController refreshController;
  final FirstEndCallback firstEndCallback;
  final int isHaveAtMeMsgIndex;
  final bool isHaveAtMeMsg;

  ChatDetailsBody(
      {this.scrollController,
      this.chatDataList,
      this.isHaveAtMeMsgIndex,
      this.isHaveAtMeMsg,
      this.firstEndCallback,
      this.vsync,
      this.chatUserName,
      this.onTap,
      this.isPersonalButler = false,
      this.voidMessageClickCallBack,
      this.onRefresh,
      this.refreshController,
      this.onAtUiClickListener,
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
            child: SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.loading) {
                    body = Container(
                      height: 50,
                      child: UnconstrainedBox(
                        child: Transform.scale(
                          scale: 0.6,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else if (mode == LoadStatus.noMore) {
                    body = Text("没有更多了");
                  } else if (mode == LoadStatus.failed) {
                    body = Text("加载错误,请重试");
                  } else {
                    body = Text("");
                  }
                  return Container(
                    child: Center(
                      child: body,
                    ),
                  );
                },
              ),
              controller: refreshController,
              onLoading: onRefresh,
              child: ListView.custom(
                cacheExtent: 0.0,
                physics: BouncingScrollPhysics(),
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16),
                reverse: true,
                childrenDelegate: FirstEndItemChildrenDelegate((
                    BuildContext context, int index) {
                  return judgeStartAnimation(chatData[index], index);
                },
                  firstEndCallback: firstEndCallback,
                  childCount: chatData.length,

                ),
                dragStartBehavior: DragStartBehavior.down,
              ),
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

