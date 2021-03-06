import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/loading.dart';
import 'package:provider/provider.dart';

///私人聊天-更多界面--管家-系统消息
class PrivateMorePage extends StatefulWidget {
  ///对话用户id
  final String chatUserId;
  final String name;
  final Function(int type, String name) listener;
  final ConversationDto dto;

  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  PrivateMorePage({this.chatUserId, this.chatType, this.dto, this.name, this.listener});

  @override
  createState() => PrivateMorePageState();
}

class PrivateMorePageState extends State<PrivateMorePage> {
  bool disturbTheNews = false;
  int disturbTheNewsIndex = -1;
  bool topChat = false;
  int topChatIndex = -1;
  bool isBlackList = false;

  @override
  void initState() {
    super.initState();
    // initData();
    getBlackListStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: widget.name,
      ),
      body: Container(
        color: AppColor.mainBlack,
        child: Column(
          children: [
            Offstage(
              offstage: !(widget.chatType == PRIVATE_TYPE || widget.chatType == MANAGER_TYPE),
              child: item(1, disturbTheNews, "消息免打扰"),
            ),
            Offstage(
              offstage: !(widget.chatType == PRIVATE_TYPE || widget.chatType == MANAGER_TYPE),
              child: getContainer(),
            ),
            item(2, topChat, "置顶聊天"),
            Offstage(
              offstage: !(widget.chatType == PRIVATE_TYPE || widget.chatType == MANAGER_TYPE),
              child: getContainer(),
            ),
            Offstage(
              offstage: widget.chatType != PRIVATE_TYPE,
              child: item(3, topChat, isBlackList ? "解除拉黑" : "拉黑", isCupertinoSwitchShow: false),
            ),
          ],
        ),
      ),
    );
  }

  //点击事件的box
  Widget item(int type, bool isOpen, String title, {bool isCupertinoSwitchShow = true}) {
    return Material(
      color: AppColor.transparent,
      child: new InkWell(
        child: _switchRow(type, isOpen, title, isCupertinoSwitchShow),
        splashColor: AppColor.textWhite40,
        onTap: () {
          if (mounted) {
            setState(() {
              if (type == 1) {
                onClickItem(disturbTheNews, title);
              } else if (type == 2) {
                onClickItem(topChat, title);
              } else {
                onClickItem(isOpen, title);
              }
            });
          }
        },
      ),
    );
  }

  //选项
  Widget _switchRow(int type, bool isOpen, String title, isCupertinoSwitchShow) {
    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: AppStyle.whiteRegular16,
            ),
            Expanded(child: SizedBox()),
            Offstage(
              offstage: !isCupertinoSwitchShow,
              child: Transform.scale(
                scale: 0.75,
                child: CupertinoSwitch(
                  activeColor: AppColor.mainYellow,
                  trackColor: AppColor.textWhite40,
                  value: isOpen,
                  onChanged: (bool value) {
                    if (type == 1) {
                      onClickItem(disturbTheNews, title);
                    } else if (type == 2) {
                      onClickItem(topChat, title);
                    } else {
                      onClickItem(isOpen, title);
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //间隔线
  Widget getContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 0.3,
      color: AppColor.dividerWhite8,
    );
  }

  //设置消息是否置顶
  void setTopChatApi() async {
    Loading.showLoading(context);
    topChat = !topChat;
    Map<String, dynamic> map =
        await (topChat ? stickChat : cancelTopChat)(targetId: int.parse(widget.chatUserId), type: 0);
    print(map.toString());
    if (map != null && map["state"] != null && map["state"]) {
      TopChatModel topChatModel = new TopChatModel(type: 0, chatId: int.parse(widget.chatUserId));
      if (topChat) {
        if (topChatIndex < 0) {
          MessageManager.topChatModelList.add(topChatModel);
          topChatIndex = MessageManager.topChatModelList.length - 1;
        }
        if (null != widget.dto) {
          widget.dto.isTop = 1;
          context.read<ConversationNotifier>().insertTop(widget.dto);
        }
      } else {
        if (topChatIndex >= 0) {
          MessageManager.topChatModelList.removeAt(topChatIndex);
        }
        topChatIndex = -1;
        if (null != widget.dto) {
          widget.dto.isTop = 0;
          context.read<ConversationNotifier>().insertCommon(widget.dto);
        }
      }
    } else {
      topChat = !topChat;
    }
    Loading.hideLoading(context);
    if (mounted) {
      setState(() {});
    }
  }

  //设置消息免打扰
  void setConversationNotificationStatus() async {
    Loading.showLoading(context);
    disturbTheNews = !disturbTheNews;
    //判断有没有免打扰
    Map<String, dynamic> map = await (disturbTheNews ? addNoPrompt : removeNoPrompt)(
        targetId: int.parse(widget.chatUserId), type: widget.chatType);
    if (map != null && map["state"] != null && map["state"]) {
      NoPromptUidModel model = NoPromptUidModel(type: widget.chatType, targetId: int.parse(widget.chatUserId));
      if (disturbTheNews) {
        MessageManager.queryNoPromptUidList.add(model);
        disturbTheNewsIndex = MessageManager.queryNoPromptUidList.length - 1;
        disturbTheNews = true;
      } else {
        if (disturbTheNewsIndex >= 0) {
          MessageManager.queryNoPromptUidList.removeAt(disturbTheNewsIndex);
        }
        disturbTheNewsIndex = -1;
        disturbTheNews = false;
      }
    } else {
      disturbTheNews = !disturbTheNews;
    }
    Loading.hideLoading(context);
    if (mounted) {
      setState(() {});
    }
  }

  //获取消息是否免打扰
  Future<void> getConversationNotificationStatus() async {
    //检测是否置顶
    if (MessageManager.topChatModelList == null || MessageManager.topChatModelList.length < 1) {
      topChat = false;
    } else {
      for (int i = 0; i < MessageManager.topChatModelList.length; i++) {
        if (MessageManager.topChatModelList[i].type == 0 &&
            MessageManager.topChatModelList[i].chatId.toString() == widget.chatUserId) {
          topChat = true;
          topChatIndex = i;
          break;
        }
      }
    }

    //判断有没有免打扰
    if (MessageManager.queryNoPromptUidList == null || MessageManager.queryNoPromptUidList.length < 1) {
      disturbTheNews = false;
    } else {
      for (int i = 0; i < MessageManager.queryNoPromptUidList.length; i++) {
        if (MessageManager.queryNoPromptUidList[i].type == widget.chatType &&
            MessageManager.queryNoPromptUidList[i].targetId.toString() == widget.chatUserId) {
          disturbTheNews = true;
          disturbTheNewsIndex = i;
          break;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
    //融云检测有没有开启免打扰
    // Application.rongCloud.getConversationNotificationStatus(
    //     RCConversationType.Private, widget.chatUserId,
    //         (int status, int code) {
    //       print("status:$status---code:$code");
    //       if (code == 0) {
    //         disturbTheNews = status == RCConversationNotificationStatus.DoNotDisturb;
    //       }
    //     });
  }

  //获取是否在黑名单内
  void getBlackListStatus() async {
    BlackModel model = await ProfileCheckBlack(int.parse(widget.chatUserId));
    if (model != null) {
      isBlackList = model.inYouBlack == 1;
      await getConversationNotificationStatus();
    }

    //融云检测拉黑关系
    // Application.rongCloud.getBlackListStatus(
    //     widget.chatUserId, (int blackListStatus, int code) {
    //   if (code == 0) {
    //     isBlackList = blackListStatus == 0;
    //   }
    // });
  }

  //拉黑了这个人
  void addToBlackList() async {
    Loading.showLoading(context);
    Future.delayed(Duration(milliseconds: 300), () async {
      if (await isOffline()) {
        ToastShow.show(msg: "请检查网络!", context: context);
        Loading.hideLoading(context);
        return;
      }
      bool blackStatus = await ProfileAddBlack(int.parse(widget.chatUserId));
      if (blackStatus != null && blackStatus) {
        isBlackList = true;
        ToastShow.show(msg: "已拉黑", context: context);
        if (widget.listener != null) {
          widget.listener(2, "拉黑");
        }
        if (mounted) {
          setState(() {
            Loading.hideLoading(context);
          });
        }
        try{
          if (context.read<UserInteractiveNotifier>().value.profileUiChangeModel.containsKey(int.parse(widget.chatUserId))) {
            context.read<UserInteractiveNotifier>().changeBlackStatus( int.parse(widget.chatUserId), true, needNotify: false);
            context.read<UserInteractiveNotifier>().changeIsFollow(true, true, int.parse(widget.chatUserId));
            context.read<UserInteractiveNotifier>().changeFollowCount(int.parse(widget.chatUserId), false);
          }
        }catch(e){
          print('------------------这是聊天页更多里面个人主页的方法报的错-----$e');
        }
      } else {
        ToastShow.show(msg: "拉黑失败", context: context);
        Loading.hideLoading(context);
      }
    });
  }

  //解除了拉黑
  void removeFromBlackList() async {
    Loading.showLoading(context);
    Future.delayed(Duration(milliseconds: 300), () async {
      if (await isOffline()) {
        ToastShow.show(msg: "请检查网络!", context: context);
        Loading.hideLoading(context);
        return;
      }
      bool blackStatus = await ProfileCancelBlack(int.parse(widget.chatUserId));
      if (blackStatus) {
        isBlackList = false;
        ToastShow.show(msg: "已解除拉黑", context: context);
        if (mounted) {
          setState(() {
            Loading.hideLoading(context);
          });
        }
        context.read<UserInteractiveNotifier>().changeBlackStatus( int.parse(widget.chatUserId), false, needNotify:
        false);
      } else {
        ToastShow.show(msg: "解除拉黑失败", context: context);
        Loading.hideLoading(context);
      }
    });
  }

  //点击事件
  void onClickItem(bool isTrue, String title) async {
    if (ClickUtil.isFastClick()) {
      print("快速点击");
      return;
    }
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    if (title == "拉黑") {
      showAppDialog(context,
          barrierDismissible: false,
          title: "拉黑",
          info: "确定需要将此人拉黑吗？",
          cancel: AppDialogButton("取消", () {
            return true;
          }),
          confirm: AppDialogButton("拉黑", () {
            Future.delayed(Duration(milliseconds: 100), () {
              addToBlackList();
            });
            return true;
          }));
    } else if (title == "解除拉黑") {
      removeFromBlackList();
    } else if (title == "消息免打扰") {
      setConversationNotificationStatus();
    } else if (title == "置顶聊天") {
      setTopChatApi();
    }
  }



  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }
}
