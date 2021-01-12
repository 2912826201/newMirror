import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/widget/LoadingProgress.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class PrivateMorePage extends StatefulWidget {
  ///对话用户id
  final String chatUserId;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  PrivateMorePage({this.chatUserId, this.chatType});

  @override
  createState() => PrivateMorePageState();
}

class PrivateMorePageState extends State<PrivateMorePage> {
  bool disturbTheNews = false;
  bool topChat = false;
  int topChatIndex = -1;
  bool isBlackList = false;
  DialogLoadingController _dialogLoadingController;

  @override
  void initState() {
    super.initState();
    // initData();
    getBlackListStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.chatType == PRIVATE_TYPE ? "私人消息" : "系统官方消息"}"),
        centerTitle: true,
      ),
      body: Container(
        color: AppColor.white,
        child: Column(
          children: [
            item(1, disturbTheNews, "消息免打扰"),
            item(2, topChat, "置顶聊天"),
            getContainer(),
            Offstage(
              offstage: widget.chatType != PRIVATE_TYPE,
              child: item(3, topChat, isBlackList ? "解除拉黑" : "拉黑", isCupertinoSwitchShow: false),
            ),
            Offstage(
              offstage: widget.chatType != PRIVATE_TYPE,
              child: getContainer(),
            ),
          ],
        ),
      ),
    );
  }

  //点击事件的box
  Widget item(int type, bool isOpen, String title,
      {bool isCupertinoSwitchShow = true}) {
    return Material(
        color: AppColor.white,
        child: new InkWell(
          child: _switchRow(type, isOpen, title, isCupertinoSwitchShow),
          splashColor: AppColor.textHint,
          onTap: () {
            setState(() {
              if (type == 1) {
                disturbTheNews = !disturbTheNews;
                onClickItem(disturbTheNews, title);
              } else if (type == 2) {
                topChat = !topChat;
                onClickItem(topChat, title);
              } else {
                onClickItem(isOpen, title);
              }
            });
          },
        ));
  }

  //选项
  Widget _switchRow(
      int type, bool isOpen, String title, isCupertinoSwitchShow) {
    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: AppStyle.textRegular16,
            ),
            Expanded(child: SizedBox()),
            Offstage(
              offstage: !isCupertinoSwitchShow,
              child: Transform.scale(
                scale: 0.75,
                child: CupertinoSwitch(
                  activeColor: AppColor.mainRed,
                  value: isOpen,
                  onChanged: (bool value) {
                    if (type == 1) {
                      disturbTheNews = !disturbTheNews;
                      onClickItem(disturbTheNews, title);
                    } else if (type == 2) {
                      topChat = !topChat;
                      onClickItem(topChat, title);
                    } else {
                      onClickItem(isOpen, title);
                    }
                    setState(() {});
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
      color: AppColor.textHint,
    );
  }


  //设置消息是否置顶
  void setTopChatApi() async {
    showProgressDialog();
    Map<String, dynamic> map = await (topChat ? stickChat : cancelTopChat)(
        targetId: int.parse(widget.chatUserId), type: 0);
    print(map.toString());
    if (map != null && map["state"] != null && map["state"]) {
      TopChatModel topChatModel = new TopChatModel(type: 0, chatId: int.parse(widget.chatUserId));
      if (topChatIndex > 0 && !topChat) {
        Application.topChatModelList.removeAt(topChatIndex);
        topChatIndex = -1;
      } else {
        Application.topChatModelList.add(topChatModel);
        topChatIndex = Application.topChatModelList.length - 1;
      }
    } else {
      topChat = !topChat;
    }
    setState(() {
      dismissProgressDialog();
    });
  }

  //设置消息免打扰
  void setConversationNotificationStatus() async {
    showProgressDialog();
    //判断有没有免打扰
    Map<String, dynamic> map = await (disturbTheNews ? addNoPrompt : removeNoPrompt)(
        targetId: int.parse(widget.chatUserId));
    if (!(map != null && map["state"] != null && map["state"])) {
      disturbTheNews = !disturbTheNews;
    } else {
      Application.rongCloud.setConversationNotificationStatus(
          RCConversationType.Private, widget.chatUserId, disturbTheNews, (int status, int code) {
        print(status);
      });
    }
    setState(() {
      dismissProgressDialog();
    });
  }

  //获取消息是否免打扰
  Future<void> getConversationNotificationStatus() async {
    //检测是否置顶
    if (Application.topChatModelList == null || Application.topChatModelList.length < 1) {
      topChat = false;
    } else {
      for (int i = 0; i < Application.topChatModelList.length; i++) {
        if (Application.topChatModelList[i].type == 0 &&
            Application.topChatModelList[i].chatId.toString() == widget.chatUserId) {
          topChat = true;
          topChatIndex = i;
          break;
        }
      }
    }

    //判断有没有免打扰
    Map<String, dynamic> map = await queryIsNoPrompt(targetId: int.parse(widget.chatUserId));
    disturbTheNews = map != null && map["state"] != null && map["state"];

    setState(() {

    });

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
    showProgressDialog();
    bool blackStatus = await ProfileAddBlack(int.parse(widget.chatUserId));
    if (blackStatus) {
      isBlackList = true;
      ToastShow.show(msg: "拉黑了这个人", context: context);
      setState(() {
        dismissProgressDialog();
      });
    } else {
      ToastShow.show(msg: "拉黑失败", context: context);
      dismissProgressDialog();
    }
  }

  //解除了拉黑
  void removeFromBlackList() async {
    showProgressDialog();
    bool blackStatus = await ProfileCancelBlack(int.parse(widget.chatUserId));
    if (blackStatus) {
      isBlackList = false;
      ToastShow.show(msg: "解除了拉黑", context: context);
      setState(() {
        dismissProgressDialog();
      });
    } else {
      ToastShow.show(msg: "解除拉黑失败", context: context);
      dismissProgressDialog();
    }
  }


  //点击事件
  void onClickItem(bool isTrue, String title) {
    if (ClickUtil.isFastClick()) {
      print("快速点击");
      return;
    }
    if (title == "拉黑") {
      addToBlackList();
    } else if (title == "解除拉黑") {
      removeFromBlackList();
    } else if (title == "消息免打扰") {
      setConversationNotificationStatus();
    } else if (title == "置顶聊天") {
      setTopChatApi();
    }
  }

  showProgressDialog({Widget progress,
    Color bgColor,}) {
    if (_dialogLoadingController == null) {
      _dialogLoadingController = DialogLoadingController();
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (ctx, animation, secondAnimation) {
            return LoadingProgress(controller: _dialogLoadingController,
              progress: progress, bgColor: bgColor,);
          }
      ));
    }
  }

  dismissProgressDialog() {
    _dialogLoadingController?.dismissDialog();
    _dialogLoadingController = null;
  }
}
