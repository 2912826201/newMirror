import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/data/notifier/unread_message_notifier.dart';
import 'package:mirror/generated/l10n.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/count_badge.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';
import 'package:mirror/page/popup/create_group_popup.dart';
import 'package:mirror/widget/size_transition_view.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:app_settings/app_settings.dart';
import 'util/message_chat_page_manager.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';

/// message_page
/// Created by yangjiayi on 2020/12/21.

class MessagePage extends StatefulWidget {
  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<MessagePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, TickerProviderStateMixin
{
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
  Map<int, AnimationController> animationMap = {};

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
    //????????????
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
    _initConnectivity();
    // ????????????tab???????????????
    // _getUnreadMsgCount();
  }

  _removeUnreadNotice(int unReadTimeStamp, int type) {
    print('------------------------??????');
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
      //???????????????????????????????????????
      if (value != null && value) {
        MessageManager.unreadNoticeTimeStamp = 0;
      }
      //???????????????????????????
      _getUnreadMsgCount();
    });
  }

  //????????????????????????
  _checkNotificationPermission() {
    return NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case PermissionStatus.granted:
          hasNotificationPermission = true;
          break;
        case PermissionStatus.denied:
        case PermissionStatus.unknown:
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

  //????????????????????????
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

  //???????????????????????????
  _getUnreadMsgCount() async {
    await getUnReads();
  }

  @override
  void dispose() {
    super.dispose();
    connectivityListener?.cancel();
    //????????????
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
    print("???????????????build");
    super.build(context);
    _listLength =
        context.watch<ConversationNotifier>().topListLength + context.watch<ConversationNotifier>().commonListLength;
    print("_listLength::::$_listLength");
    print(
        "context.watch<ConversationNotifier>().chatIdList:::::${context.watch<ConversationNotifier>().chatIdList.length}");
    print(" MessageManager.chatDataList::::${MessageManager.chatDataList.length}");

    context.watch<ConversationNotifier>().chatIdList.forEach((v) {
      print("${v}");
      print("${v.split("_")}");
      print("${v.split("_").last}");
      animationMap[int.parse(v.split("_").last)] =
          AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    });
    print("animationMap:::::${animationMap}");
    return Scaffold(
      appBar: CustomAppBar(
        hasDivider: false,
        hasLeading: false,
        titleString: "??????${context.watch<RongCloudStatusNotifier>().statusString}",
        actions: [
          CustomAppBarTextButton("????????????", AppColor.white, () {
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
      backgroundColor: AppColor.mainBlack,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildTopView(context.watch<UnreadMessageNotifier>()),
          ),
          // SliverFixedExtentList(
          //   delegate: SliverChildBuilderDelegate(
          //     (context, index) {
          //       return _buildConversationItem(
          //           index, context.watch<ConversationNotifier>().getConversationInAllList(index));
          //     },
          //     childCount: _listLength,
          //   ),
          //   itemExtent: 69,
          // ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildConversationItem(
                    index, context.watch<ConversationNotifier>().getConversationInAllList(index));
              },
              childCount: _listLength,
            ),
          )
        ],
      ),
    );
  }

  //?????????????????????????????????
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
                "?????????????????????????????????????????????",
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

  //??????????????????????????? 0?????? 1@ 2??????
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
                if (MessageManager.unreadNoticeTimeStamp > 0) {
                  _removeUnreadNotice(MessageManager.unreadNoticeTimeStamp, type);
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
                    45, color: AppColor.white),
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
                ? "${S.of(context).message_comment}"
                : type == 1
                    ? "${S.of(context).message_at}"
                    : "${S.of(context).message_like}",
            style: AppStyle.whiteRegular16,
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
          color: AppColor.mainYellow.withOpacity(0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
              ),
              AppIcon.getAppIcon(
                AppIcon.error_circle,
                16,
                color: AppColor.mainYellow,
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                "??????????????????????????????????????????",
                style: TextStyle(fontSize: 14, color: AppColor.mainYellow),
              ),
              Spacer(),
              Text(
                "?????????",
                style: TextStyle(fontSize: 14, color: AppColor.mainYellow),
              ),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_16,
                16,
                color: AppColor.mainYellow,
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
                "???????????????????????????????????????",
                style: AppStyle.text1Regular14,
              ),
              SizedBox(
                height: 28,
              ),
            ],
          );
  }

  Widget _buildConversationItem(int index, ConversationDto conversation) {
    if (conversation.type == PRIVATE_TYPE || conversation.type == GROUP_TYPE) {
      if (CheckPhoneSystemUtil.init().isAndroid()) {
        return SizeTransitionView(
            id: int.parse(conversation.conversationId),
            animationMap: animationMap,
            child: GestureDetector(
              child: _conversationItem(conversation),
              onTap: () {
                getMessageType(conversation, context);
                jumpChatPageConversationDto(context, conversation);
              },
              onLongPress: () {
                showAppDialog(context,
                    title: "????????????",
                    info: "????????????????????????????????????",
                    barrierDismissible: false,
                    cancel: AppDialogButton("??????", () {
                      print("????????????");
                      return true;
                    }),
                    confirm: AppDialogButton("??????", () {
                      print("???????????????");
                      // ????????????item
                      if (animationMap.containsKey(int.parse(conversation.conversationId))) {
                        animationMap[int.parse(conversation.conversationId)].forward().then((value) {
                          animationMap.remove(int.parse(conversation.conversationId));
                          MessageManager.removeConversation(
                              context, conversation.conversationId, conversation.uid, conversation.type);
                          Application.rongCloud
                              .clearMessages(conversation.getType(), conversation.conversationId, null);
                        });
                      }

                      return true;
                    }));
              },
            ));
      } else {
        return SizeTransitionView(
            id: int.parse(conversation.conversationId),
            animationMap: animationMap,
            child: LeftScrollListView(
              itemKey: conversation.id,
              itemTag: "conversation",
              itemIndex: index,
              isDoubleDelete: true,
              itemChild: _conversationItem(conversation, isIos: true),
              onTap: () {
                getMessageType(conversation, context);
                jumpChatPageConversationDto(context, conversation);
              },
              onClickRightBtn: (ind) {
                // ????????????item
                if (animationMap.containsKey(int.parse(conversation.conversationId))) {
                  animationMap[int.parse(conversation.conversationId)].forward().then((value) {
                    animationMap.remove(int.parse(conversation.conversationId));
                    MessageManager.removeConversation(
                        context, conversation.conversationId, conversation.uid, conversation.type);
                    Application.rongCloud.clearMessages(conversation.getType(), conversation.conversationId, null);
                  });
                }
              },
            ));
      }
    } else {
      return GestureDetector(
        child: _conversationItem(conversation),
        onTap: () {
          getMessageType(conversation, context);
          jumpChatPageConversationDto(context, conversation);
        },
      );
    }
  }

  Widget _conversationItem(ConversationDto conversation, {bool isIos = false}) {
    int messageCount = conversation.unreadCount;
    NoPromptUidModel model =
        NoPromptUidModel(type: conversation.type, targetId: int.parse(conversation.conversationId));
    if (NoPromptUidModel.contains(MessageManager.queryNoPromptUidList, model)) {
      messageCount = 0;
    }
    //
    // MessageContent msgContent = MessageContent();
    // msgContent.decode(conversation.content);
    // //FIXME ????????????at??? ???????????????????????? ??????map??????
    // bool isMentioned = msgContent.mentionedInfo != null &&
    //     msgContent.mentionedInfo.userIdList.contains(Application.profile.uid.toString());
    //

    bool isMentioned;
    AtMsg atMeMsg = MessageManager.atMesGroupModel.getAtMsg(conversation.conversationId);
    if (atMeMsg == null) {
      isMentioned = false;
    } else {
      isMentioned = true;
    }
    List<String> avatarList = conversation.avatarUri.split(",");
    return isIos
        ?
        // StreamBuilder<ConversationAnimationModel>(
        //         initialData: ConversationAnimationModel(),
        //         stream: streamController.stream,
        //         builder: (BuildContext stramContext, AsyncSnapshot<ConversationAnimationModel> snapshot) {
        //           return AnimatedContainer(
        //             height: index == snapshot.data.index ? snapshot.data.conversationItemHeight : 69,
        //             duration: const Duration(milliseconds: 250),
        //             curve: Curves.linear,
        //             child:
        Container(
            height:
                // index == snapshot.data.index ? snapshot.data.conversationItemHeight :
                69,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: conversation.isTop == 1 ? AppColor.layoutBgGrey : AppColor.mainBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height:
                        // index == snapshot.data.index ? snapshot.data.conversationItemHeight :
                        45,
                    width: 45,
                    child: conversation.type == OFFICIAL_TYPE ||
                            conversation.type == LIVE_TYPE ||
                            conversation.type == TRAINING_TYPE
                        ? _getOfficialAvatar(conversation.conversationId)
                        : _getConversationAvatar(avatarList, conversation.isTop, conversation.conversationId)),
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
                              child:
                                  // index == snapshot.data.index
                                  //     ? Container()
                                  //     :
                                  Text(
                            StringUtil.strNoEmpty(conversation.name) ? conversation.name : conversation.conversationId,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: AppStyle.whiteRegular14,
                          )),
                          // index == snapshot.data.index
                          //     ? Container()
                          //     :
                          Text(
                            DateUtil.getShowMessageDateString(
                                DateTime.fromMillisecondsSinceEpoch(conversation.updateTime)),
                            style: AppStyle.text2Regular12,
                          )
                        ],
                      ),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isMentioned
                              ? Text(
                                  "[??????@???]",
                                  style: AppStyle.redRegular13,
                                )
                              : Container(),
                          Expanded(
                              child:
                                  // index == snapshot.data.index
                                  //     ? Container()
                                  //     :
                                  Text(
                            //FIXME ?????????????????????????????????????????????????????????
                            _getItemContent(conversation) ?? "",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: AppStyle.text1Regular13,
                          )),
                          SizedBox(
                            width: 12,
                          ),
                          // index == snapshot.data.index ? Container() :
                          CountBadge(messageCount, false),
                        ],
                      ),
                      SizedBox(
                        height:
                            // index == snapshot.data.index ? snapshot.data.conversationItemHeight :
                            12.5,
                      ),
                      Container(
                        height: 0.5,
                        color: AppColor.dividerWhite8,
                      )
                    ],
                  ),
                )
              ],
            ),
            // ),
          )
        //   AnimatedContainer(
        //   duration: const Duration(milliseconds: 500),
        //   curve: Curves.linear,
        //   height: snapshot.data,
        //   child: Container(
        //     height: snapshot.data,
        //   ),
        // );
        // })
        : Container(
            height: 69,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: conversation.isTop == 1 ? AppColor.layoutBgGrey : AppColor.mainBlack,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 45,
                    width: 45,
                    child: conversation.type == OFFICIAL_TYPE ||
                            conversation.type == LIVE_TYPE ||
                            conversation.type == TRAINING_TYPE
                        ? _getOfficialAvatar(conversation.conversationId)
                        : _getConversationAvatar(avatarList, conversation.isTop, conversation.conversationId)),
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
                            style: AppStyle.whiteRegular14,
                          )),
                          Text(
                            DateUtil.getShowMessageDateString(
                                DateTime.fromMillisecondsSinceEpoch(conversation.updateTime)),
                            style: AppStyle.text2Regular12,
                          )
                        ],
                      ),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isMentioned
                              ? Text(
                                  "[??????@???]",
                                  style: AppStyle.redRegular13,
                                )
                              : Container(),
                          Expanded(
                              child: Text(
                            //FIXME ?????????????????????????????????????????????????????????
                            _getItemContent(conversation) ?? "",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: AppStyle.text1Regular13,
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
                        color: AppColor.dividerWhite8,
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
      // print("??????id:${conversation.senderUid.toString()},???id:${conversation.conversationId}");
      return _getChatUserName(
              conversation.conversationId, conversation.senderUid.toString(), conversation.senderUid.toString()) +
          ":${conversation.content}";
    } else {
      return conversation.content;
    }
  }

  String _getChatUserName(String groupId, String uId, String name) {
    // print("${groupId}_$uId");
    // print(MessageManager.chatGroupUserInformationMap);
    // print(MessageManager.chatGroupUserInformationMap["${groupId}_$uId"].toString());
    // print(GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME);
    // print((MessageManager.chatGroupUserInformationMap["${groupId}_$uId"]??Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    String userName = ((MessageManager.chatGroupUserInformationMap["${groupId}_$uId"] ??
        Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    if (userName == null || userName.length < 1) {
      userName = (MessageManager.chatGroupUserInformationMap["${groupId}_$uId"] ??
          Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
    }
    if (userName == null) {
      return name;
    } else {
      return userName;
    }
  }

  Widget _getConversationAvatar(List<String> avatarList, int isTop, String userId) {
    print("avatarList:::${avatarList.length}");
    if (avatarList.length == 1) {
      return UserAvatarImageUtil.init().getUserImageWidget(avatarList.first, userId, 45);
    } else if (avatarList.length > 1) {
      return UserAvatarImageUtil.init().getGroupImageWidget(avatarList, isTop, userId);
    } else {
      return Container();
    }
  }

  Widget _getOfficialAvatar(String userId) {
    return UserAvatarImageUtil.init().getUserImageWidget("", userId, 45);
  }
}

class ConversationAnimationModel {
  double conversationItemHeight = 69;
  int index;
}
