import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_settings/app_settings.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/page/activity/util/activity_util.dart';
import 'package:mirror/page/popup/show_group_popup.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/widget/ScaffoldChatPage.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Scaffold;
import 'package:flutter/services.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_enter_notifier.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/page/message/util/chat_message_profile_util.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/widget/chat_bottom_Setting_box.dart';
import 'package:mirror/widget/loading.dart';
import 'util/chat_page_util.dart';
import 'util/message_chat_page_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/interactiveviewer/interactiveviewer_gallery.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:video_thumbnail/video_thumbnail.dart';
import 'chat_details_body.dart';
import 'widget/chat_at_user_name_list.dart';
import 'widget/chat_more_icon.dart';
import 'widget/message_body_input.dart';
import 'widget/message_input_bar.dart';
import 'package:provider/provider.dart';
import 'package:mirror/widget/state_build_keyboard.dart';

import 'util/message_item_gallery_util.dart';
import 'util/message_item_height_util.dart';

////////////////////////////////
//
/////////////聊天会话页面
//
///////////////////////////////

class ChatPage extends StatefulWidget {
  final ConversationDto conversation;
  final Message shareMessage;
  final BuildContext context;
  final List<ChatDataModel> chatDataList;
  final int systemPage;
  final String systemLastTime;
  final String textContent;

  ChatPage(
      {Key key,
      @required this.conversation,
      this.shareMessage,
      this.chatDataList,
      this.textContent,
      this.systemLastTime,
      this.systemPage,
      this.context})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    List<ChatDataModel> chatDataList = [];
    chatDataList.addAll(this.chatDataList);
    return ChatPageState(
      conversation,
      shareMessage,
      context,
      systemLastTime,
      systemPage,
      chatDataList,
        textContent);
  }
}

class ChatPageState extends StateKeyboard with  WidgetsBindingObserver {
  final ConversationDto conversation;
  final Message shareMessage;
  final BuildContext _context;

  //所有的会话消息
  final List<ChatDataModel> chatDataList;
  final List<ChatDataModel> addChatDataList = [];

  String systemLastTime;
  String textContent;
  int systemPage = 0;
  bool isAddUnreadCountAlertMsg = false;

  ChatPageState(
    this.conversation,
    this.shareMessage,
    this._context,
    this.systemLastTime,
    this.systemPage,
    this.chatDataList,
    this.textContent,
  );

  //新消息大于多少个数量展示未读消息
  final int newMsgCountThanShow = 20;

  //是否显示表情
  bool _emojiState = false;
  bool _emojiStateOld = false;
  bool _bottomSettingPanelState = false;

  //是不是显示语音按钮
  bool _isVoiceState = false;

  //输入框的监听
  TextEditingController _textController = TextEditingController();

  //输入框的焦点
  FocusNode _focusNode = new FocusNode();

  //列表的滑动监听
  // ScrollController _scrollController = ScrollController();
  AutoScrollController _scrollController;

  // 是否点击了弹起的@用户列表
  bool isClickAtUser = false;

  // 判断是否只是切换光标
  bool isSwitchCursor = true;
  ReleaseFeedInputFormatter _formatter;

  //at用户的信息
  MentionedInfo mentionedInfo = new MentionedInfo();
  List<String> atUserIdList = <String>[];

  //有没有at我的消息
  bool isHaveAtMeMsg = false;
  bool isHaveAtMeMsgPr = false;

  int lastIndex = 0;

  //at我的消息的信息
  AtMsg atMeMsg;

  //进入聊天界面时，at的消息在列表的第几个位置
  int isHaveAtMeMsgIndex = -1;

  //上一次的最大高度
  double oldMaxScrollExtent = 0;

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  //重新编辑消息的位置
  int recallNotificationMessagePosition = -1;

  //是否可以显示头部关注box
  bool isShowTopAttentionUi = false;

  double scrollPositionPixels = 0;

  int userNumber = 0;

  int cursorIndexPr = -1;

  ScrollController textScrollController = ScrollController();

  // 大图预览组装数据
  List<DemoSourceEntity> sourceList = [];
  bool isNewSourceList=true;

  Widget topAttentionUiWidget;

  GlobalKey<ChatBottomSettingBoxState> bottomSettingChildKey = GlobalKey();
  GlobalKey<MessageInputBarState> messageInputBarChildKey = GlobalKey();
  GlobalKey<ChatDetailsBodyState> chatDetailsBodyChildKey = GlobalKey();

  StreamController<int> streamEditWidget = StreamController<int>();

  bool readOnly = false;

  String urlMd5StringVideo = "";
  String filePathMd5Video = "";

  bool isnRefreshSystemInformationIng = false;
  bool isAnimateToTopIng = false;
  int isAnimateToTopIngCount = 0;

  //是否置顶群聊
  bool topChat = false;

  //免打扰
  bool disturbTheNews = false;

  @override
  void initState() {
    super.initState();
    //print("ChatPage-initState");

    print("chatId:${conversation.conversationId}");

    WidgetsBinding.instance.addObserver(this);

    //设置这个群聊
    ChatMessageProfileUtil.init().setData(conversation, isSetUnreadCount: true);

    if (conversation.getType() == RCConversationType.Group) {
      //刷新appbar
      EventBus.init().registerNoParameter(_resetCharPageBar, EVENTBUS_CHAT_PAGE, registerName: EVENTBUS_CHAT_BAR);
      //判断是否退出群聊或者加入群聊
      EventBus.init().registerSingleParameter(_judgeResetPage, EVENTBUS_CHAT_PAGE, registerName: CHAT_JOIN_EXIT);
      //刷新群聊的群成员
      EventBus.init().registerSingleParameter(_resetChatGroupUserModelList, EVENTBUS_CHAT_PAGE,
          registerName: RESET_CHAR_GROUP_USER_LIST);
    }
    //发送消息的状态广播
    EventBus.init().registerSingleParameter(resetMsgStatus, EVENTBUS_CHAT_PAGE, registerName: RESET_MSG_STATUS);
    //接收消息的广播
    EventBus.init().registerSingleParameter(getReceiveMessages, EVENTBUS_CHAT_PAGE, registerName: CHAT_GET_MSG);
    //撤回消息的广播
    EventBus.init().registerSingleParameter(withdrawMessage, EVENTBUS_CHAT_PAGE, registerName: CHAT_WITHDRAW_MSG);
    if (conversation.getType() != RCConversationType.System) {
      initSetData();
      initTextController();
      initReleaseFeedInputFormatter();
    }
    initWidget();

    initScrollController();

    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);

    //自动发送消息
    _sendMessageAutomatically();

    _getConversationNotificationStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //print("conversation.getType(), conversation.conversationId:${conversation.getType()},${conversation.conversationId}");
    isNewSourceList = true;
    sourceList.clear();
    ChatMessageProfileUtil.init().setData(conversation);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ChatPageUtil.init(context).getAppBar(conversation, _topMoreBtnClick),
      handleStatusBarTap: _animateToIndex,
      body: MessageInputBody(
        onTap: () => _messageInputBodyClick(),
        decoration: BoxDecoration(color: AppColor.mainBlack),
        child: Column(children: [
          //关注条
          topAttentionUiWidget,
          //消息内容
          Expanded(
            child: SizedBox(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //消息内容
                  getChatDetailsBody(),
                  //是否消失@列表
                  (conversation.type != GROUP_TYPE)
                      ? Container()
                      : ChatAtUserList(
                    isShow: context.watch<ChatEnterNotifier>().keyWord == "@",
                    onItemClickListener: atListItemClick,
                    groupChatId: conversation.conversationId,
                  ),
                ],
              ),
            ),
          ),
          //消息输入框
          if (conversation.getType() != RCConversationType.System) getMessageInputBar(),
          //底部表情面板
          if (conversation.getType() != RCConversationType.System)
            ChatBottomSettingBox(
              key: bottomSettingChildKey,
              focusNode: _focusNode,
              bottomSettingPanelState: _bottomSettingPanelState,
              emojiState: _emojiState,
              textController: _textController,
              callBackCursorIndexPr: (int cursorIndexPr) {
                this.cursorIndexPr = cursorIndexPr;
                _changTextLen(_textController.text);
              },
              changTextLen: _changTextLen,
              deleteEditText: _deleteEditText,
              onSubmitClick: _onSubmitClick,
              textScrollController: textScrollController,
            ),
        ]),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    deletePostCompleteMessage(conversation);
    _messageInputBodyClick();
    _scrollController.dispose();
    streamEditWidget.close();
    ChatMessageProfileUtil.init().clear();
    if (atMeMsg != null) {
      MessageManager.atMesGroupModel.remove(atMeMsg);
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
    }
    if (conversation.getType() == RCConversationType.Group) {
      Application.appContext.read<GroupUserProfileNotifier>().clearAllUser();
      EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: EVENTBUS_CHAT_BAR);
      EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_JOIN_EXIT);
    }
    EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: RESET_MSG_STATUS);
    EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_GET_MSG);
    EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_WITHDRAW_MSG);
    context.read<VoiceSettingNotifier>().stop();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    //print("didChangeAppLifecycleState:$state");
    if (state == AppLifecycleState.paused) {
      _messageInputBodyClick();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  ///----------------------------------------ui start---------------------------------------------///

  //获取列表内容
  Widget getChatDetailsBody() {
    bool isShowName = conversation.getType() == RCConversationType.Group;
    bool isPersonalButler = false;
    //todo 单独展示底部选着面板的id-1002885-1008051
    if (conversation.type == PRIVATE_TYPE && conversation.uid == coachAccountId) {
      isPersonalButler = true;
    }

    if (isHaveAtMeMsg) {
      ChatMessageProfileUtil.unreadCount = 0;
      ChatMessageProfileUtil.unreadCountNew = 0;
    }
    // print("getChatDetailsBody:${chatDataList.length}");

    return ChatDetailsBody(
      key: chatDetailsBodyChildKey,
      scrollController: _scrollController,
      chatDataList: chatDataList,
      chatId: conversation.conversationId,
      onTap: _messageInputBodyClick,
      voidItemLongClickCallBack: onItemLongClickCallBack,
      voidMessageClickCallBack: onMessageClickCallBack,
      chatName: getChatName(),
      conversationDtoType: conversation.type,
      isPersonalButler: isPersonalButler,
      isHaveAtMeMsg: isHaveAtMeMsg,
      loadStatus: loadStatus,
      newMsgCount: ChatMessageProfileUtil.unreadCount >= newMsgCountThanShow ? ChatMessageProfileUtil.unreadCount : 0,
      isShowChatUserName: isShowName,
      onAtUiClickListener: onAtUiClickListener,
      onNewMsgClickListener: onNewMsgClickListener,
      firstEndCallback: firstEndCallbackListView,
      setCallRemoveLongPanel: _setCallRemoveLongPanel,
      setHaveAtMeMsg: _setHaveAtMeMsg,
      setNewMsgCount: _setUnreadCountCall,
    );
  }

  //输入框bar
  Widget getMessageInputBar() {
    return StreamBuilder(
      stream: streamEditWidget.stream,
      builder: (context, snapshot) {
        return MessageInputBar(
          key: messageInputBarChildKey,
          voiceOnTap: _voiceOnTapClick,
          onEmojio: () {
            onEmojioClick();
          },
          isVoice: _isVoiceState,
          isEmojio: _emojiState,
          voiceFile: _voiceFile,
          edit: _editWidget(),
          value: _textController.text,
          more: ChatMoreIcon(
            isComMomButton: StringUtil.strNoEmpty(_textController.text) && CheckPhoneSystemUtil.init().isAndroid(),
            onTap: () {
              _onSubmitClick();
            },
            moreTap: () => onPicAndVideoBtnClick(),
            textController: _textController,
          ),
          id: null,
          type: null,
        );
      },
    );
  }

  //输入框bar内的edit
  Widget _editWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      constraints: BoxConstraints(
        maxHeight: 80.0,
        minHeight: 16.0,
      ),
      child: TextSpanField(
        onTap: textSpanFieldClickListener,
        onLongTap: textSpanFieldClickListener,
        scrollController: textScrollController,
        controller: _textController,
        focusNode: _focusNode,
        // 多行展示
        keyboardType: TextInputType.multiline,
        //不限制行数
        maxLines: null,
        enableInteractiveSelection: true,
        // 光标颜色
        cursorColor: AppColor.textWhite60,
        scrollPadding: EdgeInsets.all(0),
        style: AppStyle.whiteRegular14,
        //内容改变的回调
        onChanged: _changTextLen,
        textInputAction: TextInputAction.send,
        readOnly: readOnly,
        showCursor: true,
        onSubmitted: (text) {
          if (ClickUtil.isFastClick(time: 200)) {
            return;
          }
          if (text.isNotEmpty) {
            _postText(text);
          }
          //print("重新获取焦点");
          // 重新获取焦点 避免键盘收回
          FocusScope.of(context).requestFocus(_focusNode);
        },
        // 装饰器修改外观
        decoration: InputDecoration(
          // 去除下滑线
          border: InputBorder.none,
          // 提示文本
          hintText: "说点什么吧...",
          // 提示文本样式
          hintStyle: AppStyle.text1Regular14,
          // 设置为true,contentPadding才会生效，TextField会有默认高度。
          isCollapsed: true,
          contentPadding: EdgeInsets.only(left: 16, right: 16),
        ),

        rangeStyles: getTextFieldStyle(Application.appContext.read<ChatEnterNotifier>().rules),
        inputFormatters: [_formatter],
      ),
    );
  }

  ///------------------------------------ui end--------------------------------------------------------------------------------///
  ///------------------------------------数据初始化和各种回调   start--------------------------------------------------------------------------------///

