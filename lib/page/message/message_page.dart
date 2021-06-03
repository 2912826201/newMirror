import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/message_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/data/notifier/unread_message_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/count_badge.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/create_group_popup.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:connectivity/connectivity.dart';
import 'package:app_settings/app_settings.dart';
import 'message_chat_page_manager.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';

/// message_page
/// Created by yangjiayi on 2020/12/21.

class MessagePage extends StatefulWidget {
  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<MessagePage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool isOffline = false;
  StreamSubscription<ConnectivityResult> connectivityListener;

  bool hasNotificationPermission = true;

  double _screenWidth = 0.0;
  int _listLength = 0;
  int choseUnreadType;
  StreamController<ConversationAnimationModel> streamController =
      StreamController<ConversationAnimationModel>.broadcast();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
    //绑定监听
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
    _initConnectivity();
    // 已在点击tab按钮时请求
    // _getUnreadMsgCount();
  }

  _removeUnreadNotice(int unReadTimeStamp, int type) {
    print('------------------------回调');
    switch (type) {
      case 0:
        context.read<UnreadMessageNotifier>().changeUnreadMsg(comments: 0);
        break;
      case 1:
        context.read<UnreadMessageNotifier>().changeUnreadMsg(ats: 0);
        break;
      case 2:
        context.read<UnreadMessageNotifier>().changeUnreadMsg(lauds: 0);
        break;
    }
    refreshUnreadMsg(type, timeStamp: unReadTimeStamp).then((value) {
      if(value!=null&&value){
        Application.unreadNoticeTimeStamp = null;
      }
      //然后获取新的未读数
      _getUnreadMsgCount();
    });
  }

  //获取系统通知状态
  _checkNotificationPermission() {
    return NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case PermissionStatus.denied:
          hasNotificationPermission = false;
          break;
        case PermissionStatus.granted:
          hasNotificationPermission = true;
          break;
        case PermissionStatus.unknown:
          hasNotificationPermission = false;
          break;
        case PermissionStatus.provisional:
          hasNotificationPermission = false;
          break;
        default:
          break;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  //获取网络连接状态
  _initConnectivity() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      isOffline = false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      isOffline = false;
    } else {
      isOffline = true;
    }
    if (mounted) {
      setState(() {});
    }
    connectivityListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        isOffline = false;
      } else {
        isOffline = true;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  //获取未读互动通知数
  _getUnreadMsgCount() async {
    await getUnReads();
  }

  @override
  void dispose() {
    super.dispose();
    connectivityListener?.cancel();
    //解绑监听
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("MessagePage_____________________________________________build");
    print("消息列表页build");
    super.build(context);
    _listLength =
        context.watch<ConversationNotifier>().topListLength + context.watch<ConversationNotifier>().commonListLength;
    return Scaffold(
      appBar: CustomAppBar(
        hasLeading: false,
        titleString: "消息${context.watch<RongCloudStatusNotifier>().statusString}",
        actions: [
          CustomAppBarTextButton("创建群聊", AppColor.textPrimary2, () {
            showCreateGroupPopup(context);
          }),
          // CustomAppBarIconButton(
          //     icon: Icons.group_add,
          //     iconColor: AppColor.black,
          //     onTap: () async {
          //       showCreateGroupPopup(context);
          //     }),
        ],
      ),
      backgroundColor: AppColor.white,
      body: ScrollConfiguration(
        behavior: NoBlueEffectBehavior(),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: _listLength + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildTopView(context.watch<UnreadMessageNotifier>());
            } else {
              //因为有上方头部视图 所以index要-1
              return _buildConversationItem(
                  index, context.watch<ConversationNotifier>().getConversationInAllList(index - 1));
            }
          },
        ),
      ),
    );
  }

  //消息列表上方的所有部分
  Widget _buildTopView(UnreadMessageNotifier notifier) {
    return Column(
      children: [_buildConnectionView(), _buildPermissionView(), _buildMentionView(notifier), _buildEmptyView()],
    );
  }

  Widget _buildConnectionView() {
    if (isOffline) {
      return GestureDetector(
        child: Container(
          height: 36,
          color: AppColor.mainRed.withOpacity(0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
              ),
              AppIcon.getAppIcon(
                AppIcon.error_circle,
                16,
                color: AppColor.mainRed,
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "网络连接已断开，请检查网络设置",
                style: TextStyle(fontSize: 14, color: AppColor.mainRed),
              ),
              Spacer(),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_16,
                16,
                color: AppColor.mainRed,
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
        ),
        onTap: () {
          AppRouter.navigateToNetworkLinkFailure(context: context);
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildMentionView(UnreadMessageNotifier notifier) {
    double size = _screenWidth / 3;
    return Container(
      height: size,
      child: Row(
        children: [
          _buildMentionItem(size, 0, notifier),
          _buildMentionItem(size, 1, notifier),
          _buildMentionItem(size, 2, notifier),
        ],
      ),
    );
  }

  //这里暂时不写枚举了 0评论 1@ 2点赞
  Widget _buildMentionItem(double size, int type, UnreadMessageNotifier notifier) {
    return Container(
      height: size,
      width: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              AppRouter.navigateToInteractivePage(context, type: type, callBack: (result) async {
                if(Application.unreadNoticeTimeStamp!=null){
                  _removeUnreadNotice(Application.unreadNoticeTimeStamp, type);
                }

              });
            },
            child: Stack(
              overflow: Overflow.visible,
              children: [
                AppIcon.getAppIcon(
                    type == 0
                        ? AppIcon.message_comment
                        : type == 1
                            ? AppIcon.message_at
                            : AppIcon.message_like,
                    45),
                Positioned(
                  left: 29.5,
                  child: CountBadge(
                      type == 0
                          ? notifier.comment
                          : type == 1
                              ? notifier.at
                              : notifier.laud,
                      false),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            type == 0
                ? "评论"
                : type == 1
                    ? "@我"
                    : "点赞",
            style: AppStyle.textRegular16,
          )
        ],
      ),
    );
  }

  Widget _buildPermissionView() {
    if (hasNotificationPermission) {
      return Container();
    } else {
      return GestureDetector(
        child: Container(
          height: 36,
          color: AppColor.orange.withOpacity(0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
              ),
              AppIcon.getAppIcon(
                AppIcon.error_circle,
                16,
                color: AppColor.orange,
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "开启系统通知，以免错过新消息",
                style: TextStyle(fontSize: 14, color: AppColor.orange),
              ),
              Spacer(),
              Text(
                "去开启",
                style: TextStyle(fontSize: 14, color: AppColor.orange),
              ),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_16,
                16,
                color: AppColor.orange,
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
        ),
        onTap: () {
          AppSettings.openNotificationSettings();
        },
      );
    }
  }

  Widget _buildEmptyView() {
    return _listLength > 0
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
              ),
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "这里空空如也，去推荐看看吧",
                style: AppStyle.textSecondaryRegular14,
              ),
              SizedBox(
                height: 28,
              ),
            ],
          );
  }

  Widget _buildConversationItem(int index, ConversationDto conversation) {
    if (conversation.type == PRIVATE_TYPE || conversation.type == GROUP_TYPE) {
      if (Application.platform == 0) {
        return GestureDetector(
          child: _conversationItem(index, conversation),
          onTap: () {
            getMessageType(conversation, context);
            jumpChatPageConversationDto(context, conversation);
          },
          onLongPress: () {
            showAppDialog(context,
                title: "删除消息",
                info: "确认删除这条对话消息吗？",
                barrierDismissible: false,
                cancel: AppDialogButton("取消", () {
                  print("点了取消");
                  return true;
                }),
                confirm: AppDialogButton("确定", () {
                  print("点击了确定");
                  MessageManager.removeConversation(
                      context, conversation.conversationId, conversation.uid, conversation.type);
                  Application.rongCloud.clearMessages(conversation.getType(), conversation.conversationId, null);
                  return true;
                }));
          },
        );
      } else {
        return LeftScrollListView(
          itemKey: conversation.id,
          itemTag: "conversation",
          itemIndex: index,
          isDoubleDelete: true,
          itemChild: _conversationItem(index, conversation, isIos: true),
          onTap: () {
            getMessageType(conversation, context);
            jumpChatPageConversationDto(context, conversation);
          },
          onClickRightBtn: (ind) {
            ConversationAnimationModel animationModel = ConversationAnimationModel();
            animationModel.index = ind;
            animationModel.conversationItemHeight = 0.0;
            streamController.sink.add(animationModel);
            new Future.delayed(Duration(milliseconds: 350), () {
              MessageManager.removeConversation(
                  context, conversation.conversationId, conversation.uid, conversation.type);
              Application.rongCloud.clearMessages(conversation.getType(), conversation.conversationId, null);
            });
          },
        );
      }
    } else {
      return GestureDetector(
        child: _conversationItem(index, conversation),
        onTap: () {
          getMessageType(conversation, context);
          jumpChatPageConversationDto(context, conversation);
        },
      );
    }
  }

  Widget _conversationItem(int index, ConversationDto conversation, {bool isIos = false}) {
    int messageCount = conversation.unreadCount;
    NoPromptUidModel model =
        NoPromptUidModel(type: conversation.type, targetId: int.parse(conversation.conversationId));
    if (NoPromptUidModel.contains(Application.queryNoPromptUidList, model)) {
      messageCount = 0;
    }
    //
    // MessageContent msgContent = MessageContent();
    // msgContent.decode(conversation.content);
    // //FIXME 是否有人at我 不能只看最新一条 要从map中查
    // bool isMentioned = msgContent.mentionedInfo != null &&
    //     msgContent.mentionedInfo.userIdList.contains(Application.profile.uid.toString());
    //

    bool isMentioned;
    AtMsg atMeMsg = Application.atMesGroupModel.getAtMsg(conversation.conversationId);
    if (atMeMsg == null) {
      isMentioned = false;
    } else {
      isMentioned = true;
    }
    List<String> avatarList = conversation.avatarUri.split(",");
    return isIos
        ? StreamBuilder<ConversationAnimationModel>(
            initialData: ConversationAnimationModel(),
            stream: streamController.stream,
            builder: (BuildContext stramContext, AsyncSnapshot<ConversationAnimationModel> snapshot) {
              return AnimatedContainer(
                height: index == snapshot.data.index ? snapshot.data.conversationItemHeight : 69,
                duration: const Duration(milliseconds: 250),
                curve: Curves.linear,
                child: Container(
                  height: index == snapshot.data.index ? snapshot.data.conversationItemHeight : 69,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  color: conversation.isTop == 1 ? AppColor.bgWhite : AppColor.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: index == snapshot.data.index ? snapshot.data.conversationItemHeight : 45,
                          width: 45,
                          child: conversation.type == OFFICIAL_TYPE ||
                                  conversation.type == LIVE_TYPE ||
                                  conversation.type == TRAINING_TYPE
                              ? _getOfficialAvatar(conversation.type)
                              : _getConversationAvatar(avatarList, conversation.isTop)),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: index == snapshot.data.index
                                        ? Container()
                                        : Text(
                                            StringUtil.strNoEmpty(conversation.name)
                                                ? conversation.name
                                                : conversation.conversationId,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            maxLines: 1,
                                            style: AppStyle.textRegular14,
                                          )),
                                index == snapshot.data.index
                                    ? Container()
                                    : Text(
                                        DateUtil.getShowMessageDateString(
                                            DateTime.fromMillisecondsSinceEpoch(conversation.updateTime)),
                                        style: AppStyle.textHintRegular12,
                                      )
                              ],
                            ),
                            Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isMentioned
                                    ? Text(
                                        "[有人@你]",
                                        style: AppStyle.redRegular13,
                                      )
                                    : Container(),
                                Expanded(
                                    child: index == snapshot.data.index
                                        ? Container()
                                        : Text(
                                            //FIXME 这个逻辑需要在群成员数据库写好后替换掉
                                            _getItemContent(conversation) ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            maxLines: 1,
                                            style: AppStyle.textSecondaryRegular13,
                                          )),
                                SizedBox(
                                  width: 12,
                                ),
                                index == snapshot.data.index ? Container() : CountBadge(messageCount, false),
                              ],
                            ),
                            SizedBox(
                              height: index == snapshot.data.index ? snapshot.data.conversationItemHeight : 12.5,
                            ),
                            Container(
                              height: 0.5,
                              color: AppColor.bgWhite,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
              //   AnimatedContainer(
              //   duration: const Duration(milliseconds: 500),
              //   curve: Curves.linear,
              //   height: snapshot.data,
              //   child: Container(
              //     height: snapshot.data,
              //   ),
              // );
            })
        : Container(
            height: 69,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: conversation.isTop == 1 ? AppColor.bgWhite : AppColor.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 45,
                    width: 45,
                    child: conversation.type == OFFICIAL_TYPE ||
                            conversation.type == LIVE_TYPE ||
                            conversation.type == TRAINING_TYPE
                        ? _getOfficialAvatar(conversation.type)
                        : _getConversationAvatar(avatarList, conversation.isTop)),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(
                            StringUtil.strNoEmpty(conversation.name) ? conversation.name : conversation.conversationId,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: AppStyle.textRegular14,
                          )),
                          Text(
                            DateUtil.getShowMessageDateString(
                                DateTime.fromMillisecondsSinceEpoch(conversation.updateTime)),
                            style: AppStyle.textHintRegular12,
                          )
                        ],
                      ),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isMentioned
                              ? Text(
                                  "[有人@你]",
                                  style: AppStyle.redRegular13,
                                )
                              : Container(),
                          Expanded(
                              child: Text(
                            //FIXME 这个逻辑需要在群成员数据库写好后替换掉
                            _getItemContent(conversation) ?? "",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: AppStyle.textSecondaryRegular13,
                          )),
                          SizedBox(
                            width: 12,
                          ),
                          CountBadge(messageCount, false),
                        ],
                      ),
                      SizedBox(
                        height: 12.5,
                      ),
                      Container(
                        height: 0.5,
                        color: AppColor.bgWhite,
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }

  String _getItemContent(ConversationDto conversation) {
    if (conversation.type == GROUP_TYPE &&
        conversation.senderUid != null &&
        conversation.senderUid != Application.profile.uid) {
      // print("用户id:${conversation.senderUid.toString()},群id:${conversation.conversationId}");
      return _getChatUserName(
              conversation.conversationId, conversation.senderUid.toString(), conversation.senderUid.toString()) +
          ":${conversation.content}";
    } else {
      return conversation.content;
    }
  }

  String _getChatUserName(String groupId, String uId, String name) {
    // print("${groupId}_$uId");
    // print(Application.chatGroupUserInformationMap);
    // print(Application.chatGroupUserInformationMap["${groupId}_$uId"].toString());
    // print(GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME);
    // print((Application.chatGroupUserInformationMap["${groupId}_$uId"]??Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    String userName = ((Application.chatGroupUserInformationMap["${groupId}_$uId"] ??
        Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    if (userName == null || userName.length < 1) {
      userName =
          (Application.chatGroupUserInformationMap["${groupId}_$uId"] ?? Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
    }
    if (userName == null) {
      return name;
    } else {
      return userName;
    }
  }

  Widget _getConversationAvatar(List<String> avatarList, int isTop) {
    print("avatarList:::${avatarList.length}");
    if (avatarList.length == 1) {
      return ClipOval(
        child: CachedNetworkImage(
          height: 45,
          width: 45,
          imageUrl: avatarList.first,
          fit: BoxFit.cover,
          memCacheWidth: 150,
          memCacheHeight: 150,

          /// imageUrl的淡入动画的持续时间。
          fadeInDuration: Duration(milliseconds: 0),
          placeholder: (context, url) => Container(
            color: AppColor.bgWhite,
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColor.bgWhite,
          ),
        ),
      );
    } else if (avatarList.length > 1) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: ClipOval(
              child: CachedNetworkImage(
                height: 28,
                width: 28,
                imageUrl: avatarList.first,
                fit: BoxFit.cover,
                memCacheWidth: 150,
                memCacheHeight: 150,

                /// imageUrl的淡入动画的持续时间。
                fadeInDuration: Duration(milliseconds: 0),
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //这里的边框颜色需要随背景变化
                  border: Border.all(width: 3, color: isTop == 1 ? AppColor.bgWhite : AppColor.white)),
              child: ClipOval(
                child: CachedNetworkImage(
                  height: 28,
                  width: 28,
                  imageUrl: avatarList[1],
                  fit: BoxFit.cover,
                  memCacheWidth: 150,
                  memCacheHeight: 150,

                  /// imageUrl的淡入动画的持续时间。
                  fadeInDuration: Duration(milliseconds: 0),
                  placeholder: (context, url) => Container(
                    color: AppColor.bgWhite,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColor.bgWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _getOfficialAvatar(int type) {
    return Stack(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: AppColor.textPrimary2,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppIcon.getAppIcon(
              type == OFFICIAL_TYPE
                  ? AppIcon.avatar_system
                  : type == LIVE_TYPE
                      ? AppIcon.avatar_live
                      : type == TRAINING_TYPE
                          ? AppIcon.avatar_training
                          : AppIcon.avatar_system,
              24),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            //NOTE flutter的奇葩问题，同样大小的shape叠放上面的无法完美覆盖下面，留一丝丝边，用自带的border也有这个问题，只好用嵌套方式里面的尺寸写小点。。。
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(color: AppColor.white, width: 1),
              ),
            ),
            height: 16,
            width: 16,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.textPrimary2,
                shape: BoxShape.circle,
              ),
              height: 15,
              width: 15,
              alignment: Alignment.center,
              child: AppIcon.getAppIcon(AppIcon.official, 10),
            ),
          ),
        ),
      ],
    );
  }
}

class ConversationAnimationModel {
  double conversationItemHeight = 69;
  int index;
}
