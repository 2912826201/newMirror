import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isBlackList = false;

  @override
  void initState() {
    super.initState();
    initData();
    getBlackListStatus();
  }

  @override
  void dispose() {
    super.dispose();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.chatType == MANAGER_TYPE ? "系统官方消息" : "私人消息"}"),
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
              offstage: widget.chatType == MANAGER_TYPE,
              child: item(3, topChat, isBlackList ? "解除拉黑" : "拉黑",
                  isCupertinoSwitchShow: false),
            ),
            Offstage(
              offstage: widget.chatType == MANAGER_TYPE,
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

  void initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    disturbTheNews = (prefs.getBool(
            "${widget.chatUserId}_${RCConversationType.Private}_${Application.profile.uid.toString()}_disturbTheNews") ??
        false);
    topChat = (prefs.getBool(
            "${widget.chatUserId}_${RCConversationType.Private}_${Application.profile.uid.toString()}_topChat") ??
        false);
    setState(() {});
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(
        "${widget.chatUserId}_${RCConversationType.Private}_${Application
            .profile.uid.toString()}_disturbTheNews",
        disturbTheNews);
    prefs.setBool(
        "${widget.chatUserId}_${RCConversationType.Private}_${Application
            .profile.uid.toString()}_topChat",
        topChat);
  }


  //获取是否在黑名单内
  void getBlackListStatus() {
    Application.rongCloud.getBlackListStatus(
        widget.chatUserId, (int blackListStatus, int code) {
      if (code == 0) {
        isBlackList = blackListStatus == 0;
        setState(() {

        });
      }
    });
  }

  //拉黑了这个人
  void addToBlackList() {
    Application.rongCloud.addToBlackList(widget.chatUserId, (code) {
      if (code == 0) {
        isBlackList = true;
        ToastShow.show(msg: "拉黑了这个人", context: context);
        setState(() {});
      } else {
        ToastShow.show(msg: "拉黑失败", context: context);
      }
    });
  }

  //解除了拉黑
  void removeFromBlackList() {
    Application.rongCloud.removeFromBlackList(widget.chatUserId, (code) {
      if (code == 0) {
        isBlackList = false;
        ToastShow.show(msg: "解除了拉黑", context: context);
        setState(() {});
      } else {
        ToastShow.show(msg: "拉黑失败", context: context);
      }
    });
  }


  //点击事件
  void onClickItem(bool isTrue, String title) {
    if (ClickUtil.isFastClick()) {
      print("快速点击");
      return;
    }
    print("不是快速点击");

    if (title == "拉黑") {
      addToBlackList();
    }
    if (title == "解除拉黑") {
      removeFromBlackList();
    } else {
      ToastShow.show(msg: "${isTrue ? "打开" : "关闭"}$title", context: context);
    }
  }
}
