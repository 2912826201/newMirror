import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/item/chat_top_at_mark.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/page/message/send_message_view.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';

import 'item/chat_system_bottom_bar.dart';
import 'message_view/currency_msg.dart';

///消息展示body主体 简单进行包装一下
class ChatDetailsBody extends StatefulWidget {
  final ScrollController scrollController;
  final List<ChatDataModel> chatDataList;
  final TickerProvider vsync;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final String chatName;
  final bool isShowChatUserName;
  final bool isPersonalButler;
  final GestureTapCallback onTap;
  final VoidCallback onAtUiClickListener;
  final FirstEndCallback firstEndCallback;
  final int conversationDtoType;
  final bool isHaveAtMeMsg;
  final String chatId;
  final LoadingStatus loadStatus;
  final Key chatTopAtMarkChildKey;

  ChatDetailsBody(
      {Key key,
      this.scrollController,
      this.chatDataList,
      this.chatId,
      this.conversationDtoType,
      this.loadStatus,
      this.isShowChatUserName,
      this.isHaveAtMeMsg,
      this.firstEndCallback,
      this.vsync,
      this.chatName,
      this.onTap,
      this.isPersonalButler = false,
      this.voidMessageClickCallBack,
      this.onAtUiClickListener,
      this.chatTopAtMarkChildKey,
      this.voidItemLongClickCallBack})
      : super(key: key);

  @override
  ChatDetailsBodyState createState() => ChatDetailsBodyState(loadStatus);
}

class ChatDetailsBodyState extends State<ChatDetailsBody> {
  LoadingStatus loadStatus;
  bool isShowTop;
  bool isShowHaveAnimation;

  ChatDetailsBodyState(this.loadStatus);

  bool isScroll = false;
  bool isHaveLoadAnimation = true;

  Widget loadStatusWidget;

  int atItemMessagePosition = -1;

  AnimationController _animationController;
  Animation _animation;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    if (_animationController != null) {
      _animationController.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
    _initWidget();
    EventBus.getDefault().registerNoParameter(resetChatMessageCount, EVENTBUS_CHAT_PAGE, registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatDataList.length > 1) {
      if (!(widget.chatDataList[0].isTemporary || widget.chatDataList[1].isTemporary)) {
        if (widget.chatDataList[0].msg.messageId == widget.chatDataList[1].msg.messageId) {
          widget.chatDataList.removeAt(0);
        }
      }
    }
    return Stack(
      children: [
        Positioned(
          child: getNotificationListener(),
        ),
        Positioned(
          child: widget.isPersonalButler ? ChatSystemBottomBar(widget.voidMessageClickCallBack) : Container(),
          left: 0,
          right: 0,
          bottom: 0,
        ),
        Positioned(
          child: ChatTopAtMark(
            key: widget.chatTopAtMarkChildKey,
            onAtUiClickListener: widget.onAtUiClickListener,
            isHaveAtMeMsg: widget.isHaveAtMeMsg,
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
          if(widget.onTap!=null){
            widget.onTap();
          }
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
    int childCount = getChildCount();
    return ListView.custom(
      physics: BouncingScrollPhysics(),
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      reverse: true,
      shrinkWrap: isShowTop,
      childrenDelegate: FirstEndItemChildrenDelegate(
        (BuildContext context, int index) {
          if (index == childCount - 1 && isHaveLoadAnimation) {
            return loadStatusWidget;
          } else if (index == 0 && widget.isPersonalButler) {
            return Container(
              width: double.infinity,
              height: 48,
              color: AppColor.transparent,
            );
          } else {
            return Container(
              margin: index == 0
                  ? const EdgeInsets.only(bottom: 16)
                  : (index == childCount - 1)
                      ? const EdgeInsets.only(top: 8)
                      : null,
              child: judgeStartAnimation(getChatDataListIndex(index)),
            );
          }
        },
        firstEndCallback: (int firstIndex, int lastIndex) {
          if (isScroll) {
            widget.firstEndCallback(firstIndex, lastIndex);
          }
        },
        childCount: childCount,
      ),
      dragStartBehavior: DragStartBehavior.down,
    );
  }

  int getChatDataListIndex(int childCountIndex) {
    if (widget.isPersonalButler) {
      return childCountIndex - 1;
    } else {
      return childCountIndex;
    }
  }

  int getChildCount() {
    return widget.chatDataList.length + (widget.isPersonalButler ? 1 : 0) + (isHaveLoadAnimation ? 1 : 0);
  }

  Widget getLoadingUi() {
    return Container(
      height: loadStatus != LoadingStatus.STATUS_COMPLETED ? 40.0 : 0.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: loadStatus != LoadingStatus.STATUS_COMPLETED ? true : false,
            child: SizedBox(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
                // loading 大小
                strokeWidth: 2,
              ),
              width: 12.0,
              height: 12.0,
            ),
          )
        ],
      ),
    );
  }

