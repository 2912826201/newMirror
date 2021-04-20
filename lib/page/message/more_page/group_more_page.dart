import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/loading_progress.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/api/message_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import '../message_chat_page_manager.dart';

typedef VoidCallback = void Function();

///群聊天-更多界面
class GroupMorePage extends StatefulWidget {
  ///群id
  final String chatGroupId;

  final Function(int type, String name) listener;
  final VoidCallback exitGroupListener;
  final ConversationDto dto;

  ///群名字
  final String groupName;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  GroupMorePage({this.chatGroupId, this.chatType, this.groupName, this.listener, this.dto, this.exitGroupListener});

  @override
  createState() => GroupMorePageState();
}

class GroupMorePageState extends State<GroupMorePage> {
  bool disturbTheNews = false;
  int disturbTheNewsIndex = -1;
  bool topChat = false;
  String groupMeName = "还未取名";
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "群聊消息 (${context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length})",
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
          getListItem(text: "群聊名称", subtitle: groupName ?? "未命名"),
          getListItem(text: "群聊二维码", isRightIcon: true),
          getContainer(height: 12, horizontal: 0),
          getListItem(text: "群昵称", subtitle: groupMeName == "还未取名" ? getGroupMeName() : groupMeName),
          getContainer(),
          getListItem(text: "消息免打扰", isOpen: disturbTheNews, index: 1),
          getListItem(text: "置顶聊天", isOpen: topChat, index: 2),
          getContainer(height: 12, horizontal: 0),
          getListItem(text: "删除并退出", textColor: AppColor.mainRed),
          getContainer(),
          SliverToBoxAdapter(
            child: Container(
              height: ScreenUtil.instance.bottomBarHeight,
              color: AppColor.white,
            ),
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
          ChatGroupUserModel addModel = new ChatGroupUserModel();
          addModel.avatarUri = "addModel";
          groupUserList.add(addModel);
          bool isHaveSubBtn;
          try {
            isHaveSubBtn = chatGroupUserModelList[0].uid == Application.profile.uid;
          } catch (e) {
            isHaveSubBtn = false;
          }
          if (isHaveSubBtn) {
            ChatGroupUserModel addModel = new ChatGroupUserModel();
            addModel.avatarUri = "subModel";
            groupUserList.add(addModel);
          }
          return SliverGrid.count(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            children: List.generate(groupUserList.length, (index) {
              if (groupUserList[index].avatarUri == "addModel") {
                return getTopItemAddOrSubUserUi(true, true);
              } else if (groupUserList[index].avatarUri == "subModel") {
                return getTopItemAddOrSubUserUi(false, true);
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
    if (context.watch<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
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
                AppIcon.getAppIcon(AppIcon.arrow_right_12, 12, color: AppColor.textSecondary),
              ],
            ),
            onTap: seeMoreGroupUser,
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }
  }

  //获取下面每一个listItem
  Widget getListItem({String text, String subtitle, bool isOpen, bool isRightIcon, Color textColor, int index}) {
    return SliverToBoxAdapter(
        // child: getItemList(text,subtitle,isOpen,isRightIcon,textColor),
        child: Material(
            color: AppColor.white,
            child: new InkWell(
              child: getItemList(text, subtitle, isOpen, isRightIcon, textColor, index),
              splashColor: AppColor.textHint,
              onTap: () {
                onClickItemList(title: text, subtitle: subtitle, isOpen: isOpen, index: index);
              },
            )));
  }

  //每一个item--list
  Widget getItemList(String text, String subtitle, bool isOpen, bool isRightIcon, Color textColor, int index) {
    var padding1 = const EdgeInsets.only(left: 16, right: 10);
    var padding2 = const EdgeInsets.symmetric(horizontal: 16);
    return Container(
      height: 48,
      padding: isOpen == null ? padding2 : padding1,
      child: Row(
        children: [
          Text(text,
              style: TextStyle(fontSize: 16, color: textColor ?? AppColor.textPrimary1, fontWeight: FontWeight.w500)),
          Expanded(child: SizedBox()),
          subtitle != null
              ? Text(
                  StringUtil.maxLength(subtitle, 15),
                  style: AppStyle.textSecondaryMedium14,
                )
              : Container(),
          subtitle != null ? SizedBox(width: 12) : Container(),
          isRightIcon != null || subtitle != null
              ? AppIcon.getAppIcon(AppIcon.arrow_right_18, 18, color: AppColor.textSecondary)
              : Container(),
          isOpen != null
              ? Container(
                  child: Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                      activeColor: AppColor.mainRed,
                      value: isOpen,
                      onChanged: (bool value) {
                        onClickItemList(title: text, isOpen: isOpen, index: index);
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

    return GestureDetector(
      onTap: () async {
        if (!(await isContinue())) {
          return;
        }
        AppRouter.navigateToMineDetail(context, userModel.uid,
            avatarUrl: userModel.avatarUri, userName: userModel.nickName);
      },
      child: Container(
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


  String getGroupMeName() {
    String userName = ((Application.chatGroupUserInformationMap["${widget.chatGroupId}_${Application.profile.uid}"] ??
        Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    if (userName == null || userName.length < 1) {
      userName = (Application.chatGroupUserInformationMap["${widget.chatGroupId}_${Application.profile.uid}"] ??
          Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
    }
    if (userName == null || userName.length < 1) {
      return Application.profile.nickName;
    } else {
      return userName;
    }
  }


  //获取群信息
  void getGroupInformation() async {
    try {
      List<GroupChatModel> list = await getGroupChatByIds(id: int.parse(widget.chatGroupId));
      if (list != null) {
        list.forEach((v) {
          groupChatModel = v;
          groupName = groupChatModel.modifiedName == null ? groupChatModel.name : groupChatModel.modifiedName;
        });
        await getConversationNotificationStatus();
      }
    } catch (e) {
      await getConversationNotificationStatus();
    }
  }

  //修改群名
  void modifyPr(String newName) async {
    if (context.read<GroupUserProfileNotifier>().isNoHaveMe()) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return;
    }
    try {
      Map<String, dynamic> model = await modify(groupChatId: int.parse(widget.chatGroupId), newName: newName);
      if (model != null && model["state"] != null && model["state"]) {
        groupChatModel.modifiedName = newName;
        groupName = newName;
        if (widget.listener != null) {
          widget.listener(1, groupName);
        }
        if (mounted) {
          setState(() {});
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
      Map<String, dynamic> model = await modifyNickName(groupChatId: int.parse(widget.chatGroupId), newName: newName);
      print(model == null ? "" : model.toString());
      if (model != null && model["uid"] != null) {
        groupMeName = newName;
        ChatGroupUserModel chatGroupUserModel = new ChatGroupUserModel();
        chatGroupUserModel.uid = Application.profile.uid;
        chatGroupUserModel.groupNickName = groupMeName;
        chatGroupUserModel.nickName = Application.profile.nickName;
        chatGroupUserModel.avatarUri = Application.profile.avatarUri;
        if (mounted) {
          setState(() {});
        }
        await GroupChatUserInformationDBHelper().update(chatGroupUserModel: chatGroupUserModel, groupId: widget.chatGroupId);
        if (widget.listener != null) {
          widget.listener(0, newName);
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

  //查看更多群成员
  void seeMoreGroupUser() async {
    if (!(await isContinue())) {
      return;
    }
    AppRouter.navigateFriendsPage(context: context, type: 1, groupChatId: int.parse(widget.chatGroupId));
  }

  //添加用户按钮
  void addGroupUser() async {
    if (!(await isContinue())) {
      return;
    }
    AppRouter.navigateFriendsPage(context: context, type: 3, groupChatId: int.parse(widget.chatGroupId));
  }

  //删除用户按钮
  void deleteGroupUser() async {
    if (!(await isContinue())) {
      return;
    }
    AppRouter.navigateFriendsPage(context: context, type: 2, groupChatId: int.parse(widget.chatGroupId));
  }

  //退出按钮
  void exitGroupChatPr() async {
    Map<String, dynamic> model = await exitGroupChat(groupChatId: int.parse(widget.chatGroupId));
    if (model != null && model["state"] != null && model["state"]) {
      if (widget.exitGroupListener != null) {
        widget.exitGroupListener();
      }

      GroupChatUserInformationDBHelper().removeGroupAllInformation(widget.chatGroupId);
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
    topChat = !topChat;
    Map<String, dynamic> map =
        await (topChat ? stickChat : cancelTopChat)(targetId: int.parse(widget.chatGroupId), type: 1);
    if (map != null && map["state"] != null && map["state"]) {
      TopChatModel topChatModel = new TopChatModel(type: 1, chatId: int.parse(widget.chatGroupId));
      int index = TopChatModel.containsIndex(Application.topChatModelList, topChatModel);
      if(topChat){
        if(index<0){
          Application.topChatModelList.add(topChatModel);
          if (null != widget.dto) {
            widget.dto.isTop = 1;
            context.read<ConversationNotifier>().insertTop(widget.dto);
          }
        }
      }else{
        if (index >= 0) {
          Application.topChatModelList.removeAt(index);
          if (null != widget.dto) {
            widget.dto.isTop = 0;
            context.read<ConversationNotifier>().insertCommon(widget.dto);
          }
        }
      }
    } else {
      topChat = !topChat;
    }

    // Application.topChatModelList.forEach((element) {
    //   print("Application.topChatModelList:${element.toJson().toString()}");
    // });

    if (mounted) {
      setState(() {});
    }
  }

  //设置消息免打扰
  void setConversationNotificationStatus() async {
    disturbTheNews = !disturbTheNews;
    //判断有没有免打扰
    Map<String, dynamic> map = await (disturbTheNews ? addNoPrompt : removeNoPrompt)(
        targetId: int.parse(widget.chatGroupId), type: GROUP_TYPE);
    if (map != null && map["state"] != null && map["state"]) {
      NoPromptUidModel model = NoPromptUidModel(type: GROUP_TYPE, targetId: int.parse(widget.chatGroupId));
      int index = NoPromptUidModel.containsIndex(Application.queryNoPromptUidList, model);
      if(disturbTheNews){
        if (index < 0) {
          Application.queryNoPromptUidList.add(model);
        }
      }else{
        if (index >= 0) {
          Application.queryNoPromptUidList.remove(index);
        }
      }
    } else {
      disturbTheNews = !disturbTheNews;
    }
    if (mounted) {
      setState(() {});
    }
  }

  //获取消息是否免打扰
  Future<void> getConversationNotificationStatus() async {
    //判断有没有置顶
    if (Application.topChatModelList == null || Application.topChatModelList.length < 1) {
      topChat = false;
      print("没有置顶");
    } else {
      for (TopChatModel topChatModel in Application.topChatModelList) {
        if (topChatModel.type == 1 && topChatModel.chatId.toString() == widget.chatGroupId) {
          topChat = true;
          print("有置顶");
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

    if (mounted) {
      setState(() {});
    }
  }

  //点击事件
  void onClickItemList({
    String title,
    String subtitle,
    bool isOpen,
    int index,
  }) async {
    if (!(await isContinue())) {
      return;
    }
    if (isOpen != null) {
      if (index == 1) {
        setConversationNotificationStatus();
      } else {
        setTopChatApi();
      }
      // ToastShow.show(msg: "${!isOpen ? "打开" : "关闭"}$title", context: context);
    } else if (title == "群聊名称") {
      AppRouter.navigateToEditInfomationName(context, subtitle, (result) {
        if (mounted) {
          setState(() {
            if (result != null && groupName != result) {
              modifyPr(result);
            }
          });
        }
      }, title: "编辑群聊名称");
      // ToastShow.show(msg: subtitle, context: context);
    } else if (title == "群昵称") {
      AppRouter.navigateToEditInfomationName(context, subtitle, (result) {
        if (mounted) {
          setState(() {
            if (result != null && groupMeName != result) {
              modifyNickNamePr(result);
            }
          });
        }
      }, title: "编辑群昵称");
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
      if (groupChatModel == null) {
        ToastShow.show(msg: "获取群聊信息失败", context: context);
      } else {
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

  showProgressDialog({
    Widget progress,
    Color bgColor,
  }) {
    if (_dialogLoadingController == null) {
      _dialogLoadingController = DialogLoadingController();
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (ctx, animation, secondAnimation) {
            return LoadingProgress(
              controller: _dialogLoadingController,
              progress: progress,
              bgColor: bgColor,
            );
          }));
    }
  }

  dismissProgressDialog() {
    _dialogLoadingController?.dismissDialog();
    _dialogLoadingController = null;
  }

  //是否继续
  Future<bool> isContinue() async {
    if (ClickUtil.isFastClick()) {
      print("快速点击");
      return false;
    }
    if (context.read<GroupUserProfileNotifier>().isNoHaveMe()) {
      ToastShow.show(msg: "你不是群成员", context: context);
      return false;
    }
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return false;
    }
    return true;
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
