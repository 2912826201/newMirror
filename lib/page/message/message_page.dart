import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/message_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/data/notifier/unread_message_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/profile/Interactive_notification/interactive_notice_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/count_badge.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/create_group_popup.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:connectivity/connectivity.dart';
import 'package:app_settings/app_settings.dart';
import 'message_chat_page_manager.dart';

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
    Unreads model = await getUnReads();
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
          CustomAppBarIconButton(
              icon: Icons.group_add,
              iconColor: AppColor.black,
              onTap: () async {
                showCreateGroupPopup(context);
              }),
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
      children: [_buildConnectionView(), _buildMentionView(notifier), _buildPermissionView(), _buildEmptyView()],
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
              Icon(
                Icons.error_outline,
                size: 16,
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
              Icon(
                Icons.chevron_right,
                size: 16,
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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return InteractiveNoticePage(
                  type: type,
                );
              })).then((result) async {
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
                //用时间戳清空之前的未读数
                int timeStamp = result as int;
                await refreshUnreadMsg(type, timeStamp: timeStamp);
                //然后获取新的未读数
                _getUnreadMsgCount();
              });
            },
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  color: AppColor.mainBlue,
                ),
                Positioned(
                    left: 6.5,
                    top: 6.5,
                    child: Container(
                      height: 32,
                      width: 32,
                      color: AppColor.bgBlack,
                    )),
                Positioned(
                    left: 29.5,
                    child: CountBadge(
                        type == 0
                            ? notifier.comment
                            : type == 1
                                ? notifier.at
                                : notifier.laud,
                        false)),
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
        onTap: () {
          AppSettings.openNotificationSettings();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            color: AppColor.mainBlue,
            height: 56,
          ),
        ),
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
                color: AppColor.mainBlue,
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
      return LeftScrollListView(
        itemKey: conversation.id,
        itemTag: "conversation",
        itemIndex: index,
        isDoubleDelete:true,
        itemChild: _conversationItem(index, conversation),
        onTap: (){
          getMessageType(conversation, context);
          jumpChatPageConversationDto(context, conversation);
        },
        onClickRightBtn: () {
          MessageManager.removeConversation(context, conversation.conversationId, conversation.uid, conversation.type);
        },
      );
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

  Widget _conversationItem(int index, ConversationDto conversation) {
    MessageContent msgContent = MessageContent();
    msgContent.decode(conversation.content);
    //FIXME 是否有人at我 不能只看最新一条 要从map中查
    bool isMentioned = msgContent.mentionedInfo != null &&
        msgContent.mentionedInfo.userIdList.contains(Application.profile.uid.toString());
    List<String> avatarList = conversation.avatarUri.split(",");
    return Container(
      height: 69,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: conversation.isTop == 1 ? AppColor.textHint : AppColor.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            child: Stack(
              children: [
                avatarList.length == 1
                    ? ClipOval(
                        child: CachedNetworkImage(
                          height: 45,
                          width: 45,
                          imageUrl: avatarList.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            "images/test.png",
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "images/test.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : avatarList.length > 1
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                height: 28,
                                width: 28,
                                imageUrl: avatarList.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset(
                                  "images/test.png",
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  "images/test.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                        : Container(),
                avatarList.length > 1
                    ? Positioned(
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              //这里的边框颜色需要随背景变化
                              border: Border.all(
                                  width: 3, color: conversation.isTop == 1 ? AppColor.textHint : AppColor.white)),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              height: 28,
                              width: 28,
                              imageUrl: avatarList[1],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.asset(
                                "images/test.png",
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "images/test.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                conversation.type == OFFICIAL_TYPE ||
                        conversation.type == LIVE_TYPE ||
                        conversation.type == TRAINING_TYPE
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 16,
                          width: 16,
                          color: AppColor.bgBlack,
                        ))
                    : Container()
              ],
            ),
          ),
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
                      style: AppStyle.textRegular14,
                    )),
                    Text(
                      DateUtil.getShowMessageDateString(DateTime.fromMillisecondsSinceEpoch(conversation.updateTime)),
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
                      "${conversation.content}",
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppStyle.textSecondaryRegular13,
                    )),
                    SizedBox(
                      width: 12,
                    ),
                    //TODO 免打扰需要处理
                    CountBadge(conversation.unreadCount, false),
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
}
