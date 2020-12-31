import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
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

  @override
  void initState() {
    super.initState();
    initData();
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
              child: item(3, topChat, "拉黑", isCupertinoSwitchShow: false),
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
                scale: 0.8,
                child: CupertinoSwitch(
                  activeColor: AppColor.mainRed,
                  value: isOpen,
                  onChanged: (bool value) {
                    return;
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
        "${widget.chatUserId}_${RCConversationType.Private}_${Application.profile.uid.toString()}_disturbTheNews",
        disturbTheNews);
    prefs.setBool(
        "${widget.chatUserId}_${RCConversationType.Private}_${Application.profile.uid.toString()}_topChat",
        topChat);
  }

  //点击事件
  void onClickItem(bool isTrue, String title) {
    if (title == "拉黑") {
      ToastShow.show(msg: "拉黑了这个人", context: context);
    } else {
      ToastShow.show(msg: "${isTrue ? "打开" : "关闭"}$title", context: context);
    }
  }
}
