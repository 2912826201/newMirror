import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/LoadingProgress.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

typedef VoidCallback = void Function();

class GroupMorePage extends StatefulWidget {
  ///群id
  final String chatGroupId;

  final VoidCallback listener;
  final VoidCallback exitGroupListener;

  ///群名字
  final String groupName;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  GroupMorePage({this.chatGroupId, this.chatType, this.groupName, this.listener, this.exitGroupListener});

  @override
  createState() => GroupMorePageState();
}

class GroupMorePageState extends State<GroupMorePage> {
  bool disturbTheNews = false;
  bool topChat = false;
  String groupMeName = "还未取名";
  bool isUpdateGroupMeName = false;
  Map<String, dynamic> groupInformationMap;
  String groupName;
  DialogLoadingController _dialogLoadingController;

  LoadStatus loadStatus = LoadStatus.loading;

  @override
  void initState() {
    super.initState();
    getGroupInformation();
  }

  @override
  void dispose() {
    super.dispose();
    updateUserName();
    isUpdateGroupMeName = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("群聊消息"),
        centerTitle: true,
      ),
      body: getBodyUi(),
    );
  }

  //获取主体
  Widget getBodyUi() {
    return Container(
      color: AppColor.white,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          getTopAllUserImage(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 8,
            ),
          ),
          getSeeAllUserBtn(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          getContainer(),
          getListItem(text: "群聊名称", subtitle: groupName ?? widget.groupName),
          getListItem(text: "群聊二维码", isRightIcon: true),
          getContainer(height: 12, horizontal: 0),
          getListItem(
              text: "群昵称",
              subtitle: groupMeName == "还未取名" ? getGroupMeName() : groupMeName),
          getContainer(),
          getListItem(text: "消息免打扰", isOpen: disturbTheNews, index: 1),
          getListItem(text: "置顶聊天", isOpen: topChat, index: 2),
          getContainer(height: 12, horizontal: 0),
          getListItem(text: "删除并退出", textColor: AppColor.mainRed),
          getContainer(),
        ],
      ),
    );
  }

  //获取头部群用户的头像
  Widget getTopAllUserImage() {
    List<ChatGroupUserModel> groupUserList = <ChatGroupUserModel>[];
    if (Application.chatGroupUserModelList.length > 13) {
      groupUserList.addAll(Application.chatGroupUserModelList.sublist(0, 13));
    } else {
      groupUserList.addAll(Application.chatGroupUserModelList);
    }
    groupUserList.add(new ChatGroupUserModel());
    groupUserList.add(new ChatGroupUserModel());
    return SliverGrid.count(
      crossAxisCount: 5,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: List.generate(groupUserList.length, (index) {
        if (index >= groupUserList.length - 2) {
          bool isVisibility;
          try {
            isVisibility = index == groupUserList.length - 2 ||
                Application.chatGroupUserModelList[0].uid == Application.profile.uid;
          } catch (e) {
            isVisibility = false;
          }
          return getTopItemAddOrSubUserUi(index == groupUserList.length - 2, isVisibility);
        } else {
          return getItemUserImage(index, groupUserList[index]);
        }
      }).toList(),
    );
  }

  //获取查看更多用户的按钮
  Widget getSeeAllUserBtn() {
    return SliverToBoxAdapter(
      child: Container(
        child: GestureDetector(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "查看更多群成员",
                style: TextStyle(color: AppColor.textSecondary, fontSize: 12),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColor.textSecondary,
                size: 12,
              ),
            ],
          ),
          onTap: () {
            seeMoreGroupUser();
          },
        ),
      ),
    );
  }

  //获取下面每一个listItem
  Widget getListItem(
      {String text,
      String subtitle,
      bool isOpen,
      bool isRightIcon,
      Color textColor,
      int index}) {
    return SliverToBoxAdapter(
        // child: getItemList(text,subtitle,isOpen,isRightIcon,textColor),
        child: Material(
            color: AppColor.white,
            child: new InkWell(
              child: getItemList(
                  text, subtitle, isOpen, isRightIcon, textColor, index),
              splashColor: AppColor.textHint,
              onTap: () {
                onClickItemList(title: text,
                    subtitle: subtitle,
                    isOpen: isOpen,
                    index: index);
              },
            )));
  }

  //每一个item--list
  Widget getItemList(String text, String subtitle, bool isOpen,
      bool isRightIcon, Color textColor, int index) {
    var padding1 = const EdgeInsets.only(left: 16, right: 10);
    var padding2 = const EdgeInsets.symmetric(horizontal: 16);
    return Container(
      height: 48,
      padding: isOpen == null ? padding2 : padding1,
      child: Row(
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? AppColor.textPrimary1,
                  fontWeight: FontWeight.w500)),
          Expanded(child: SizedBox()),
          subtitle != null
              ? Text(getMaxLengthString(subtitle),
            style: AppStyle.textSecondaryMedium14,)
              : Container(),
          subtitle != null ? SizedBox(width: 12) : Container(),
          isRightIcon != null || subtitle != null
              ? Icon(
                  Icons.chevron_right,
                  size: 17,
                  color: AppColor.textSecondary,
                )
              : Container(),
          isOpen != null
              ? Container(
                  child: Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                      activeColor: AppColor.mainRed,
                      value: isOpen,
                      onChanged: (bool value) {
                        onClickItemList(
                            title: text, isOpen: isOpen, index: index);
                      },
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  //间隔线
  Widget getContainer({double height, double horizontal}) {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: horizontal ?? 16),
        height: height ?? 0.5,
        color: AppColor.bgWhite,
      ),
    );
  }

  //获取每一个用户的头像显示
  Widget getItemUserImage(int index, ChatGroupUserModel userModel) {
    return Container(
      child: Column(
        children: [
          getUserImage(userModel.avatarUri, 47, 47),
          SizedBox(
            height: 6,
          ),
          SizedBox(
            width: 47,
            child: Text(userModel.uid == Application.profile.uid ? groupMeName ?? userModel.groupNickName ?? "" :
            userModel.groupNickName ?? "",
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  //显示加减群成员
  Widget getTopItemAddOrSubUserUi(bool isAdd, bool isVisibility) {
    return Visibility(
      visible: isVisibility,
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(47 / 2.0),
                child: Container(
                  color: AppColor.bgWhite,
                  width: 47,
                  height: 47,
                  child: Center(
                    child: Text(
                      isAdd ? "+" : "-",
                      style: TextStyle(fontSize: 20, color: AppColor.textPrimary1),
                    ),
                  ),
                ),
              ),
              onTap: () {
                if (isAdd) {
                  addGroupUser();
                } else {
                  deleteGroupUser();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  //获取我的群昵称
  String getGroupMeName() {
    String name = "还未取名";
    for (int i = 1; i < Application.chatGroupUserModelList.length; i++) {
      if (Application.chatGroupUserModelList[i].uid ==
          Application.profile.uid) {
        groupMeName = Application.chatGroupUserModelList[i].groupNickName;
        return Application.chatGroupUserModelList[i].groupNickName;
      }
    }
    return name;
  }


  //获取群信息
  void getGroupInformation() async {
    print("getGroupInformation");
    try {
      Map<String, dynamic> model = await getGroupChatByIds(id: int.parse(widget.chatGroupId));
      if (model != null && model["list"] != null) {
        model["list"].forEach((v) {
          groupInformationMap = v;
          groupName = groupInformationMap["name"];
        });
        await getConversationNotificationStatus();
      }
    } catch (e) {
      await getConversationNotificationStatus();
    }
  }

  //修改群名
  void modifyPr(String newName) async {
    try {
      Map<String, dynamic> model = await modify(
          groupChatId: int.parse(widget.chatGroupId), newName: newName);
      if (model != null && model["state"] != null && model["state"]) {
        groupName = newName;
        setState(() {

        });
      } else {
        ToastShow.show(msg: "修改失败", context: context);
      }
    } catch (e) {
      ToastShow.show(msg: "修改失败", context: context);
    }
  }

  //修改群昵称
  void modifyNickNamePr(String newName) async {
    try {
      Map<String, dynamic> model = await modifyNickName(
          groupChatId: int.parse(widget.chatGroupId), newName: newName);
      print(model == null ? "" : model.toString());
      if (model != null && model["uid"] != null) {
        groupMeName = newName;
        isUpdateGroupMeName = true;
        setState(() {

        });
      } else {
        ToastShow.show(msg: "修改失败", context: context);
      }
    } catch (e) {
      ToastShow.show(msg: "修改失败", context: context);
    }
  }

  //限制字符串的长度
  String getMaxLengthString(String text) {
    if (text == null) {
      return "";
    }
    if (text.length > 10) {
      return text.substring(0, 10) + "...";
    } else {
      return text;
    }
  }


  void updateUserName() {
    if (isUpdateGroupMeName) {
      for (int i = 0; i < Application.chatGroupUserModelList.length; i++) {
        if (Application.chatGroupUserModelList[i].uid == Application.profile.uid) {
          Application.chatGroupUserModelList[i].groupNickName = groupMeName;
          if (widget.listener != null) {
            widget.listener();
          }
        }
      }
    }
  }


  //查看更多群成员
  void seeMoreGroupUser() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return FriendsPage(
          type: 1,
          groupChatId: int.parse(widget.chatGroupId),
          voidCallback: (name, userId, context) {
            print("查看了name：$name");
          });
    }));
  }

  //添加用户按钮
  void addGroupUser() {
    print("添加群成员");

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return FriendsPage(type: 3, groupChatId: int.parse(widget.chatGroupId), voidCallback: (name, userId, context) {
        print("添加用户：$name进群");

        setState(() {

        });
      });
    }));
  }

  //删除用户按钮
  void deleteGroupUser() {
    print("删除群成员");
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return FriendsPage(
          type: 2,
          groupChatId: int.parse(widget.chatGroupId),
          voidCallback: (name, userId, context) {
            print("移除这个用户：$name");

            setState(() {});
          });
    }));
  }

  //删除用户按钮
  void exitGroupChatPr() async {
    Map<String, dynamic> model = await exitGroupChat(groupChatId: int.parse(widget.chatGroupId));
    if (model != null && model["state"] != null && model["state"]) {
      if (widget.exitGroupListener != null) {
        widget.exitGroupListener();
      }
      ToastShow.show(msg: "退出成功", context: context);
      Navigator.of(context).pop();
    } else {
      ToastShow.show(msg: "退出失败", context: context);
    }
  }


  //设置消息是否置顶
  void setTopChatApi() async {
    showProgressDialog();
    Map<String, dynamic> map =
        await (topChat ? stickChat : cancelTopChat)(targetId: int.parse(widget.chatGroupId), type: 1);
    if (map != null && map["state"] != null && map["state"]) {
      TopChatModel topChatModel = new TopChatModel(type: 1, chatId: int.parse(widget.chatGroupId));
      if (Application.topChatModelList.contains(topChatModel)) {
        Application.topChatModelList.remove(topChatModel);
      } else {
        Application.topChatModelList.add(topChatModel);
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
    Map<String, dynamic> map =
        await (disturbTheNews ? addNoPrompt : removeNoPrompt)(targetId: int.parse(widget.chatGroupId));
    if (!(map != null && map["state"] != null && map["state"])) {
      disturbTheNews = !disturbTheNews;
    } else {
      Application.rongCloud.setConversationNotificationStatus(
          RCConversationType.Group, widget.chatGroupId, disturbTheNews, (int status, int code) {
        print(status);
      });
    }
    setState(() {
      dismissProgressDialog();
    });
  }

  //获取消息是否免打扰
  Future<void> getConversationNotificationStatus() async {
    //判断有没有置顶
    if (Application.topChatModelList == null || Application.topChatModelList.length < 1) {
      topChat = false;
    } else {
      for (TopChatModel topChatModel in Application.topChatModelList) {
        if (topChatModel.type == 1 && topChatModel.chatId.toString() == widget.chatGroupId) {
          topChat = true;
          break;
        }
      }
    }

    //判断有没有免打扰
    Map<String, dynamic> map = await queryIsNoPrompt(targetId: int.parse(widget.chatGroupId));
    disturbTheNews = map != null && map["state"] != null && map["state"];
    setState(() {});

    //融云的--暂时没用
    // Application.rongCloud.getConversationNotificationStatus(
    //     RCConversationType.Group, widget.chatGroupId,
    //         (int status, int code) {
    //       print("status:$status---code:$code");
    //       if (code == 0) {
    //         disturbTheNews = status == RCConversationNotificationStatus.DoNotDisturb;
    //       }
    //     });
  }

  //点击事件
  void onClickItemList({String title, String subtitle, bool isOpen, int index,}) {
    if (isOpen != null) {
      if (index == 1) {
        disturbTheNews = !disturbTheNews;
        setConversationNotificationStatus();
      } else {
        topChat = !topChat;
        setTopChatApi();
      }
      // ToastShow.show(msg: "${!isOpen ? "打开" : "关闭"}$title", context: context);
    } else if (title == "群聊名称") {
      AppRouter.navigateToEditInfomationName(context, subtitle, (result) {
        setState(() {
          if (result != null && groupName != result) {
            modifyPr(result);
          }
        });
      }, title: "修改群聊名称");
      // ToastShow.show(msg: subtitle, context: context);
    } else if (title == "群昵称") {
      AppRouter.navigateToEditInfomationName(context, subtitle, (result) {
        setState(() {
          if (result != null && groupMeName != result) {
            modifyNickNamePr(result);
          }
        });
      }, title: "修改群昵称");
      // ToastShow.show(msg: subtitle, context: context);
    } else if (title == "删除并退出") {
      showAppDialog(context,
          title: "退出群聊",
          info: "你确定退出当前群聊吗?",
          cancel: AppDialogButton("取消", () {
            // print("点了取消");
            return true;
          }),
          confirm: AppDialogButton("确定", () {
            exitGroupChatPr();
            return true;
          }));
      // ToastShow.show(msg: "点击了：$title", context: context);
    } else {
      ToastShow.show(msg: "点击了：$title", context: context);
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