// 监听返回
  Future<bool> _requestPop() {
    bool b = false;
    if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0) {
      b = false;
      _messageInputBodyClick();
    } else {
      b = true;
    }
    return new Future.value(b);
  }

  //当改变了输入框内的文字个数
  _changTextLen(String text) {
    // 存入最新的值
    _removeLongPanelCall();
    context.read<ChatEnterNotifier>().changeCallback(text);
    EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
  }

  String getChatName() {
    if (conversation.name == null || conversation.name.trim().length < 1) {
      return conversation.conversationId;
    } else {
      return conversation.name;
    }
  }

  //初始化一些数据
  void initSetData() async {
    //获取有没有at我的消息
    judgeIsHaveAtMeMsg();

    //判断有没有显示关注按钮
    getRelation();

    //判断第一次是否加载历史记录
    _isInitAddRemoteHistoryMessages();
  }

  //查询我是不是关注了对方
  Future<void> getRelation() async {
    if (conversation.type != PRIVATE_TYPE) {
      isShowTopAttentionUi = false;
    } else {
      Map<String, dynamic> map = await relation(Application.profile.uid, int.parse(conversation.conversationId));
      if (map == null || map["relation"] == null || map["relation"] == 1 || map["relation"] == 3) {
        isShowTopAttentionUi = false;
      } else {
        isShowTopAttentionUi = true;
      }
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _resetShowTopAttentionUi();
        }
      });
    }
  }

  //获取系统通知
  Future<List<ChatDataModel>> getSystemInformationNet() async {
    List<ChatDataModel> dataList = <ChatDataModel>[];
    Map<String, dynamic> dataListMap =
        await querySysMsgList(type: conversation.type, size: chatAddHistoryMessageCount, lastTime: systemLastTime);
    try {
      systemLastTime = dataListMap["lastTime"].toString();
    } catch (e) {}
    if (dataListMap != null && dataListMap["list"] != null) {
      systemPage++;
      dataListMap["list"].forEach((v) {
        ChatSystemMessageModel model = ChatSystemMessageModel.fromJson(v);
        dataList.add(getMessage(getSystemMsg(model, conversation.type), isHaveAnimation: false));
      });
    }
    return dataList;
  }

  //判断加不加时间提示
  ChatDataModel judgeAddAlertTime(ChatDataModel model) {
    if (model == null) {
      return getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch, conversation.conversationId);
    } else if (model.msg != null && new DateTime.now().millisecondsSinceEpoch - model.msg.sentTime >= 5 * 60 * 1000) {
      return getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch, conversation.conversationId);
    }
    return null;
  }

  //判断有没有at我的消息
  void judgeIsHaveAtMeMsg() {
    //print("判断有没有at我的消息");
    if (MessageManager.atMesGroupModel == null || MessageManager.atMesGroupModel.atMsgMap == null) {
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
    } else {
      atMeMsg = MessageManager.atMesGroupModel.getAtMsg(conversation.conversationId);
      if (atMeMsg == null) {
        isHaveAtMeMsg = false;
        isHaveAtMeMsgPr = false;
      } else {
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        setHaveAtMeMsg(isHaveAtMeMsg);
        judgeNowChatIsHaveAt();
      }
    }
  }

  //判断当前屏幕内有没有at我的消息
  void judgeNowChatIsHaveAt() {
    isHaveAtMeMsgIndex = -1;
    if (chatDataList == null || chatDataList.length < 1) {
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
      MessageManager.atMesGroupModel.remove(atMeMsg);
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
    } else {
      for (int i = 0; i < chatDataList.length; i++) {
        if (chatDataList[i].msg.messageUId == atMeMsg.messageUId) {
          //print("能找到id");
          isHaveAtMeMsgIndex = i;

          List<ChatDataModel> dataList=[];
          for (int j = 0; j <= i; j++) {
            dataList.add(chatDataList[j]);
          }
          bool isShowName = conversation.getType() == RCConversationType.Group;
          bool isThanChatScreenHeight = MessageItemHeightUtil.init()
              .judgeMessageItemHeightIsThenScreenHeight(dataList, isShowName);
          if(!isThanChatScreenHeight){
            //print("当前消息在屏幕中间-消除at");
            isHaveAtMeMsg = false;
            isHaveAtMeMsgPr = false;
            MessageManager.atMesGroupModel.remove(atMeMsg);
            ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
          }
          break;
        } else if (chatDataList[i].msg.sentTime < atMeMsg.sendTime) {
          //print("找不到id--匹配时间");
          isHaveAtMeMsg = false;
          isHaveAtMeMsgPr = false;
          MessageManager.atMesGroupModel.remove(atMeMsg);
          ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
          break;
        }
      }
    }

    setHaveAtMeMsg(isHaveAtMeMsg);
  }

  //listview 当前显示的是第几个 回调
  void firstEndCallbackListView(int firstIndex, int lastIndex) {
    this.lastIndex = lastIndex;
    // print("firstIndex:$firstIndex,lastIndex:$lastIndex");
    //print("isHaveAtMeMsgPr:$isHaveAtMeMsgPr,isHaveAtMeMsg:$isHaveAtMeMsg,isHaveAtMeMsgIndex:$isHaveAtMeMsgIndex,");
    if (ClickUtil.isFastClickFirstEndCallbackListView(time: 200)) {
      return;
    }
    //检查滑动中有没有at的消息
    checkIsHaveAtMsg();

    checkArrivalsNewMsgPosition();
  }

  //检查是否到达新消息的位置
  void checkArrivalsNewMsgPosition() {
    //当未读数大于0时
    if (ChatMessageProfileUtil.unreadCountNew > 0 && ChatMessageProfileUtil.unreadCount > 0) {
      if (ChatMessageProfileUtil.unreadCountNew < lastIndex) {
        ChatMessageProfileUtil.unreadCount = 0;
        ChatMessageProfileUtil.unreadCountNew = 0;
        setUnreadCount(ChatMessageProfileUtil.unreadCount);
        print("unreadCount:$ChatMessageProfileUtil.unreadCount,lastIndex:$lastIndex");
        return;
      }
    }
  }

  //检查滑动中有没有at的消息
  void checkIsHaveAtMsg() {
    if (isHaveAtMeMsgPr) {
      if (isHaveAtMeMsgIndex < 0) {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        setHaveAtMeMsg(isHaveAtMeMsg);
      } else if (isHaveAtMeMsgIndex <= lastIndex) {
        if (isHaveAtMeMsg) {
          isHaveAtMeMsg = false;
          ////print('2--------------------------关闭标识at');
        }
        ////print('2--------------------------已经是关闭--关闭标识at');
        isHaveAtMeMsgPr = false;
        isHaveAtMeMsgIndex = -1;
        MessageManager.atMesGroupModel.remove(atMeMsg);
        setHaveAtMeMsg(isHaveAtMeMsg);
        ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
      } else {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
          ////print('3--------------------------显示标识at');
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        setHaveAtMeMsg(isHaveAtMeMsg);
      }
    }
  }

  //at标识符号的点击事件
  void onAtUiClickListener() async {
    print("isHaveAtMeMsg:$isHaveAtMeMsg,isHaveAtMeMsgIndex:$isHaveAtMeMsgIndex,");
    if (isHaveAtMeMsgIndex < 0) {
      while (isHaveAtMeMsg && isHaveAtMeMsgIndex < 0) {
        //print("chatDataList.len:${chatDataList.length}");
        List msgList = new List();
        msgList = await RongCloud.init().getHistoryMessages(conversation.getType(), conversation.conversationId,
            chatDataList[chatDataList.length - 1].msg.sentTime, chatAddHistoryMessageCount, 0);
        List<ChatDataModel> dataList = <ChatDataModel>[];
        if (msgList != null && msgList.length > 0) {
          for (int i = 1; i < msgList.length; i++) {
            dataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
          }

          if (dataList != null && dataList.length > 0) {
            ChatPageUtil.init(context).setTimeAlert(dataList, conversation.conversationId);
            //print("value:${chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime}-----------");
            if (chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime < 5 * 60 * 1000) {
              chatDataList.removeAt(chatDataList.length - 1);
            }
            chatDataList.addAll(dataList);
          }

          judgeNowChatIsHaveAt();
        } else {
          isHaveAtMeMsgIndex = -1;
          isHaveAtMeMsg = false;
          isHaveAtMeMsgPr = false;
          MessageManager.atMesGroupModel.remove(atMeMsg);
          setHaveAtMeMsg(isHaveAtMeMsg);
          ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
          return;
        }
        if (isHaveAtMeMsgIndex > 0) {
          break;
        }
      }
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      await Future.delayed(Duration(milliseconds: 100), () {});
    }

    if (!isHaveAtMeMsg) {
      setHaveAtMeMsg(isHaveAtMeMsg);
      return;
    }

    print("isHaveAtMeMsg:$isHaveAtMeMsg,isHaveAtMeMsgIndex:$isHaveAtMeMsgIndex,");
    _animateToIndex(index: isHaveAtMeMsgIndex);

    int indexAtMsg = isHaveAtMeMsgIndex;
    Future.delayed(Duration(milliseconds: 300), () {
      chatDetailsBodyChildKey.currentState.setAtItemMessagePosition(indexAtMsg);
      isHaveAtMeMsgIndex = -1;
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
      MessageManager.atMesGroupModel.remove(atMeMsg);
      setHaveAtMeMsg(isHaveAtMeMsg);
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
    });
  }

  //点击了有新消息的标识
  void onNewMsgClickListener() {
    if (ChatMessageProfileUtil.unreadCountNew < chatDataList.length) {
      _animateToIndex(index: ChatMessageProfileUtil.unreadCountNew);
    } else {
      ChatPageUtil.init(context).onLoadMoreHistoryMessages(
        chatDataList, conversation,
        (bool isHaveMore) {
          if (isHaveMore) {
            loadStatus = LoadingStatus.STATUS_IDEL;
          } else {
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
          chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
          judgeIsAddUnreadCountAlertMsg();
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          Future.delayed(Duration(milliseconds: 300), () {
            print("开始滚动，列表内有：${chatDataList.length}");
            _animateToIndex();
          });
        },
        loadMsgCount: ChatMessageProfileUtil.unreadCountNew - chatDataList.length + 2,
        // }, loadMsgCount: newMsgCountThanShow,
      );
    }
  }

  //刷新appbar
  void _resetCharPageBar() {
    if (mounted) {
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
  }

  //刷新关注条
  void _resetShowTopAttentionUi() {
    Element e = findChild(context as Element, topAttentionUiWidget);
    if (e != null) {
      topAttentionUiWidget = ChatPageUtil.init(context)
          .getTopAttentionUi(isShowTopAttentionUi, conversation.type, _attntionOnClick, (bool isShow) {
        isShowTopAttentionUi = isShow;
        _resetShowTopAttentionUi();
      });
      e.owner.lockState(() {
        e.update(topAttentionUiWidget);
      });
    }
  }

  Element findChild(Element e, Widget w) {
    Element child;
    void visit(Element element) {
      if (w == element.widget)
        child = element;
      else
        element.visitChildren(visit);
    }

    visit(e);
    return child;
  }

  ///------------------------------------数据初始化和各种回调   end--------------------------------------------------------------------------------///

  ///------------------------------------发送消息  start-----------------------------------------------------------------------///

  //自动发送消息
  _sendMessageAutomatically() {
    Future.delayed(Duration(seconds: 1), () {
      if (conversation.type == PRIVATE_TYPE && textContent != null && textContent.length > 0) {
        _attntionOnClick();
        _postText(textContent);
        textContent = null;
      }
    });
  }

  //发送文字消息
  _postText(String text) {
    if (text == null || text.length < 1) {
      ToastShow.show(msg: "消息为空,请输入消息！", context: _context);
      return;
    }

    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_TEXT;
    chatDataModel.content = text;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = true;
    chatDataModel.id="${conversation.id}_${DateTime.now().microsecondsSinceEpoch}_${chatDataList.length}";
    chatDataModel.conversationId=conversation.id;
    mentionedInfo.type = RCMentionedType.Users;
    atUserIdList.clear();
    // 获取输入框内的规则
    var rules = context.read<ChatEnterNotifier>().rules;
    for (int i = 0; i < rules.length; i++) {
      if (!atUserIdList.contains(rules[i].clickIndex.toString())) {
        atUserIdList.add(rules[i].clickIndex.toString());
      }
    }
    mentionedInfo.userIdList = atUserIdList;
    mentionedInfo.mentionedContent =
        gteAtUserName(atUserIdList, context.read<GroupUserProfileNotifier>().chatGroupUserModelList);
    chatDataModel.mentionedInfo = mentionedInfo;

    if (addChatDataList.length > 0) {
      for (var model in addChatDataList) {
        chatDataList.insert(0, model);
      }
      addChatDataList.clear();
    }

    ChatDataModel time = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
    if (time != null) {
      chatDataList.insert(0, time);
    }
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    _animateToIndex(index: 0);

    //print("recallNotificationMessagePosition:$recallNotificationMessagePosition");
    if (recallNotificationMessagePosition >= 0) {
      _updateRecallNotificationMessage();
    } else {
      if (mounted) {
        _textController.text = "";
        bottomSettingChildKey.currentState.setCursorIndexPr(0);
        _changTextLen("");
        context.read<ChatEnterNotifier>().clearRules();
        if (chatDataList.length > 100) {
          List<ChatDataModel> list = [];
          list = chatDataList.sublist(0, 100);
          chatDataList.clear();
          chatDataList.addAll(list);
        }
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
      }
    }

    //未读消息的跳转数目加1
    if (ChatMessageProfileUtil.unreadCountNew > 0) {
      ChatMessageProfileUtil.unreadCountNew++;
    }

    //print("chatDataList[0]:${chatDataList[0]}");
    postText(chatDataList[0], conversation.conversationId, conversation.getType(), mentionedInfo, () {
      context.read<ChatEnterNotifier>().clearRules();
      _textController.text = "";
      bottomSettingChildKey.currentState.setCursorIndexPr(0);
      _changTextLen("");
      // List list=[];
      // list.add(0);
      // list.add(chatDataModel.id);
      // EventBus.getDefault().post(msg:list,registerName: CHAT_EVERY_MESSAGE);
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  //发送视频以及图片
  _handPicOrVideo(SelectedMediaFiles selectedMediaFiles) async {
    List<ChatDataModel> modelList = <ChatDataModel>[];
    for (int i = 0; i < selectedMediaFiles.list.length; i++) {
      if (selectedMediaFiles.list[i].croppedImage != null) {
        //print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        ByteData byteData = await selectedMediaFiles.list[i].croppedImage.toByteData(format: ui.ImageByteFormat.png);
        //print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        Uint8List picBytes = byteData.buffer.asUint8List();
        //print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
        selectedMediaFiles.list[i].croppedImageData = picBytes;
      }
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.type = (selectedMediaFiles.type == mediaTypeKeyVideo
          ? ChatTypeModel.MESSAGE_TYPE_VIDEO
          : ChatTypeModel.MESSAGE_TYPE_IMAGE);
      chatDataModel.mediaFileModel = selectedMediaFiles.list[i];
      chatDataModel.isTemporary = true;
      chatDataModel.isHaveAnimation = true;
      chatDataModel.id="${conversation.id}_"
          "${DateTime
          .now()
          .microsecondsSinceEpoch}_"
          "${chatDataList.length + modelList.length}";
      chatDataModel.conversationId = conversation.id;
      modelList.add(chatDataModel);
      addTemporaryMessage(chatDataModel, conversation);
    }
    if (modelList != null) {
      if (addChatDataList.length > 0) {
        for (var model in addChatDataList) {
          chatDataList.insert(0, model);
        }
        addChatDataList.clear();
      }
      ChatDataModel time = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
      if (time != null) {
        chatDataList.insert(0, time);
      }
      chatDataList.insertAll(0, modelList);
    }
    _animateToIndex(index: 0);
    if (mounted) {
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }

    //未读消息的跳转数目加modelList.length
    if (ChatMessageProfileUtil.unreadCountNew > 0) {
      ChatMessageProfileUtil.unreadCountNew += modelList.length;
    }

    postImgOrVideo(modelList, conversation.conversationId, selectedMediaFiles.type, conversation.getType(),
        (isSuccess) {
      isNewSourceList = true;
      print("isSuccess:$isSuccess");
      modelList.forEach((element) {
        deleteCancelMessage(element.conversationId, element.id ?? "");
      });
      if (!isSuccess) {
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      }
    });
  }

  //发送录音
  _voiceFile(String path, int time) async {
    // print("发送录音:path:$path,time:$time,${File(path).existsSync()}");

    ChatDataModel chatDataModel = new ChatDataModel();
    ChatVoiceModel voiceModel = new ChatVoiceModel();
    voiceModel.filePath = path;
    voiceModel.longTime = time;
    voiceModel.read = 0;
    chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_VOICE;
    chatDataModel.chatVoiceModel = voiceModel;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = true;
    chatDataModel.id = "${conversation.id}_"
        "${DateTime.now().microsecondsSinceEpoch}_"
        "${chatDataList.length}";
    chatDataModel.conversationId = conversation.id;

    if (addChatDataList.length > 0) {
      for (var model in addChatDataList) {
        chatDataList.insert(0, model);
      }
      addChatDataList.clear();
    }
    ChatDataModel timeModel = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
    if (timeModel != null) {
      chatDataList.insert(0, timeModel);
    }
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    _animateToIndex(index: 0);
    if (mounted) {
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }

    //未读消息的跳转数目加1
    if (ChatMessageProfileUtil.unreadCountNew > 0) {
      ChatMessageProfileUtil.unreadCountNew++;
    }
    // //print("conversation.conversationId:${conversation.conversationId},${conversation.getType()}");
    postVoice(chatDataList[0], conversation.conversationId, conversation.getType(), () {
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  //发送可选择的信息
  _postSelectMessage(String text) async {
    text += "," + text;
    text += "," + text;
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_SELECT;
    chatDataModel.content = text;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = true;

    if (addChatDataList.length > 0) {
      for (var model in addChatDataList) {
        chatDataList.insert(0, model);
      }
      addChatDataList.clear();
    }
    ChatDataModel time = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
    if (time != null) {
      chatDataList.insert(0, time);
    }
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    _animateToIndex(index: 0);
    if (mounted) {
      _textController.text = "";
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
    }
    postSelectMessage(chatDataList[0], conversation.conversationId, conversation.getType(), () {
      //
      // List list=[];
      // list.add(0);
      // list.add(chatDataModel.id);
      // EventBus.getDefault().post(msg:list,registerName: CHAT_EVERY_MESSAGE);
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  //撤回消息
  void recallMessage(Message message, int position) async {
    RecallNotificationMessage recallNotificationMessage = await RongCloud.init().recallMessage(message);
    if (recallNotificationMessage == null) {
      ToastShow.show(msg: "撤回失败", context: _context);
    } else {
      chatDataList[position].msg.objectName = RecallNotificationMessage.objectName;
      chatDataList[position].msg.content = recallNotificationMessage;
      MessageManager.updateConversationByMessage(context, chatDataList[position].msg);
      if (mounted) {
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      }
    }
  }

  //修改撤回消息
  _updateRecallNotificationMessage() {
    getReChatDataModel(
      targetId: conversation.conversationId,
      conversationType: conversation.getType(),
      sendTime: chatDataList[recallNotificationMessagePosition + 1].msg.sentTime,
      text: "你撤回了一条消息",
      finished: (Message msg, int code) {
        ChatDataModel chatDataModel = new ChatDataModel();
        chatDataModel.msg = msg;
        chatDataModel.isTemporary = false;
        chatDataModel.isHaveAnimation = false;
        chatDataList.insert(recallNotificationMessagePosition + 1, chatDataModel);
        RongCloud.init().deleteMessageById(chatDataList[recallNotificationMessagePosition + 2].msg, (code) {});
        chatDataList.removeAt(recallNotificationMessagePosition + 2);
        recallNotificationMessagePosition = -1;
        if (mounted) {
          _textController.text = "";
          bottomSettingChildKey.currentState.setCursorIndexPr(0);
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
        }
      },
    );
  }

  //插入加入黑名单的消息
  void _insertMessageMenu(String text) {
    getReChatDataModel(
      targetId: conversation.conversationId,
      conversationType: conversation.getType(),
      sendTime: new DateTime.now().millisecondsSinceEpoch + 1000,
      text: text,
      finished: (Message msg, int code) {
        if (addChatDataList.length > 0) {
          for (var model in addChatDataList) {
            chatDataList.insert(0, model);
          }
          addChatDataList.clear();
        }

        ChatDataModel chatDataModel = new ChatDataModel();
        chatDataModel.msg = msg;
        chatDataModel.isTemporary = false;
        chatDataModel.isHaveAnimation = false;
        chatDataList.insert(0, chatDataModel);

        _animateToIndex(index: 0);

        if (mounted) {
          isShowTopAttentionUi = true;
          _resetShowTopAttentionUi();
          _textController.text = "";
          bottomSettingChildKey.currentState.setCursorIndexPr(0);
          recallNotificationMessagePosition = -1;
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
        }
      },
    );
  }

  //重新发送消息
  void _resetPostMessage(int position) async {
    if (!(await isContinue(context))) {
      return;
    }
    if (chatDataList[position].isTemporary) {
      if (chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_IMAGE ||
          chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_VIDEO ||
          chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
        _resetPostTemporaryImageVideoVoice(position);
      } else {
        ToastShow.show(msg: "未处理：${chatDataList[position].type}", context: _context);
      }
    } else if (chatDataList[position].msg != null &&
        chatDataList[position].msg.objectName == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      TextMessage textMessage = ((chatDataList[position].msg.content) as TextMessage);
      //print("textMessage.content:${textMessage.content}");
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE ||
          mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        if (mapModel["isTemporary"] != null && mapModel["isTemporary"]) {
          _resetPostMessageTemporaryImageVideo(position, map);
          return;
        }
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VOICE) {
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        if (mapModel["isTemporary"] != null && mapModel["isTemporary"]) {
          _resetPostMessageTemporaryVoice(position, map);
          return;
        }
      }
    }
    _resetPostMsg(position);
  }

  //重新发送临时的图片视频和录音
  void _resetPostTemporaryImageVideoVoice(int position) {
    // chatDataList.insert(0, chatDataList[position]);
    // chatDataList.removeAt(position + 1);
    List<ChatDataModel> modelList = <ChatDataModel>[];
    modelList.add(chatDataList[position]);
    String type = mediaTypeKeyVideo;
    if (chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      type = mediaTypeKeyImage;
    } else if (chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      type = mediaTypeKeyVoice;
    }
    chatDataList[position].isHaveAnimation = false;
    chatDataList[position].isTemporary = true;
    // deletePostCompleteMessage(conversation);
    // chatDataList[position].isTemporary = true;
    // addTemporaryMessage(chatDataList[position], conversation);
    if (type == mediaTypeKeyVoice) {
      postVoice(chatDataList[position], conversation.conversationId, conversation.getType(), () {
        // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      });
    } else {
      postImgOrVideo(modelList, conversation.conversationId, type, conversation.getType(), (isSuccess) {
        if (!isSuccess) {
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      });
    }
  }

  //重新发送融云数据库内的临时图片视频
  void _resetPostMessageTemporaryImageVideo(int position, Map<String, dynamic> sizeInfoMap) async {
    RongCloud.init().deleteMessageById(chatDataList[position].msg, null);
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.type = getChatTypeModel(chatDataList[position]);
    MediaFileModel mediaFileModel = new MediaFileModel();
    mediaFileModel.file = File(sizeInfoMap["showImageUrl"]);
    if (chatDataModel.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      mediaFileModel.type = mediaTypeKeyImage;
    } else {
      mediaFileModel.type = mediaTypeKeyVideo;
      mediaFileModel.thumb = await VideoThumbnail.thumbnailData(
          video: sizeInfoMap["showImageUrl"], imageFormat: ImageFormat.JPEG, quality: 100);
    }
    mediaFileModel.sizeInfo = SizeInfo.fromJson(sizeInfoMap);
    chatDataModel.mediaFileModel = mediaFileModel;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = false;

    chatDataList[position] = chatDataModel;
    // deletePostCompleteMessage(conversation);
    // chatDataList.removeAt(position);

    // List<ChatDataModel> modelList = <ChatDataModel>[];
    // modelList.add(chatDataModel);
    // addTemporaryMessage(chatDataModel, conversation);
    // if (modelList != null) {

    // ChatDataModel time=judgeAddAlertTime(chatDataList.length<1?null:chatDataList[0]??null);
    // if(time!=null){
    //   chatDataList.insert(0, time);
    // }
    // chatDataList.insertAll(0, modelList);
    // }
    // _animateToIndex(index: 0);
    if (mounted) {
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    postImgOrVideo([chatDataList[position]], conversation.conversationId, mediaFileModel.type, conversation.getType(),
        (isSuccess) {
      if (!isSuccess) {
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      }
    });
  }

  //重新发送录音的消息本地数据库里的消息
  _resetPostMessageTemporaryVoice(int position, Map<String, dynamic> infoMap) {
    RongCloud.init().deleteMessageById(chatDataList[position].msg, null);
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.type = getChatTypeModel(chatDataList[position]);
    ChatVoiceModel chatVoiceModel = ChatVoiceModel();
    chatVoiceModel.filePath = infoMap["filePath"];
    chatVoiceModel.longTime = infoMap["duration"];
    chatDataModel.chatVoiceModel = chatVoiceModel;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = false;
    chatDataList[position] = chatDataModel;
    // deletePostCompleteMessage(conversation);
    // chatDataList.removeAt(position);
    // addTemporaryMessage(chatDataModel, conversation);

    // ChatDataModel time=judgeAddAlertTime(chatDataList.length<1?null:chatDataList[0]??null);
    // if(time!=null){
    //   chatDataList.insert(0, time);
    // }
    // chatDataList.insert(0, chatDataModel);
    // _animateToIndex(index: 0);
    if (mounted) {
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    postVoice(chatDataList[position], conversation.conversationId, conversation.getType(), () {});
  }

  //重新发送融云数据的正常消息
  void _resetPostMsg(int position) {
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.isTemporary = false;
    chatDataModel.isHaveAnimation = false;
    chatDataModel.msg = chatDataList[position].msg;
    chatDataModel.msg.sentStatus = 10;
    chatDataModel.msg.sentTime = new DateTime.now().millisecondsSinceEpoch;
    chatDataList[position] = chatDataModel;
    // ChatDataModel time=judgeAddAlertTime(chatDataList.length<1?null:chatDataList[0]??null);
    // if(time!=null){
    //   chatDataList.insert(0, time);
    // }
    // chatDataList.removeAt(position);
    // chatDataList.insert(0, chatDataModel);
    // _animateToIndex(index: 0);

    if (mounted) {
      _textController.text = "";
      bottomSettingChildKey.currentState.setCursorIndexPr(0);
      EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    resetPostMessage(chatDataList[position], () {
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  ///------------------------------------发送消息  end-----------------------------------------------------------------------///
  ///------------------------------------一些功能 方法  start-----------------------------------------------------------------------///

  //设置消息的状态
  void resetMsgStatus(List<int> list) async {
    if (list == null || list.length < 2) {
      return;
    }
    int messageId = list[0];
    int status = list[1];
    //print("更新消息状态-----------messageId：$messageId, status:$status");
    if (messageId == null || status == null || chatDataList == null || chatDataList.length < 1) {
      return;
    } else {
      bool isHaveMessage = false;
      for (ChatDataModel dataModel in chatDataList) {
        if (dataModel.msg?.messageId == messageId) {
          isHaveMessage = true;
          if (dataModel.msg?.sentStatus == status) {
            return;
          } else {
            dataModel.msg?.sentStatus = status;
            if (status == RCSentStatus.Failed) {
              ChatPageUtil.init(context).checkPostMessageFailed(conversation.type, conversation.conversationId);
            } else if (status == RCSentStatus.Sent) {
              await getHistoryMessage(dataModel);
            }
            EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
              }
            });
            return;
          }
        }
      }
      if (!isHaveMessage) {
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          }
        });
      }
    }
  }

  //撤回的消息
  void withdrawMessage(Message message) {
    if (message == null) {
      return;
    }
    if (message.targetId != conversation.conversationId) {
      return;
    }
    if (message.conversationType != conversation.getType()) {
      return;
    }
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      //撤回消息
      for (ChatDataModel model in chatDataList) {
        if (model != null &&
            model.msg != null &&
            model.msg.messageUId != null &&
            model.msg.messageUId == message.messageUId) {
          model.msg = message;
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          break;
        }
      }
      //撤回消息
      for (ChatDataModel model in addChatDataList) {
        if (model != null &&
            model.msg != null &&
            model.msg.messageUId != null &&
            model.msg.messageUId == message.messageUId) {
          model.msg = message;
          break;
        }
      }
    }
    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
  }

  //接收消息
  void getReceiveMessages(Message message) {
    if (message == null) {
      return;
    }
    //print("message.targetId:${message.targetId},${conversation.conversationId}");
    if (message.targetId != conversation.conversationId) {
      return;
    }
    if (message.conversationType != conversation.getType()) {
      return;
    }

    //当进入聊天界面,没有任何聊天记录,这时对方给我发消息就可能会照成崩溃
    if (chatDataList.length > 0 && message.messageUId == chatDataList[0].msg.messageUId) {
      return;
    }

    isNewSourceList=true;

    ChatDataModel chatDataModel = getMessage(message, isHaveAnimation: scrollPositionPixels < 500);
    //print("scrollPositionPixels：$scrollPositionPixels");
    insertSourceList(chatDataModel);
    //判断是不是群通知
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF && conversation.getType() == RCConversationType.Group) {
      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 4:
          conversation.name = dataMap["groupChatName"];
          break;
        default:
          getChatGroupUserModelList1(conversation.conversationId, context);
          break;
      }
    }

    if (scrollPositionPixels < 500) {
      ChatDataModel time = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
      if (time != null) {
        chatDataList.insert(0, time);
      }
      chatDataList.insert(0, chatDataModel);
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      //未读消息的跳转数目加1
      if (ChatMessageProfileUtil.unreadCountNew > 0) {
        ChatMessageProfileUtil.unreadCountNew++;
      }
    } else {
      ChatDataModel time;
      if (addChatDataList.length < 1) {
        time = judgeAddAlertTime(chatDataList.length < 1 ? null : chatDataList[0] ?? null);
      } else {
        time = judgeAddAlertTime(addChatDataList[addChatDataList.length - 1] ?? null);
      }
      if (time != null) {
        addChatDataList.add(time);
      }
      addChatDataList.add(chatDataModel);
    }

    //清聊天未读数
    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
  }

  // 大图预览插入数据
  insertSourceList(ChatDataModel model) {
    DemoSourceEntity demoSourceEntity=MessageItemGalleryUtil.init().getMessageGallery(model);
    if(demoSourceEntity!=null){
      sourceList.add(demoSourceEntity);
    }
  }

  //获取数据库内的messageUId
  Future<void> getHistoryMessage(ChatDataModel model) async {
    if (null == model.msg.messageUId || model.msg.messageUId.length < 1) {
      model.msg = await Application.rongCloud.getMessageById(model.msg.messageId);
    }
  }

//判断是否退出群聊或者加入群聊
  void _judgeResetPage(Message message) {
    //print("判断是否退出群聊或者加入群聊");

    if (message == null) {
      //print(message == null);
      return;
    }
    Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
    if (dataMap["groupChatId"].toString() != conversation.conversationId) {
      //print("message.targetId:${message.targetId},${conversation.conversationId}");
      return;
    }
    _resetChatGroupUserModelList(message);
    //print("dataMap[subType]0:${dataMap["subType"]}");
    if (dataMap["subType"] == 0 || dataMap["subType"] == 2) {
      //print("dataMap[subType]0:${dataMap["subType"]}");
      insertExitGroupMsg(message, conversation.conversationId, (Message msg, int code) {
        if (code == 0) {
          //print("scrollPositionPixels加入：$scrollPositionPixels");
          if (scrollPositionPixels < 500) {
            chatDataList.insert(0, getMessage(msg, isHaveAnimation: scrollPositionPixels < 500));
            EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          } else {
            addChatDataList.add(getMessage(msg, isHaveAnimation: scrollPositionPixels < 500));
          }
        }
      });
    } else {
      if (scrollPositionPixels < 500) {
        EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      }
    }
  }

  //重新刷新群聊人数
  void _resetChatGroupUserModelList(Message message) {
    if (message == null) {
      return;
    }
    if (message.targetId != conversation.conversationId) {
      return;
    }
    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
    getChatGroupUserModelList(conversation.conversationId, context);
  }

  initWidget() {
    topAttentionUiWidget = ChatPageUtil.init(_context)
        .getTopAttentionUi(isShowTopAttentionUi, conversation.type, _attntionOnClick, (bool isShow) {
      isShowTopAttentionUi = isShow;
      _resetShowTopAttentionUi();
    });
  }

  initScrollController() {
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _scrollController.addListener(() {
      scrollPositionPixels = _scrollController.position.pixels;
      double scrollMaxPositionPixels = _scrollController.position.maxScrollExtent;
      // print("scrollPositionPixels3：$scrollPositionPixels,scrollMaxPositionPixels:$scrollMaxPositionPixels");
      // print("scrollPositionPixels3：$lastIndex,scrollMaxPositionPixels:${chatDataList.length}");
      int chatDataListLength = 0;
      if (chatDataList != null && chatDataList.length >= 0) {
        chatDataListLength = chatDataList.length;
      }
      if (scrollPositionPixels == scrollMaxPositionPixels && lastIndex + 1 >= chatDataListLength) {
        // print("loadStatus:$loadStatus");
        if (loadStatus == LoadingStatus.STATUS_IDEL) {
          // 先设置状态，防止下拉就直接加载reload
          if (mounted) {
            loadStatus = LoadingStatus.STATUS_LOADING;
          }
          if (conversation.getType() != RCConversationType.System) {
            _onLoadMoreHistoryMessages();
          } else {
            _onRefreshSystemInformation();
          }
        }
        chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
      } else if (scrollPositionPixels <= 0) {
        if (mounted && addChatDataList.length > 0) {
          for (var model in addChatDataList) {
            chatDataList.insert(0, model);
          }
          addChatDataList.clear();
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      }
    });
  }

  initTextController() {
    _focusNode.addListener(() {
      cursorIndexPr = _textController.selection.baseOffset;
      bottomSettingChildKey.currentState.setCursorIndexPr(cursorIndexPr);
    });
    _textController.addListener(() {
      // //print("值改变了");
      //print("监听文字光标${_textController.selection}");

      List<Rule> rules = context.read<ChatEnterNotifier>().rules;
      int atIndex = context.read<ChatEnterNotifier>().atCursorIndex;
      //print("当前值￥${_textController.text}");
      //print(context.read<ChatEnterNotifier>().textFieldStr);
      // 获取光标位置
      int cursorIndex = _textController.selection.baseOffset;
      //print("实时光标位置$cursorIndex");
      // 在每次选择@用户后ios设置光标位置。 在每次选择@用户后ios设置光标位置。
      if (Platform.isIOS && (isClickAtUser || recallNotificationMessagePosition == -2)) {
        recallNotificationMessagePosition = -1;
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: _textController.text.length,
          extentOffset: _textController.text.length,
        );
        _textController.selection = setCursor;
      }
      if (Platform.isAndroid && isClickAtUser) {
        //print("at位置&$atIndex");
        var setCursor = TextSelection(
          baseOffset: atIndex,
          extentOffset: atIndex,
        );
        _textController.selection = setCursor;
      }
      isClickAtUser = false;
      // // 安卓每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      if (isSwitchCursor && !Platform.isIOS) {
        // _textEditingController.o
        for (Rule rule in rules) {
          // 是否光标点击到了@区域
          if (cursorIndex >= rule.startIndex && cursorIndex <= rule.endIndex) {
            // 获取中间值用此方法是因为当atRule.startIndex和atRule.endIndex为负数时不会溢出。
            int median = rule.startIndex + (rule.endIndex - rule.startIndex) ~/ 2;
            TextSelection setCursor;
            if (cursorIndex <= median) {
              setCursor = TextSelection(
                baseOffset: rule.startIndex,
                extentOffset: rule.startIndex,
              );
            }
            if (cursorIndex > median) {
              setCursor = TextSelection(
                baseOffset: rule.endIndex,
                extentOffset: rule.endIndex,
              );
            }
            // 设置光标
            _textController.selection = setCursor;
          }
        }

        // 唤起@#后切换光标关闭视图
        if (cursorIndex != atIndex) {
          if (context.read<ChatEnterNotifier>().keyWord != "") {
            context.read<ChatEnterNotifier>().openAtCallback("");
            EventBus.init().post(registerName: CHAT_AT_GROUP_PANEL);
          }
        }
      }
      isSwitchCursor = true;
    });
  }

  initReleaseFeedInputFormatter() {
    _formatter = ReleaseFeedInputFormatter(
      context: context,
      controller: _textController,
      maxNumberOfBytes: 6000,
      correctRulesListener: () {
        streamEditWidget.sink.add(0);
      },
      rules: context.read<ChatEnterNotifier>().rules,
      // @回调
      triggerAtCallback: (String str) async {
        //print("打开@功能--str：$str------------------------");
        bool isHaveUser = true;
        if (context.read<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0) {
          if (context.read<GroupUserProfileNotifier>().isNoHaveMe()) {
            isHaveUser = false;
          }
        } else {
          if (MessageManager.chatGroupUserInformationMap["${conversation.conversationId}_${Application.profile.uid}"] ==
              null) {
            isHaveUser = false;
          }
        }
        if (isHaveUser) {
          if (conversation.getType() == RCConversationType.Group) {
            context.read<ChatEnterNotifier>().openAtCallback(str);
            isClickAtUser = false;
            EventBus.init().post(registerName: CHAT_AT_GROUP_PANEL);
          }
        }
        return "";
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        //print("取消艾特功能3");
        //print('----------------------------关闭视图');
        context.read<ChatEnterNotifier>().openAtCallback("");
        EventBus.init().post(registerName: CHAT_AT_GROUP_PANEL);
      },
      valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
          String topicSearchStr, bool isAdd) {
        rules = rules;
        // ////print("输入框值回调：$value");
        // ////print(rules);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<ChatEnterNotifier>().getAtCursorIndex(atIndex);
        }
        context.read<ChatEnterNotifier>().setAtSearchStr(atSearchStr);
        context.read<ChatEnterNotifier>().changeCallback(value);
        context.read<GroupUserProfileNotifier>().setSearchText(atSearchStr);
        // 实时搜索
      },
    );
  }

  //滚动到聊天界面的顶部
  void _animateToIndex({int index}) {
    _scrollController.scrollToIndex(index ?? chatDataList.length - 1,
        duration: Duration(milliseconds: getMilliseconds(index ?? chatDataList.length - 1)),
        preferPosition: AutoScrollPosition.middle);
  }

  int getMilliseconds(int scrollIndex) {
    return (((max(0, scrollIndex - lastIndex)) / chatAddHistoryMessageCount + 1) * 400).toInt();
  }

  ///------------------------------------一些功能 方法  end-----------------------------------------------------------------------///
  ///------------------------------------各种点击事件  start-----------------------------------------------------------------------///

  //聊天内容的点击事件
  _messageInputBodyClick() {
    //print("_messageInputBodyClick");
    try {
      if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0 || _bottomSettingPanelState) {
        _emojiStateOld = false;
        //print("_emojiStateOld1:$_emojiStateOld");

        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          //print("222222222222222222");
        }
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        _bottomSettingPanelState = false;
        bottomSettingChildKey.currentState.bottomSettingPanelState = false;
        if (_emojiState) {
          _emojiState = false;
          messageInputBarChildKey.currentState.setIsEmojio(_emojiState);
          bottomSettingChildKey.currentState.setData(
            bottomSettingPanelState: false,
            emojiState: _emojiState,
          );
        } else {
          bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
        }
      }
      Future.delayed(Duration(milliseconds: 100), () {
        if (readOnly) {
          readOnly = false;
          if (mounted &&
              streamEditWidget != null &&
              streamEditWidget.sink != null &&
              streamEditWidget.sink.add != null) {
            streamEditWidget.sink.add(0);
          }
        }
      });
    } catch (e) {}
  }

  //输入框的点击事件
  textSpanFieldClickListener() {
    _emojiStateOld = _emojiState;
    print("_emojiStateOld2:$_emojiStateOld");
    if (_emojiState) {
      _emojiState = !_emojiState;
      messageInputBarChildKey.currentState.setIsEmojio(_emojiState);
      bottomSettingChildKey.currentState.setData(emojiState: _emojiState);
      _bottomSettingPanelState = true;
      bottomSettingChildKey.currentState.setBottomSettingPanelState(true);
      // Future.delayed(Duration(milliseconds: 200),(){
      //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
      //     _bottomSettingPanelState = false;
      //     bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
      //   }
      // });
    } else {
      // pageHeightStopCanvas = true;
      // oldKeyboardHeight = 0;
    }
    print("readOnly:$readOnly");
    if (readOnly) {
      readOnly = false;
      streamEditWidget.sink.add(0);
    }
  }

  //表情的点击事件
  void onEmojioClick() {
    cursorIndexPr = _textController.selection.baseOffset;
    bottomSettingChildKey.currentState.setCursorIndexPr(cursorIndexPr);

    if (_isVoiceState) {
      // if(_textController.text.length>0){
      //   context.read<ChatEnterNotifier>().clearRules();
      //   _textController.text = "";
      //   bottomSettingChildKey.currentState.setCursorIndexPr(0);
      //   _changTextLen("");
      // }
      _isVoiceState = false;
      messageInputBarChildKey.currentState.setIsVoice(_isVoiceState);
    }

    if (_emojiState) {
      // _emojiState = false;
      readOnly = false;
      // _emojiStateOld = true;
      textSpanFieldClickListener();
      streamEditWidget.sink.add(0);
    } else {
      _emojiState = true;
      readOnly = true;
      streamEditWidget.sink.add(0);
      EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);
      Future.delayed(Duration(milliseconds: 100), () {
        if (!_focusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_focusNode);
          // _emojiStateOld=true;
          // FocusScope.of(context).requestFocus(_focusNode);
          // textSpanFieldClickListener();
          bottomSettingChildKey.currentState.setCursorIndexPr(_textController.text.length);
        }
      });
    }
    messageInputBarChildKey.currentState.setIsEmojio(_emojiState);

    bottomSettingChildKey.currentState.setEmojiState(_emojiState);
  }

  //图片的点击事件
  onPicAndVideoBtnClick() {
    ////print("=====图片的点击事件");
    context.read<VoiceSettingNotifier>().stop();
    _messageInputBodyClick();
    SelectedMediaFiles selectedMediaFiles = new SelectedMediaFiles();
    AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, false, startPageGallery, false, (result) async {
      SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
      if (true != result || files == null) {
        ////print("没有选择媒体文件");
        return;
      }
      RuntimeProperties.selectedMediaFiles = null;
      selectedMediaFiles.type = files.type;
      selectedMediaFiles.list = files.list;
      _handPicOrVideo(selectedMediaFiles);
    });
  }

  //发送按钮点击事件
  _onSubmitClick() {
    if (ClickUtil.isFastClick(time: 200)) {
      return;
    }
    String text = _textController.text;
    if (text == null || text.isEmpty || text.length < 1) {
      ToastShow.show(msg: "消息为空,请输入消息！", context: _context);
      return;
    }
    _postText(text);
  }

  //点击删除输入框
  _deleteEditText() {
    if (_textController.text == null || _textController.text.length < 1 || cursorIndexPr <= 0) {
      return;
    }

    var setCursorOld = TextSelection(
      baseOffset: cursorIndexPr,
      extentOffset: cursorIndexPr,
    );
    String editString = _textController.text;
    TextEditingValue oldValue = TextEditingValue(text: editString, selection: setCursorOld, composing: TextRange.empty);
    List<String> listString = editString.characters.toList();
    editString = "";
    int textLength = 0;
    int deleteTextLength = 0;
    for (int i = 1; i < listString.length + 1; i++) {
      textLength += listString[i - 1].length;
      if (cursorIndexPr != textLength) {
        editString += listString[i - 1];
      } else {
        deleteTextLength = listString[i - 1].length;
      }
    }
    cursorIndexPr -= deleteTextLength;
    var setCursor = TextSelection(
      baseOffset: cursorIndexPr,
      extentOffset: cursorIndexPr,
    );
    TextEditingValue newValue = TextEditingValue(text: editString, selection: setCursor, composing: TextRange.empty);
    TextEditingValue value = _formatter.formatEditUpdate(oldValue, newValue);
    cursorIndexPr = value.selection.baseOffset;
    bottomSettingChildKey.currentState.setCursorIndexPr(cursorIndexPr);
    _textController.value = value;
    _changTextLen(_textController.text);
  }

  //录音按钮的点击事件
  _voiceOnTapClick() async {
 Permission.microphone.request().then((value){
   if (value.isGranted) {
     _focusNode.unfocus();
        //print("4444444444444");
        // if(_textController.text.length>0){
        //   context.read<ChatEnterNotifier>().clearRules();
        //   _textController.text = "";
        //   bottomSettingChildKey.currentState.setCursorIndexPr(0);
        //   _changTextLen("");
        // }
        _isVoiceState = !_isVoiceState;
        messageInputBarChildKey.currentState.setIsVoice(_isVoiceState);

        EventBus.init().post(msg: _isVoiceState, registerName: CHAT_BOTTOM_MORE_BTN);

        if (_emojiState) {
          _emojiState = false;
          messageInputBarChildKey.currentState.setIsEmojio(_emojiState);
          bottomSettingChildKey.currentState.setEmojiState(_emojiState);
        }
        if (readOnly) {
          readOnly = false;
          streamEditWidget.sink.add(0);
        }
        Future.delayed(Duration(milliseconds: 100), () {
       if (!_isVoiceState) {
         _emojiStateOld = true;
         FocusScope.of(context).requestFocus(_focusNode);
         textSpanFieldClickListener();
       }
     });
   }else if(value.isPermanentlyDenied){
     showAppDialog(context,
         title: "获取录音权限",
         info: "使用该功能需要打开录音权限",
         cancel: AppDialogButton("取消", () {
           return true;
         }),
         confirm: AppDialogButton(
           "去打开",
               () {
             AppSettings.openAppSettings();
             return true;
           },
         ),
         barrierDismissible: false);
   }
 });

  }

  //头部-更多按钮的点击事件
  _topMoreBtnClick() {
    if (ClickUtil.isFastClick()) {
      return;
    }
    // _animateToIndex();
    // Message msg = chatDataList[chatDataList.length - 2].msg;
    // AtMsg atMsg = new AtMsg(groupId: int.parse(msg.targetId), sendTime: msg.sentTime, messageUId: msg.messageUId);
    // MessageManager.atMesGroupModel.add(atMsg);
    // context.read<VoiceSettingNotifier>().stop();

    print("conversation:${conversation.toMap().toString()}");

    _messageInputBodyClick();
    if (conversation.getType() == RCConversationType.Group && conversation.groupType == 1) {
      //是活动群聊时展示功能按钮面板
      _showBottomSetting();
    } else {
      //不是跳转更多界面
      judgeJumpPage(
          conversation.getType(),
          this.conversation.conversationId,
          conversation.type,
          context,
          getChatName(),
          _morePageOnClick,
          _moreOnClickExitChatPage,
          conversation.id);
    }
  }

  //更多的界面-里面进行了一些的点击事件
  _morePageOnClick(int type, String name) {
    //type  0-用户名  1--群名 2--拉黑 3--邀请不是相互关注-进行提醒
    if (type == 0) {
      //修改了用户名
      // Application.chatGroupUserNameMap.clear();
      // for (ChatGroupUserModel userModel in context.read<GroupUserProfileNotifier>().chatGroupUserModelList) {
      //   Application.chatGroupUserNameMap[userModel.uid.toString()] = userModel.groupNickName;
      // }
      //print("修改了用户名");
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    } else if (type == 1) {
      conversation.name = name;
      //修改了群名
      // _postUpdateGroupName(name);
      context.read<ConversationNotifier>().updateConversationName(name, conversation);
      EventBus.init().post(registerName: EVENTBUS_CHAT_BAR);
    } else if (type == 2) {
      //拉黑
      _insertMessageMenu("你拉黑了这个用户!");
      if (context
          .read<UserInteractiveNotifier>()
          .value
          .profileUiChangeModel
          .containsKey(int.parse(conversation.conversationId))) {
        context.read<UserInteractiveNotifier>().removeUserFollowId(int.parse(conversation.conversationId));
      }
    } else {
      //不是还有关系不能邀请进群
      _insertMessageMenu(name + " 邀请失败!");
    }
  }

  //更多界面点击了退出群聊-要退出聊天界面
  _moreOnClickExitChatPage() {
    //退出群聊
    MessageManager.removeConversation(context, conversation.conversationId, Application.profile.uid, conversation.type);
    Application.rongCloud.clearMessages(conversation.getType(), conversation.conversationId.toString(), null);
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pop();
    });
  }

  //头部显示的关注按钮的点击事件
  _attntionOnClick() async {
    if (conversation.type == PRIVATE_TYPE) {
      BlackModel blackModel = await ProfileCheckBlack(int.parse(conversation.conversationId));
      String text = "";
      if (blackModel != null && blackModel.inYouBlack == 1) {
        text = "关注失败，你已将对方加入黑名单";
      } else if (blackModel != null && blackModel.inThisBlack == 1) {
        text = "关注失败，你已被对方加入黑名单";
      } else {
        int attntionResult = await ProfileAddFollow(int.parse(conversation.conversationId));
        if (attntionResult != null && (attntionResult == 1 || attntionResult == 3)) {
          text = "关注成功!";
          isShowTopAttentionUi = false;
          _resetShowTopAttentionUi();
          context.read<UserInteractiveNotifier>().changeFollowCount(int.parse(conversation.conversationId), true);
          if (context
              .read<UserInteractiveNotifier>()
              .value
              .profileUiChangeModel
              .containsKey(int.parse(conversation.conversationId))) {
            //print('=================个人主页同步');
            context.read<UserInteractiveNotifier>().changeIsFollow(true, false, int.parse(conversation.conversationId));
            context
                .read<UserInteractiveNotifier>()
                .removeUserFollowId(int.parse(conversation.conversationId), isAdd: false);
          }
        }
      }
      if (text != null && text.length > 0) {
        ToastShow.show(msg: text, context: _context);
      }
    } else {
      isShowTopAttentionUi = false;
      _resetShowTopAttentionUi();
    }
  }

  //at 了那个用户
  void atListItemClick(ChatGroupUserModel userModel, int index) {
    isClickAtUser = true;
    // ////print("+++++++++++++++++++++++++++++++++++++++++++++++++++" + content);
    // At的文字长度
    int atLength = userModel.nickName.length + 1;
    // 获取输入框内的规则
    var rules = context.read<ChatEnterNotifier>().rules;
    // 检测是否添加过
    if (rules.isNotEmpty) {
      for (Rule rule in rules) {
        if (rule.clickIndex == userModel.uid && rule.isAt == true) {
          ToastShow.show(msg: "你已经@过Ta啦！", context: _context, gravity: Toast.CENTER);
          ////print("你已经@过Ta啦！");
          return;
        }
      }
    }
    // 获取@的光标
    int atIndex = context.read<ChatEnterNotifier>().atCursorIndex;
    // 获取实时搜索文本
    String searchStr = context.read<ChatEnterNotifier>().atSearchStr;
    // @前的文字
    String atBeforeStr;
    try {
      atBeforeStr = _textController.text.substring(0, atIndex);
    } catch (e) {
      atBeforeStr = "";
    }
    // @后的文字
    String atRearStr = "";
    ////print(searchStr);
    ////print("controller.text:${_textController.text}");
    ////print("atBeforeStr$atBeforeStr");
    // isSwitchCursor = false;
    if (searchStr != "" && searchStr != null && searchStr.isNotEmpty) {
      ////print("atIndex:$atIndex");
      ////print("searchStr:$searchStr");
      ////print("controller.text:${_textController.text}");
      atRearStr = _textController.text.substring(atIndex + searchStr.length, _textController.text.length);
      ////print("atRearStr:$atRearStr");
    } else {
      atRearStr = _textController.text.substring(atIndex, _textController.text.length);
    }

    // 拼接修改输入框的值
    _textController.text = atBeforeStr + userModel.nickName + " " + atRearStr;
    // ios赋值设置了光标后会走addListener监听，但是在监听内打印光标位置 获取为0，安卓不会出现此问题 所有iOS没必要在此设置光标位置。
    if (!Platform.isIOS) {
      // 设置光标
      var setCursor = TextSelection(
        baseOffset: _textController.text.length,
        extentOffset: _textController.text.length,
      );
      _textController.selection = setCursor;
    }
    context.read<ChatEnterNotifier>().changeCallback(atBeforeStr + userModel.nickName + atRearStr);
    // isSwitchCursor = false;
    ////print("controller.text:${_textController.text}");
    // 这是替换输入的文本修改后面输入的@的规则
    if (searchStr != "" && searchStr != null && searchStr.isNotEmpty) {
      int oldLength = searchStr.length;
      int newLength = userModel.nickName.length + 1;
      int oldStartIndex = atIndex;
      int diffLength = newLength - oldLength;
      for (int i = 0; i < rules.length; i++) {
        if (rules[i].startIndex >= oldStartIndex) {
          int newStartIndex = rules[i].startIndex + diffLength;
          int newEndIndex = rules[i].endIndex + diffLength;
          rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
        }
      }
    }
    // 此时为了解决后输入的@切换光标到之前输入的@或者#前方，更新之前输入@和#的索引。
    for (int i = 0; i < rules.length; i++) {
      // 当最新输入框内的文本对应不上之前的值时。
      if (rules[i].params != _textController.text.substring(rules[i].startIndex, rules[i].endIndex)) {
        ////print("进入");
        ////print(rules[i]);
        rules[i] = Rule(rules[i].startIndex + atLength, rules[i].endIndex + atLength, rules[i].params,
            rules[i].clickIndex, rules[i].isAt);
        ////print(rules[i]);
      }
    }
    // 存储规则
    context
        .read<ChatEnterNotifier>()
        .addRules(Rule(atIndex - 1, atIndex + atLength, "@" + userModel.nickName + " ", userModel.uid, true));

    //print("取消艾特功能4");
    context.read<ChatEnterNotifier>().setAtSearchStr("");
    // 关闭视图
    context.read<ChatEnterNotifier>().openAtCallback("");
    EventBus.init().post(registerName: CHAT_AT_GROUP_PANEL);
    streamEditWidget.sink.add(0);
  }


  //加载更多的系统通知
  _onRefreshSystemInformation() async {
    if (isnRefreshSystemInformationIng) {
      return;
    }
    isnRefreshSystemInformationIng = true;
    List<ChatDataModel> dataList = await getSystemInformationNet();
    if (dataList != null && dataList.length > 0) {
      ChatPageUtil.init(context).setTimeAlert(dataList, conversation.conversationId);
      if (chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime < 5 * 60 * 1000) {
        chatDataList.removeAt(chatDataList.length - 1);
      }
      chatDataList.addAll(dataList);

      loadStatus = LoadingStatus.STATUS_IDEL;
    } else {
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
    EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    isnRefreshSystemInformationIng = false;
  }


  //进入聊天界面判断需不需加载网路历史数据
  _isInitAddRemoteHistoryMessages(){
    //目前不做
    // ChatPageUtil.init(context).isInitAddRemoteHistoryMessages(chatDataList,conversation);
  }

  //加载更多的历史记录
  _onLoadMoreHistoryMessages(){
    ChatPageUtil.init(context).onLoadMoreHistoryMessages(
      chatDataList, conversation,
      (bool isHaveMore){
          if (isHaveMore) {
        //判断有没有艾特我的消息
        if (isHaveAtMeMsg || isHaveAtMeMsgPr) {
          judgeNowChatIsHaveAt();
        }
        loadStatus = LoadingStatus.STATUS_IDEL;
      } else {
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
      chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
      judgeIsAddUnreadCountAlertMsg();
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  void judgeIsAddUnreadCountAlertMsg() {
    if (ChatMessageProfileUtil.unreadCountNew > 0 && !isAddUnreadCountAlertMsg) {
      if (ChatMessageProfileUtil.unreadCountNew <= chatDataList.length) {
        ChatPageUtil.init(context)
            .addNewAlertMsg(chatDataList, ChatMessageProfileUtil.unreadCountNew, conversation.conversationId);
        isAddUnreadCountAlertMsg = true;
      }
    }
  }

  //取消长按界面

  void Function() removeLongPanelCall;

  void _setCallRemoveLongPanel(void Function() call, String longClickString) {
    // print("111111longClickString:$longClickString");
    if (removeLongPanelCall != null &&
        longClickString != null &&
        longClickString!=""&&
        !longClickString.contains("撤回")){
      EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    this.removeLongPanelCall = call;
  }

  //取消长按界面
  void _removeLongPanelCall() {
    //print("取消长按界面");
    if (removeLongPanelCall != null) {
      //print("取消长按界面-有");
      removeLongPanelCall();
    } else {
      //print("取消长按界面-無");
    }
  }

  //取消at标识
  void Function(bool isHaveAtMeMsg) setHaveAtMeMsgCall;

  void _setHaveAtMeMsg(void Function(bool isHaveAtMeMsg) call) {
    this.setHaveAtMeMsgCall = call;
  }

  //取消at标识
  void setHaveAtMeMsg(bool isHaveAtMeMsg) {
    if (setHaveAtMeMsgCall != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        setHaveAtMeMsgCall(isHaveAtMeMsg);
      });
    }
  }

  //取消新消息的标识
  void Function(int unreadCount) setUnreadCountCall;

  void _setUnreadCountCall(void Function(int unreadCount) call) {
    this.setUnreadCountCall = call;
  }

  //取消at标识
  void setUnreadCount(int unreadCount) {
    if (setUnreadCountCall != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        setUnreadCountCall(unreadCount);
      });
    }
  }

  //所有的item长按事件
  void onItemLongClickCallBack(
      {int position, String settingType, Map<String, dynamic> map, String contentType, String content}) {
    //print("所有的item长按事件");
    if (conversation.type == MANAGER_TYPE && position != null) {
      position--;
    }
    String urlMd5StringVideo = map == null ? "" : map["urlMd5String"];
    String filePathMd5Video = map == null ? "" : map["filePathMd5"];

    if (settingType == null || settingType.isEmpty || settingType.length < 1) {
      ////print("暂无此配置");
    } else if (settingType == "删除") {
      if(this.urlMd5StringVideo==urlMd5StringVideo||this.filePathMd5Video==filePathMd5Video){
        context.read<VoiceSettingNotifier>().stop();
      }
      if(chatDataList[position].isTemporary){
        if(chatDataList[position].id!=null){
          cancelPostMessage.add(chatDataList[position].id);
          deleteCancelMessage(conversation.id, chatDataList[position].id ?? "");
          if (mounted) {
            chatDataList.removeAt(position);
            EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          }
        }
      }else {
        RongCloud.init().deleteMessageById(chatDataList[position].msg, (code) {
          //print("====" + code.toString());
          updateMessagePageAlert(conversation, context);
          if (mounted) {
            chatDataList.removeAt(position);
            if (chatDataList.length > position) {
              if (ChatPageUtil.init(context).isTimeAlertMsg(chatDataList[position])) {
                chatDataList.removeAt(position);
              }
            }
            EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          }
        });
        //print("删除-第$position个");
      }
    } else if (settingType == "撤回") {
      if(this.urlMd5StringVideo==urlMd5StringVideo||this.filePathMd5Video==filePathMd5Video){
        context.read<VoiceSettingNotifier>().stop();
      }
      recallMessage(chatDataList[position].msg, position);
    } else if (settingType == "复制") {
      if (context != null && content != null) {
        Clipboard.setData(ClipboardData(text: content));
        ToastShow.show(msg: "复制成功", context: _context);
      }
    } else {
      ////print("暂无此配置");
    }
    ////print("position:$position-----------------------------------------");
    // ////print("position：$position--$contentType---${content==null?map.toString():content}----${chatDataList[position].msg.toString()}");
  }

  //所有的item点击事件
  void onMessageClickCallBack(
      {String contentType, String content, int position, Map<String, dynamic> map, bool isUrl, String msgId}) {
    if (conversation.type == MANAGER_TYPE && position != null) {
      position--;
    }

    if (contentType == null || contentType.isEmpty || contentType.length < 1) {
      ////print("暂无此配置");
    }
    if (contentType == ChatTypeModel.MESSAGE_TYPE_TEXT && isUrl) {
      // print("跳转网页地址:$content");
      _messageInputBodyClick();
      context.read<VoiceSettingNotifier>().stop();
      StringUtil.launchUrl(content, context);
      // ToastShow.show(msg: "跳转网页地址: $content", context: _context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_FEED) {
      context.read<VoiceSettingNotifier>().stop();
      // ToastShow.show(msg: "跳转动态详情页", context: context);
      getFeedDetail(map["id"], context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      //大图预览
      context.read<VoiceSettingNotifier>().stop();
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      //大图预览
      context.read<VoiceSettingNotifier>().stop();
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_USER) {
      context.read<VoiceSettingNotifier>().stop();
      // ToastShow.show(msg: "跳转用户界面", context: _context);
      _messageInputBodyClick();
      jumpToUserProfilePage(context, map["uid"], avatarUrl: map["avatarUri"], userName: map["nikeName"],
          callback: (dynamic result) {
        //print("result:$result");
        getRelation();
      });
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
      context.read<VoiceSettingNotifier>().stop();
      // ToastShow.show(msg: "跳转直播课详情界面", context: _context);
      CourseModel liveModel = CourseModel.fromJson(map);
      AppRouter.navigateToLiveDetail(context, liveModel.id,
          heroTag: msgId, liveModel: liveModel, isHaveStartTime: false);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
      context.read<VoiceSettingNotifier>().stop();
      // ToastShow.show(msg: "跳转视频课详情界面", context: _context);
      CourseModel videoModel = CourseModel.fromJson(map);
      AppRouter.navigateToVideoDetail(context, videoModel.id, heroTag: msgId, videoModel: videoModel);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // ToastShow.show(msg: "播放录音", context: _context);
      urlMd5StringVideo=map["urlMd5String"];
      filePathMd5Video=map["filePathMd5"];
      updateMessage(chatDataList[position], (code) {
        if (mounted) {
          EventBus.init().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      });
    } else if (contentType == RecallNotificationMessage.objectName) {
      recallNotificationMessagePosition = -2;
      //print("position:$position");
      // ToastShow.show(msg: "重新编辑消息", context: _context);
      // FocusScope.of(context).requestFocus(_focusNode);

      if (_isVoiceState) {
        _isVoiceState = false;
        messageInputBarChildKey.currentState.setIsVoice(_isVoiceState);
      }

      _textController.text += json.decode(map["content"])["data"];
      bottomSettingChildKey.currentState.setCursorIndexPr(_textController.text.length);
      if (CheckPhoneSystemUtil.init().isAndroid()) {
        var setCursor = TextSelection(
          baseOffset: _textController.text.length,
          extentOffset: _textController.text.length,
        );
        _textController.selection = setCursor;
      }
      print("00000000000000000000000000000000000");
      FocusScope.of(context).requestFocus(_focusNode);
      print("000000000000000000000000000000000001");
      textSpanFieldClickListener();
    } else if (contentType == ChatTypeModel.CHAT_SYSTEM_BOTTOM_BAR) {
      // ToastShow.show(msg: "管家界面-底部点击了：$content", context: _context);
      // _postSelectMessage(content);
      if (content == "拉入群聊") {
        _showGroupPopup();
      }
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      // ToastShow.show(msg: "选择列表选择了-底部点击了：$content", context: _context);
      if (ClickUtil.isFastClick(time: 200)) {
        return;
      }
      // _textController.text=content;
      _postText(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_CLICK_ERROR_BTN) {
      //print("点击了发送失败的按钮-重新发送：$position");

      // profileCheckBlack();
      _resetPostMessage(position);
      // _textController.text=content;
      // _postText(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE && content == "点击查看活动详情") {
      //print("点击查看活动详情：$position");
      _comeInActivity(conversation.activityId);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE) {
      //print("点击了邀请参加活动消息：$position");
      _joinByInvitationActivity(map["id"] ?? 0);
    } else {
      ////print("暂无此类型");
    }
  }

  // 打开大图预览
  _openGallery(int position) {
    if(isNewSourceList) {
      sourceList.clear();

      sourceList = MessageItemGalleryUtil.init().getMessageGalleryList(chatDataList);

      isNewSourceList = false;
    }

    int initIndex = MessageItemGalleryUtil.init().getPositionMessageGalleryList(sourceList,chatDataList[position]);

    if(initIndex<0) {
      sourceList.clear();
      sourceList = MessageItemGalleryUtil.init().getMessageGalleryList(chatDataList);
      isNewSourceList = false;

      initIndex = MessageItemGalleryUtil.init().getPositionMessageGalleryList(sourceList, chatDataList[position]);
      if (initIndex < 0) {
        ToastShow.show(msg: "无法查看详情$position", context: context);
        return;
      }
    }

    Navigator.of(context).push(
      HeroDialogRoute<void>(builder: (BuildContext context) {
        return InteractiveviewerGallery(sources: sourceList, initIndex: initIndex, itemBuilder: itemBuilder);
      }),
    );
  }

// 大图预览内部的Item
  Widget itemBuilder(BuildContext context, int index, bool isFocus,Function(Function(bool isFocus),int) setFocus) {
    DemoSourceEntity sourceEntity = sourceList[index];
    //print("____sourceEntity:index,$index,isFocus:$isFocus:${sourceEntity.toString()}");
    if (sourceEntity.type == 'video') {
      return DemoVideoItem2(
        sourceEntity,
        isFocus,
        index,
        setFocus,
      );
    } else {
      return DemoImageItem(
        sourceEntity,
        isFocus,
        index,
        setFocus,
      );
    }
  }



  //显示我已加入的群聊--邀请对话的人进入群聊
  _showGroupPopup() {
    showGroupPopup(context, int.parse(conversation.conversationId), (GroupChatModel groupChatModel) async {
      if (isShowTopAttentionUi) {
        await _attntionOnClick();
      }
      bool isSuccess = await ChatPageUtil.init(context).addUserGroup(conversation.conversationId, groupChatModel.id);
      if (isSuccess) {
        String name = groupChatModel.modifiedName ?? groupChatModel.name;
        _postText("我已邀请你进入群聊：$name");
      }
    });
  }

  // @override
  // void endCanvasPage() {
  //   //print("停止改变屏幕高度");
  //   if (MediaQuery.of(this.context).viewInsets.bottom > 0) {
  //     if (Application.keyboardHeightChatPage != MediaQuery.of(this.context).viewInsets.bottom) {
  //       Application.keyboardHeightChatPage = MediaQuery.of(this.context).viewInsets.bottom;
  //       //print("Application.keyboardHeightChatPage:${Application.keyboardHeightChatPage}");
  //       bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
  //     }
  //   }
  // }

  // @override
  // void startCanvasPage(bool isOpen) {
  //   //print("开始改变屏幕高度:${isOpen ? "打开" : "关闭"}");
  //   //print("_bottomSettingPanelState:$_bottomSettingPanelState,_emojiStateOld:$_emojiStateOld");
  //   if (isOpen) {
  //     if (!_emojiStateOld) {
  //       if (_bottomSettingPanelState != isOpen) {
  //         _bottomSettingPanelState = isOpen;
  //         bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
  //       }
  //     }
  //   } else {
  //     _bottomSettingPanelState = false;
  //     bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
  //   }
  //   if (isOpen) {
  //     _emojiStateOld = false;
  //   }
  // }

  // @override
  // void keyBoardHeightThanZero() {
  //   if (!_emojiStateOld) {
  //     if (MediaQuery.of(this.context).viewInsets.bottom > 0 && !_bottomSettingPanelState) {
  //       _focusNode.unfocus();
  //       //print("11111111111111111111111111");
  //     }
  //   }
  // }

  // @override
  // void secondListener() {
  //   if (scrollPositionPixels < 500 && chatDataList.length > 100) {
  //     List<ChatDataModel> list = [];
  //     list = chatDataList.sublist(0, 100);
  //     chatDataList.clear();
  //     chatDataList.addAll(list);
  //     EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
  //   }
  // }

  @override
  void endChangeKeyBoardHeight(bool isOpenKeyboard) {
    if (isOpenKeyboard) {
      if (Application.keyboardHeightChatPage != MediaQuery.of(this.context).viewInsets.bottom) {
        Application.keyboardHeightChatPage = MediaQuery.of(this.context).viewInsets.bottom;
        //print("Application.keyboardHeightChatPage:${Application.keyboardHeightChatPage}");
        bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
      }
    }
  }

  @override
  void startChangeKeyBoardHeight(bool isOpenKeyboard) {
    print("startChangeKeyBoardHeight:$isOpenKeyboard");
    _removeLongPanelCall();
    if (isOpenKeyboard) {
      if (!_emojiStateOld) {
        if (_bottomSettingPanelState != isOpenKeyboard) {
          _bottomSettingPanelState = isOpenKeyboard;
          bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
        }
      }
    } else {
      _bottomSettingPanelState = false;
      bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
    }
    if (isOpenKeyboard) {
      _emojiStateOld = false;
    }
  }

  //参加邀请的活动
  _joinByInvitationActivity(int activityId) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (activityId == null || activityId == 0) {
      ToastShow.show(msg: "活动id错误", context: context);
      return;
    }
    Navigator.of(context).pop();
    AppRouter.navigateActivityDetailPage(context, activityId, inviterId: int.parse(conversation.conversationId));
  }

  //进入活动
  _comeInActivity(int activityId) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (activityId == null || activityId == 0) {
      ToastShow.show(msg: "活动id错误", context: context);
      return;
    }
    Navigator.of(context).pop();
    AppRouter.navigateActivityDetailPage(context, activityId);
  }

  //获取消息是否免打扰和置顶
  _getConversationNotificationStatus() {
    //判断有没有置顶
    topChat = conversation.isTop == 1;

    //判断有没有免打扰
    if (MessageManager.queryNoPromptUidList == null || MessageManager.queryNoPromptUidList.length < 1) {
      disturbTheNews = false;
    } else {
      for (NoPromptUidModel noPromptUidModel in MessageManager.queryNoPromptUidList) {
        if (noPromptUidModel.type == GROUP_TYPE &&
            noPromptUidModel.targetId.toString() == this.conversation.conversationId) {
          disturbTheNews = true;
          break;
        }
      }
    }
  }


  //是活动群聊时展示功能按钮面板
  _showBottomSetting() {
    List<String> list = [];
    list.add("进入活动");
    list.add("查看活动群成员");
    list.add(topChat ? "取消置顶" : "置顶");
    list.add(disturbTheNews ? "取消免打扰" : "免打扰");
    list.add("退出群聊");
    openMoreBottomSheet(
      context: context,
      lists: list,
      onItemClickListener: (index) async {
        if (list[index] == "进入活动") {
          _comeInActivity(conversation.activityId);
        }
        if (list[index] == "查看活动群成员") {
          if (conversation.activityId != null) {
            AppRouter.navigateActivityUserPage(context, activityId: conversation.activityId);
          }
        } else if (list[index] == "置顶" || list[index] == "取消置顶") {
          setTopChatApi();
        } else if (list[index] == "免打扰" || list[index] == "取消免打扰") {
          setConversationNotificationStatus();
        } else if (list[index] == "退出群聊") {
          showAppDialog(context,
              title: "退出群聊",
              info: "你确定退出当前群聊吗?",
              cancel: AppDialogButton("取消", () {
                return true;
              }),
              confirm: AppDialogButton("确定", () {
                exitGroupChatPr();
                return true;
              }));
        }
      },
    );
  }

  //设置消息是否置顶
  void setTopChatApi() async {
    Loading.showLoading(context);
    topChat = !topChat;
    Map<String, dynamic> map =
        await (topChat ? stickChat : cancelTopChat)(targetId: int.parse(this.conversation.conversationId), type: 1);
    if (map != null && map["state"] != null && map["state"]) {
      TopChatModel topChatModel = new TopChatModel(type: 1, chatId: int.parse(this.conversation.conversationId));
      int index = TopChatModel.containsIndex(MessageManager.topChatModelList, topChatModel);
      if (topChat) {
        if (index < 0) {
          MessageManager.topChatModelList.add(topChatModel);
          conversation.isTop = 1;
          context.read<ConversationNotifier>().insertTop(conversation);
        }
      } else {
        if (index >= 0) {
          MessageManager.topChatModelList.removeAt(index);
          conversation.isTop = 0;
          context.read<ConversationNotifier>().insertCommon(conversation);
        }
      }
    } else {
      topChat = !topChat;
    }

    Loading.hideLoading(context);
  }


  //设置消息免打扰
  void setConversationNotificationStatus() async {
    Loading.showLoading(context);

    disturbTheNews = !disturbTheNews;
    //判断有没有免打扰
    Map<String, dynamic> map = await (disturbTheNews ? addNoPrompt : removeNoPrompt)(
        targetId: int.parse(this.conversation.conversationId), type: GROUP_TYPE);
    if (map != null && map["state"] != null && map["state"]) {
      NoPromptUidModel model =
          NoPromptUidModel(type: GROUP_TYPE, targetId: int.parse(this.conversation.conversationId));
      int index = NoPromptUidModel.containsIndex(MessageManager.queryNoPromptUidList, model);
      if (disturbTheNews) {
        if (index < 0) {
          MessageManager.queryNoPromptUidList.add(model);
        }
      } else {
        if (index >= 0) {
          MessageManager.queryNoPromptUidList.remove(index);
        }
      }
    } else {
      disturbTheNews = !disturbTheNews;
    }

    Loading.hideLoading(context);
  }


  //退出按钮-移除
  void exitGroupChatPr() async {
    Loading.showLoading(context);
    Map<String, dynamic> model = await exitGroupChat(groupChatId: int.parse(this.conversation.conversationId));
    Loading.hideLoading(context);
    if (model != null && model["state"] != null && model["state"]) {
      _moreOnClickExitChatPage();
      GroupChatUserInformationDBHelper().removeGroupAllInformation(this.conversation.conversationId);
      ToastShow.show(msg: "退出成功", context: context);
    } else {
      ToastShow.show(msg: "退出失败", context: context);
    }
  }
}

///------------------------------------各种点击事件  end-----------------------------------------------------------------------///}
