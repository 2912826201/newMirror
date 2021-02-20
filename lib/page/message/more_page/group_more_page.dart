import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/loading_progress.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';
import 'package:mirror/api/message_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import '../message_chat_page_manager.dart';

typedef VoidCallback = void Function();

///群聊天-更多界面
class GroupMorePage extends StatefulWidget {
  ///群id
  final String chatGroupId;

  final Function(int type,String name) listener;
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
  GroupChatModel groupChatModel;
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
      appBar: CustomAppBar(
        titleString: "群聊消息",
      ),
      body: getBodyUi(),
    );
  }

  //获取主体
  Widget getBodyUi() {
    print("groupMeName:${groupMeName}");
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
          getListItem(text: "群聊名称", subtitle: groupName ?? "未命名"),
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
          SliverToBoxAdapter(
            child: Container(height: ScreenUtil.instance.bottomBarHeight,color: AppColor.white,),
          )
        ],
      ),
    );
  }

  //获取头部群用户的头像
  Widget getTopAllUserImage() {
    return Consumer<GroupUserProfileNotifier>(
      builder: (context, notifier, child) {
        if (context.watch<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
          List<ChatGroupUserModel> groupUserList = <ChatGroupUserModel>[];
          List<ChatGroupUserModel> chatGroupUserModelList =
              context.watch<GroupUserProfileNotifier>().chatGroupUserModelList;
          if (chatGroupUserModelList.length > 13) {
            groupUserList.addAll(chatGroupUserModelList.sublist(0, 13));
          } else {
            groupUserList.addAll(chatGroupUserModelList);
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
                  isVisibility =
                      index == groupUserList.length - 2 || chatGroupUserModelList[0].uid == Application.profile.uid;
                } catch (e) {
                  isVisibility = false;
                }
                return getTopItemAddOrSubUserUi(index == groupUserList.length - 2, isVisibility);
              } else {
                return getItemUserImage(index, groupUserList[index]);
              }
            }).toList(),
          );
        } else if (context.watch<GroupUserProfileNotifier>().len >= 0) {
          getChatGroupUserModelList(widget.chatGroupId, context);
        }
        return SliverToBoxAdapter(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: UnconstrainedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  //获取查看更多用户的按钮
  Widget getSeeAllUserBtn() {
    if (context
        .watch<GroupUserProfileNotifier>()
        .loadingStatus == LoadingStatus.STATUS_COMPLETED) {
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
    } else {
      return SliverToBoxAdapter(
        child: Container(

        ),
      );
    }
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
    String userName;
    if (userModel.uid == Application.profile.uid && groupMeName != null && groupMeName != "还未取名") {
      userName = groupMeName;
    } else {
      userName = userModel.groupNickName ?? "";
    }

    return Container(
      child: Column(
        children: [
          getUserImage(userModel.avatarUri, 47, 47),
          SizedBox(
            height: 6,
          ),
          SizedBox(
            width: 47,
            child: Text(
              userName,
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
    if (context.watch<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      for (int i = 0; i < context
          .watch<GroupUserProfileNotifier>()
          .chatGroupUserModelList
          .length; i++) {
        if (context
            .watch<GroupUserProfileNotifier>()
            .chatGroupUserModelList[i].uid ==
            Application.profile.uid) {
          groupMeName = context
              .watch<GroupUserProfileNotifier>()
              .chatGroupUserModelList[i].groupNickName;
          return context
              .watch<GroupUserProfileNotifier>()
              .chatGroupUserModelList[i].groupNickName;
        }
      }
    }
    return name;
  }


  //获取群信息
  void getGroupInformation() async {
    print("getGroupInformation");
    try {
      List<GroupChatModel> list = await getGroupChatByIds(id: int.parse(widget.chatGroupId));
      if (list != null ) {
        list.forEach((v) {
          groupChatModel = v;
          groupName = groupChatModel.modifiedName == null? groupChatModel.name : groupChatModel.modifiedName;
        });
        await getConversationNotificationStatus();
      }
    } catch (e) {
      await getConversationNotificationStatus();
    }
  }

  //修改群名
  void modifyPr(String newName) async {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    try {
      Map<String, dynamic> model = await modify(
          groupChatId: int.parse(widget.chatGroupId), newName: newName);
      if (model != null && model["state"] != null && model["state"]) {
        groupChatModel.modifiedName = newName;
        groupName = newName;
        if (widget.listener != null) {
          widget.listener(1,groupName);
        }
        if(mounted) {
          setState(() {

          });
        }
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
        if(mounted) {
          setState(() {

          });
        }
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
    if (text.length > 15) {
      return text.substring(0, 15) + "...";
    } else {
      return text;
    }
  }


  void updateUserName() {
    if (isUpdateGroupMeName) {
      if (context
          .read<GroupUserProfileNotifier>()
          .loadingStatus == LoadingStatus.STATUS_COMPLETED) {
        for (int i = 0; i < context
            .watch<GroupUserProfileNotifier>()
            .chatGroupUserModelList
            .length; i++) {
          if (context
              .watch<GroupUserProfileNotifier>()
              .chatGroupUserModelList[i].uid == Application.profile.uid) {
            context
                .watch<GroupUserProfileNotifier>()
                .chatGroupUserModelList[i].groupNickName = groupMeName;
            if (widget.listener != null) {
              widget.listener(0,groupMeName);
            }
          }
        }
      }
    }
  }


  //查看更多群成员
  void seeMoreGroupUser() {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    AppRouter.navigateFriendsPage(context: context,type: 1,groupChatId: int.parse(widget.chatGroupId));
  }

  //添加用户按钮
  void addGroupUser() {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    AppRouter.navigateFriendsPage(context: context,type: 3,groupChatId: int.parse(widget.chatGroupId));
  }

  //删除用户按钮
  void deleteGroupUser() {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    AppRouter.navigateFriendsPage(context: context,type: 2,groupChatId: int.parse(widget.chatGroupId));
  }

  //退出按钮
  void exitGroupChatPr() async {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    Map<String, dynamic> model = await exitGroupChat(groupChatId: int.parse(widget.chatGroupId));
    if (model != null && model["state"] != null && model["state"]) {
      if (widget.exitGroupListener != null) {
        widget.exitGroupListener();
      }
      ToastShow.show(msg: "退出成功", context: context);
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
      });
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
    if(mounted) {
      setState(() {
        dismissProgressDialog();
      });
    }
  }

  //设置消息免打扰
  void setConversationNotificationStatus() async {
    showProgressDialog();
    //判断有没有免打扰
    Map<String, dynamic> map = await (disturbTheNews ? addNoPrompt : removeNoPrompt)(
        targetId: int.parse(widget.chatGroupId), type: GROUP_TYPE);
    if (!(map != null && map["state"] != null && map["state"])) {
      disturbTheNews = !disturbTheNews;
    } else {
      Application.rongCloud.setConversationNotificationStatus(
          RCConversationType.Group, widget.chatGroupId, disturbTheNews, (int status, int code) {
        print(status);
      });
    }
    if(mounted) {
      setState(() {
        dismissProgressDialog();
      });
    }
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
    if (Application.queryNoPromptUidList == null || Application.queryNoPromptUidList.length < 1) {
      disturbTheNews = false;
    } else {
      for (NoPromptUidModel noPromptUidModel in Application.queryNoPromptUidList) {
        if (noPromptUidModel.type == GROUP_TYPE && noPromptUidModel.targetId.toString() == widget.chatGroupId) {
          disturbTheNews = true;
          break;
        }
      }
    }

    if(mounted) {
      setState(() {
      });
    }
  }

  //点击事件
  void onClickItemList({String title, String subtitle, bool isOpen, int index,}) {
    if (Application.chatGroupUserModelMap[Application.profile.uid.toString()] == null) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
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
        if(mounted) {
          setState(() {
            if (result != null && groupName != result) {
              modifyPr(result);
            }
          });
        }
      }, title: "修改群聊名称");
      // ToastShow.show(msg: subtitle, context: context);
    } else if (title == "群昵称") {
      AppRouter.navigateToEditInfomationName(context, subtitle, (result) {
        if(mounted) {
          setState(() {
            if (result != null && groupMeName != result) {
              modifyNickNamePr(result);
            }
          });
        }
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
    } else if (title == "群聊二维码") {
      if(groupChatModel == null){
        ToastShow.show(msg: "获取群聊信息失败", context: context);
      }else{
        AppRouter.navigateToGroupQrCodePage(
            context: context,
            imageUrl: groupChatModel.coverUrl,
            name: groupChatModel.modifiedName == null ? groupChatModel.name : groupChatModel.modifiedName,
            groupId: groupChatModel.id.toString(),
        );
      }
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