  //判断有没有动画
  Widget judgeStartAnimation(int position) {
    ChatDataModel model = widget.chatDataList[position];
    if (model.isHaveAnimation && isShowHaveAnimation) {
      AnimationController animationController = AnimationController(
        duration: new Duration(milliseconds: 100),
        vsync: widget.vsync,
      );
      Future.delayed(Duration(milliseconds: 100), () {
        animationController.forward();
      });
      model.isHaveAnimation = false;
      return SizeTransition(
        sizeFactor: CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          child: getBodyAtItem(model, position),
        ),
      );
    } else {
      return getBodyAtItem(model, position);
    }
  }

  //获取每一个item
  Widget getBodyAtItem(ChatDataModel model, int position) {
    if (atItemMessagePosition == position) {
      _animationController = AnimationController(duration: Duration(seconds: 2), vsync: widget.vsync);
      _animation = DecorationTween(
          begin: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColor.transparent,
                AppColor.textHint,
                AppColor.transparent,
              ],
            ),
          ),
          end: BoxDecoration(
            color: AppColor.transparent,
          )).animate(_animationController);
      Future.delayed(Duration(milliseconds: 500), () {
        _animationController.forward();
      });
      atItemMessagePosition = -1;
      return DecoratedBoxTransition(decoration: _animation, child: getBodyItem(model, position));
    } else {
      return getBodyItem(model, position);
    }
  }

  Widget getBodyItem(ChatDataModel model, int position) {
    return SendMessageView(model, widget.chatId, position, widget.voidMessageClickCallBack,
        widget.voidItemLongClickCallBack, widget.chatName, widget.isShowChatUserName, widget.conversationDtoType);
  }

  _initData() {
    isShowHaveAnimation = MessageItemHeightUtil.init()
        .judgeMessageItemHeightIsThenScreenHeight(widget.chatDataList, widget.isShowChatUserName);
    isShowTop = !isShowHaveAnimation;
    if (isShowTop) {
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }else{
      loadStatus = LoadingStatus.STATUS_IDEL;
    }
    if (loadStatus != LoadingStatus.STATUS_COMPLETED) {
      isHaveLoadAnimation = true;
    }else{
      isHaveLoadAnimation = false;
    }
  }

  _initWidget() {
    loadStatusWidget = getLoadingUi();
  }

  resetChatMessageCount() {
    _initData();
    setState(() {});
  }

  setLoadStatus(LoadingStatus loadStatus) {
    this.loadStatus = loadStatus;
    if (loadStatus != LoadingStatus.STATUS_COMPLETED && !isShowTop) {
      if (!isHaveLoadAnimation) {
        isHaveLoadAnimation = true;
        setState(() {});
        return;
      }
    }
    _resetLoadStatus();
  }

  setAtItemMessagePosition(int atItemMessagePosition) {
    this.atItemMessagePosition = atItemMessagePosition;
    if (atItemMessagePosition > 0) {
      setState(() {});
    }
  }

  _resetLoadStatus() {
    Element e = findChild(context as Element, loadStatusWidget);
    if (e != null) {
      loadStatusWidget = getLoadingUi();
      e.owner.lockState(() {
        e.update(loadStatusWidget);
      });
    }
  }

  Element findChild(Element e, Widget w) {
    Element child;
    void visit(Element element) {
      if (w == element.widget)
        child = element;
      else
        element.visitChildren(visit);
    }

    visit(e);
    return child;
  }
}
