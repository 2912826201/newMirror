import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_enter_notifier.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/item/chat_bottom_Setting_box.dart';
import 'package:mirror/page/message/item/chat_page_ui.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'chat_details_body.dart';
import 'item/chat_at_user_name_list.dart';
import 'item/chat_more_icon.dart';
import 'item/chat_top_at_mark.dart';
import 'item/message_body_input.dart';
import 'item/message_input_bar.dart';
import 'package:provider/provider.dart';
import 'package:mirror/widget/should_build_keyboard.dart';

import 'message_view/message_item_height_util.dart';

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

  ChatPage(
      {Key key,
      @required this.conversation,
      this.shareMessage,
      this.chatDataList,
      this.systemLastTime,
      this.systemPage,
      this.context})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState(conversation, shareMessage, context, systemLastTime, systemPage, chatDataList);
  }
}

class ChatPageState extends XCState with TickerProviderStateMixin, WidgetsBindingObserver {
  final ConversationDto conversation;
  final Message shareMessage;
  final BuildContext _context;

  //所有的会话消息
  final List<ChatDataModel> chatDataList;

  String systemLastTime;
  int systemPage = 0;

  ChatPageState(
      this.conversation, this.shareMessage, this._context, this.systemLastTime, this.systemPage, this.chatDataList);

  //是否显示表情
  bool _emojiState = false;
  bool _emojiStateOld=false;
  bool _bottomSettingPanelState = false;

  //是不是显示语音按钮
  bool _isVoiceState = false;

  //输入框的监听
  TextEditingController _textController = TextEditingController();

  //输入框的焦点
  FocusNode _focusNode = new FocusNode();

  //输入框内是不是有字符--作用是来判断是否刷新界面
  bool isHaveTextLen = false;

  //列表的滑动监听
  ScrollController _scrollController = ScrollController();

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
  bool isHaveReceiveChatDataList = false;

  int userNumber = 0;

  int cursorIndexPr = -1;

  ScrollController textScrollController = ScrollController();

  // 大图预览组装数据
  List<DemoSourceEntity> sourceList = [];

  Widget editWidget;
  Widget topAttentionUiWidget;

  GlobalKey<ChatBottomSettingBoxState> bottomSettingChildKey = GlobalKey();
  GlobalKey<MessageInputBarState> messageInputBarChildKey = GlobalKey();
  GlobalKey<ChatTopAtMarkState> chatTopAtMarkChildKey = GlobalKey();
  GlobalKey<ChatDetailsBodyState> chatDetailsBodyChildKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    context.read<ChatMessageProfileNotifier>().setData(conversation.getType(), conversation.conversationId);

    if (conversation.getType() == RCConversationType.Group) {
      EventBus.getDefault().registerNoParameter(_resetCharPageBar, EVENTBUS_CHAT_PAGE, registerName: EVENTBUS_CHAT_BAR);
      EventBus.getDefault().registerSingleParameter(_judgeResetPage, EVENTBUS_CHAT_PAGE, registerName: CHAT_JOIN_EXIT);
      EventBus.getDefault().registerSingleParameter(_resetChatGroupUserModelList, EVENTBUS_CHAT_PAGE, registerName: RESET_CHAR_GROUP_USER_LIST);
    }
    EventBus.getDefault()
        .registerSingleParameter(resetSettingStatus, EVENTBUS_CHAT_PAGE, registerName: RESET_MSG_STATUS);
    EventBus.getDefault().registerSingleParameter(getReceiveMessages, EVENTBUS_CHAT_PAGE, registerName: CHAT_GET_MSG);
    EventBus.getDefault().registerSingleParameter(withdrawMessage, EVENTBUS_CHAT_PAGE, registerName: CHAT_WITHDRAW_MSG);
    if (conversation.getType() != RCConversationType.System) {
      initSetData();
      initTextController();
      initReleaseFeedInputFormatter();
    }
    initWidget();

    initScrollController();

    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ChatMessageProfileNotifier>().setData(conversation.getType(), conversation.conversationId);
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ChatPageUtil.init(context).getAppBar(conversation, _topMoreBtnClick),
      body: MessageInputBody(
        onTap: () => _messageInputBodyClick(),
        decoration: BoxDecoration(color: AppColor.bgWhite),
        child: Column(children: getBody()),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    _messageInputBodyClick();
    _scrollController.dispose();
    if (Application.appContext != null) {
      //清聊天未读数
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
      //清其他数据
      Application.appContext.read<VoiceSettingNotifier>().stop();
      Application.appContext.read<ChatMessageProfileNotifier>().clear();
      _textController.text = "";
      Application.appContext.read<ChatEnterNotifier>().clearRules();
    }
    if (conversation.getType() == RCConversationType.Group) {
      Application.appContext.read<GroupUserProfileNotifier>().clearAllUser();
      EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: EVENTBUS_CHAT_BAR);
      EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_JOIN_EXIT);
    }
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: RESET_MSG_STATUS);
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_GET_MSG);
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_WITHDRAW_MSG);

    deletePostCompleteMessage(conversation);
  }


  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("didChangeAppLifecycleState:$state");
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

  //获取显示的ui主体
  List<Widget> getBody() {
    List<Widget> bodyArray = [];

    //接收当前会话的新的消息
    bodyArray.add(topAttentionUiWidget);
    //添加主体聊天界面
    bodyArray.add(Expanded(
      child: SizedBox(
        child: Stack(
          fit: StackFit.expand,
          children: [
            getChatDetailsBody(),
            (conversation.type != GROUP_TYPE)
                ? Container()
                : ChatAtUserList(
                    isShow: context.read<ChatEnterNotifier>().keyWord == "@",
                    onItemClickListener: atListItemClick,
                    groupChatId: conversation.conversationId,
                  ),
          ],
        ),
      ),
    ));

    if (conversation.getType() != RCConversationType.System) {
      bodyArray.add(getMessageInputBar());
      bodyArray.add(ChatBottomSettingBox(
        key: bottomSettingChildKey,
        bottomSettingPanelState: _bottomSettingPanelState,
        emojiState: _emojiState,
        textController: _textController,
        callBackCursorIndexPr: (int cursorIndexPr) {
          this.cursorIndexPr = cursorIndexPr;
        },
        changTextLen: _changTextLen,
        deleteEditText: _deleteEditText,
        onSubmitClick: _onSubmitClick,
        textScrollController: textScrollController,
      ));
    }

    return bodyArray;
  }

  //获取列表内容
  Widget getChatDetailsBody() {
    bool isShowName = conversation.getType() == RCConversationType.Group;
    return ChatDetailsBody(
      key: chatDetailsBodyChildKey,
      chatTopAtMarkChildKey: chatTopAtMarkChildKey,
      scrollController: _scrollController,
      chatDataList: chatDataList,
      chatId: conversation.conversationId,
      vsync: this,
      onTap: _messageInputBodyClick,
      voidItemLongClickCallBack: onItemLongClickCallBack,
      voidMessageClickCallBack: onMessageClickCallBack,
      chatName: getChatName(),
      conversationDtoType: conversation.type,
      isPersonalButler: conversation.type == MANAGER_TYPE,
      isHaveAtMeMsg: isHaveAtMeMsg,
      loadStatus: loadStatus,
      isShowChatUserName: isShowName,
      onAtUiClickListener: onAtUiClickListener,
      firstEndCallback: firstEndCallbackListView,
    );
  }

  //输入框bar
  Widget getMessageInputBar() {
    return MessageInputBar(
      key: messageInputBarChildKey,
      voiceOnTap: _voiceOnTapClick,
      onEmojio: () {
        onEmojioClick();
      },
      isVoice: _isVoiceState,
      voiceFile: _voiceFile,
      edit: (context, size) {
        return editWidget;
      },
      value: _textController.text,
      more: ChatMoreIcon(
        isComMomButton: StringUtil.strNoEmpty(_textController.text) && Application.platform == 0,
        onTap: () {
          _onSubmitClick();
        },
        moreTap: () => onPicAndVideoBtnClick(),
        textController: _textController,
      ),
      id: null,
      type: null,
    );
  }

  //输入框bar内的edit
  Widget _editWidget() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 80.0,
          minHeight: 16.0,
          maxWidth: Platform.isIOS
              ? ScreenUtil.instance.screenWidthDp - 32 - 32 - 64
              : ScreenUtil.instance.screenWidthDp - 32 - 32 - 64 - 52 - 12),
      child: TextSpanField(
        onTap: () {
          _emojiStateOld=_emojiState;
          print("_emojiStateOld2:$_emojiStateOld");
          if (_emojiState) {
            _emojiState = !_emojiState;
            bottomSettingChildKey.currentState.setData(emojiState: _emojiState);
            _bottomSettingPanelState = true;
            bottomSettingChildKey.currentState.setBottomSettingPanelState(true);
            // Future.delayed(Duration(milliseconds: 200),(){
            //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
            //     _bottomSettingPanelState = false;
            //     bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
            //   }
            // });
          }else{
            pageHeightStopCanvas = true;
            oldKeyboardHeight = 0;
          }
        },
        onLongTap: () {
          _emojiStateOld=_emojiState;
          print("_emojiStateOld3:$_emojiStateOld");
          if (_emojiState) {
            _emojiState = !_emojiState;
            bottomSettingChildKey.currentState.setData(emojiState: _emojiState);
            _bottomSettingPanelState = true;
            bottomSettingChildKey.currentState.setBottomSettingPanelState(true);
            // Future.delayed(Duration(milliseconds: 200),(){
            //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
            //     _bottomSettingPanelState = false;
            //     bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
            //   }
            // });
          }else{
            pageHeightStopCanvas = true;
            oldKeyboardHeight = 0;
          }
        },
        scrollController: textScrollController,
        controller: _textController,
        focusNode: _focusNode,
        // 多行展示
        keyboardType: TextInputType.multiline,
        //不限制行数
        maxLines: null,
        enableInteractiveSelection: true,
        // 光标颜色
        cursorColor: Color.fromRGBO(253, 137, 140, 1),
        scrollPadding: EdgeInsets.all(0),
        style: TextStyle(
          fontSize: 16,
          color: AppColor.textPrimary1,
        ),
        //内容改变的回调
        onChanged: _changTextLen,
        textInputAction: TextInputAction.send,
        onSubmitted: (text) {
          if (ClickUtil.isFastClick(time: 200)) {
            return;
          }
          if (text.isNotEmpty) {
            _postText(text);
          }
          print("重新获取焦点");
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
          hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
          // 设置为true,contentPadding才会生效，TextField会有默认高度。
          isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 6, bottom: 4, left: 16, right: 16),
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
    context.read<ChatEnterNotifier>().changeCallback(text);
    bool isReset = false;
    if (text!=null&&text.length>0) {
      if (!isHaveTextLen) {
        isReset = true;
        isHaveTextLen = true;
      }
    } else {
      _textController.text = "";
      Application.appContext.read<ChatEnterNotifier>().clearRules();
      if (isHaveTextLen) {
        isReset = true;
        isHaveTextLen = false;
      }
    }
    if (isReset) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
        }
      });
    }
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

  //获取系统消息
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
        dataList.add(getMessage(getSystemMsg(v, conversation.type), isHaveAnimation: false));
      });
    }
    return dataList;
  }

  //判断加不加时间提示
  judgeAddAlertTime() {
    if (chatDataList.length > 0) {
      if (chatDataList[0].msg != null &&
          new DateTime.now().millisecondsSinceEpoch - chatDataList[0].msg.sentTime >= 5 * 60 * 1000) {
        chatDataList.insert(
            0, getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch, conversation.conversationId));
        if (recallNotificationMessagePosition > 0) {
          recallNotificationMessagePosition++;
        }
      }
    }else{
      chatDataList.insert(
          0, getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch, conversation.conversationId));
    }
  }

  //判断有没有at我的消息
  void judgeIsHaveAtMeMsg() {
    if (Application.atMesGroupModel == null || Application.atMesGroupModel.atMsgMap == null) {
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
    } else {
      atMeMsg = Application.atMesGroupModel.getAtMsg(conversation.conversationId);
      if (atMeMsg == null) {
        isHaveAtMeMsg = false;
        isHaveAtMeMsgPr = false;
      } else {
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        judgeNowChatIsHaveAt();
        chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
      }
    }
  }

  //判断当前屏幕内有没有at我的消息
  void judgeNowChatIsHaveAt() {
    isHaveAtMeMsgIndex = -1;
    if (chatDataList == null || chatDataList.length < 1) {
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
      Application.atMesGroupModel.remove(atMeMsg);
      chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
    } else {
      for (int i = 0; i < chatDataList.length; i++) {
        if (chatDataList[i].msg.messageUId == atMeMsg.messageUId) {
          //print("能找到id");
          isHaveAtMeMsgIndex = i;
          break;
        } else if (chatDataList[i].msg.sentTime < atMeMsg.sendTime) {
          //print("找不到id--匹配时间");
          isHaveAtMeMsg = false;
          isHaveAtMeMsgPr = false;
          Application.atMesGroupModel.remove(atMeMsg);
          chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
          break;
        }
      }
    }
  }

  //listview 当前显示的是第几个 回调
  void firstEndCallbackListView(int firstIndex, int lastIndex) {
    // print("firstIndex:$firstIndex,lastIndex:$lastIndex");
    if (ClickUtil.isFastClickFirstEndCallbackListView(time: 200)) {
      return;
    }
    if (isHaveAtMeMsgPr) {
      if (isHaveAtMeMsgIndex < 0) {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
      } else if (isHaveAtMeMsgIndex <= lastIndex) {
        if (isHaveAtMeMsg) {
          isHaveAtMeMsg = false;
          //print('2--------------------------关闭标识at');
        }
        //print('2--------------------------已经是关闭--关闭标识at');
        isHaveAtMeMsgPr = false;
        isHaveAtMeMsgIndex = -1;
        Application.atMesGroupModel.remove(atMeMsg);
        chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
      } else {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
          //print('3--------------------------显示标识at');
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
        chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
      }
    }
  }

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
            getTimeAlert(dataList, conversation.conversationId);
            print("value:${chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime}-----------");
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
          Application.atMesGroupModel.remove(atMeMsg);
          chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
          return;
        }
        if (isHaveAtMeMsgIndex > 0) {
          break;
        }
      }
    }

    if (!isHaveAtMeMsg) {
      return;
    }

    List<ChatDataModel> list = [];
    for (int i = 0; i < isHaveAtMeMsgIndex; i++) {
      list.add(chatDataList[i]);
    }
    bool isShowName = conversation.getType() == RCConversationType.Group;
    double messageHeight = MessageItemHeightUtil.init().getMessageHeight(list, isShowName);
    print("messageHeight:$messageHeight,_scrollController:${_scrollController.position.maxScrollExtent}");

    EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    Future.delayed(Duration(milliseconds: 100), () {
      _animateToTopHeight(scrollExtent: messageHeight - 50);
      Future.delayed(Duration(milliseconds: 200), () {
        chatDetailsBodyChildKey.currentState.setAtItemMessagePosition(isHaveAtMeMsgIndex);
        isHaveAtMeMsgIndex = -1;
        isHaveAtMeMsg = false;
        isHaveAtMeMsgPr = false;
        Application.atMesGroupModel.remove(atMeMsg);
        chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
      });
    });
  }

  //点击了at标识
  void onAtUiClickListener1() async {
    //print("点击了at标识1");
    if (isHaveAtMeMsg && isHaveAtMeMsgIndex > 0) {
      //print("滚动到第$isHaveAtMeMsgIndex个item位置");
    } else {
      //print("加载更多的item");
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
            getTimeAlert(dataList, conversation.conversationId);
            print("value:${chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime}-----------");
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
          Application.atMesGroupModel.remove(atMeMsg);
          chatTopAtMarkChildKey.currentState.setIsHaveAtMeMs(isHaveAtMeMsg);
          break;
        }

        if (mounted) {
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
        await Future.delayed(Duration(milliseconds: 100), () {
          try {
            animateToTop();
          } catch (e) {}
        });
        if (isHaveAtMeMsgIndex > 0) {
          //print("1滚动到第$isHaveAtMeMsgIndex个item位置");
          break;
        }
      }
    }
    if (isHaveAtMeMsg && isHaveAtMeMsgIndex > 0) {
      //print("滚动滚动滚动滚动滚动滚动滚动滚动滚动");
      //开启无限滚动直到滚动到那个位置
      while (isHaveAtMeMsg && isHaveAtMeMsgIndex > 0) {
        await Future.delayed(Duration(milliseconds: 50), () {
          //print("滚动次数+count：${count++}");
          try {
            animateToTop(milliseconds: 100);
          } catch (e) {
            //print("滚动报错了e:$e");
          }
        });
      }
    }
  }

  //刷新appbar
  void _resetCharPageBar() {
    if(mounted){
      Future.delayed(Duration(milliseconds: 100),(){
        reload((){});
      });
    }
  }

  //刷新输入框
  void _resetEditText() {
    Element e = findChild(context as Element, editWidget);
    if (e != null) {
      editWidget = _editWidget();
      e.owner.lockState(() {
        e.update(editWidget);
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
    judgeAddAlertTime();
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    animateToBottom();

    print("recallNotificationMessagePosition:$recallNotificationMessagePosition");
    if (recallNotificationMessagePosition >= 0) {
      _updateRecallNotificationMessage();
    } else {
      if (mounted) {
        _textController.text = "";
        _resetEditText();
        context.read<ChatEnterNotifier>().clearRules();
        isHaveTextLen = false;
        if (chatDataList.length > 100) {
          List<ChatDataModel> list = [];
          list = chatDataList.sublist(0, 100);
          chatDataList.clear();
          chatDataList.addAll(list);
        }
        EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
      }
    }

    print("chatDataList[0]:${chatDataList[0]}");
    postText(chatDataList[0], conversation.conversationId, conversation.getType(), mentionedInfo, () {
      context.read<ChatEnterNotifier>().clearRules();
      _textController.text = "";
      _resetEditText();
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
        print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        ByteData byteData = await selectedMediaFiles.list[i].croppedImage.toByteData(format: ui.ImageByteFormat.png);
        print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
        Uint8List picBytes = byteData.buffer.asUint8List();
        print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
        selectedMediaFiles.list[i].croppedImageData = picBytes;
      }
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.type = (selectedMediaFiles.type == mediaTypeKeyVideo
          ? ChatTypeModel.MESSAGE_TYPE_VIDEO
          : ChatTypeModel.MESSAGE_TYPE_IMAGE);
      chatDataModel.mediaFileModel = selectedMediaFiles.list[i];
      chatDataModel.isTemporary = true;
      chatDataModel.isHaveAnimation = true;
      modelList.add(chatDataModel);
      addTemporaryMessage(chatDataModel, conversation);
    }
    if (modelList != null) {
      judgeAddAlertTime();
      chatDataList.insertAll(0, modelList);
    }
    animateToBottom();
    if (mounted) {
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    postImgOrVideo(modelList, conversation.conversationId, selectedMediaFiles.type, conversation.getType(), () {
      // modelList.forEach((element) {
      //
      //   List list=[];
      //   list.add(0);
      //   list.add(element.id);
      //   EventBus.getDefault().post(msg:list,registerName: CHAT_EVERY_MESSAGE);
      //   // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      // });

      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  //发送录音
  _voiceFile(String path, int time) async {
    ChatDataModel chatDataModel = new ChatDataModel();
    ChatVoiceModel voiceModel = new ChatVoiceModel();
    voiceModel.filePath = path;
    voiceModel.longTime = time;
    voiceModel.read = 0;
    chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_VOICE;
    chatDataModel.chatVoiceModel = voiceModel;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = true;
    judgeAddAlertTime();
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    animateToBottom();
    if (mounted) {
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    // print("conversation.conversationId:${conversation.conversationId},${conversation.getType()}");
    postVoice(chatDataList[0], conversation.conversationId, conversation.getType(), () {
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
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
    judgeAddAlertTime();
    chatDataList.insert(0, chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    animateToBottom();
    if (mounted) {
      _textController.text = "";
      isHaveTextLen = false;
      if (chatDataList.length > 100) {
        List<ChatDataModel> list = [];
        list = chatDataList.sublist(0, 100);
        chatDataList.clear();
        chatDataList.addAll(list);
      }
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
      EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
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
      MessageManager.updateConversationByMessageList(context, [chatDataList[position].msg]);
      if (mounted) {
        EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
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
          isHaveTextLen = false;
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
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
        ChatDataModel chatDataModel = new ChatDataModel();
        chatDataModel.msg = msg;
        chatDataModel.isTemporary = false;
        chatDataModel.isHaveAnimation = false;
        chatDataList.insert(0, chatDataModel);
        if (mounted) {
          isShowTopAttentionUi = true;
          _resetShowTopAttentionUi();
          _textController.text = "";
          isHaveTextLen = false;
          recallNotificationMessagePosition = -1;
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
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
          chatDataList[position].type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        _resetPostTemporaryImageVideo(position);
      } else {
        ToastShow.show(msg: "未处理：${chatDataList[position].type}", context: _context);
      }
    } else if (chatDataList[position].msg.objectName == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      TextMessage textMessage = ((chatDataList[position].msg.content) as TextMessage);
      print("textMessage.content:${textMessage.content}");
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE ||
          mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        if (mapModel["isTemporary"] != null && mapModel["isTemporary"]) {
          _resetPostMessageTemporaryImageVideo(position, map);
          return;
        }
      }
    }
    _resetPostMsg(position);
  }

  //重新发送临时的图片视频
  void _resetPostTemporaryImageVideo(int position) {
    chatDataList.insert(0, chatDataList[position]);
    chatDataList.removeAt(position + 1);
    List<ChatDataModel> modelList = <ChatDataModel>[];
    modelList.add(chatDataList[0]);
    String type = mediaTypeKeyVideo;
    if (chatDataList[0].type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      type = mediaTypeKeyImage;
    }
    chatDataList[0].isTemporary = false;
    deletePostCompleteMessage(conversation);
    chatDataList[0].isTemporary = true;
    addTemporaryMessage(chatDataList[0], conversation);
    postImgOrVideo(modelList, conversation.conversationId, type, conversation.getType(), () {
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
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
    chatDataModel.isHaveAnimation = true;

    chatDataList[position].isTemporary = false;
    deletePostCompleteMessage(conversation);
    chatDataList.removeAt(position);

    List<ChatDataModel> modelList = <ChatDataModel>[];
    modelList.add(chatDataModel);
    addTemporaryMessage(chatDataModel, conversation);
    if (modelList != null) {
      judgeAddAlertTime();
      chatDataList.insertAll(0, modelList);
    }
    animateToBottom();
    if (mounted) {
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    postImgOrVideo(modelList, conversation.conversationId, mediaFileModel.type, conversation.getType(), () {
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  //重新发送融云数据的正常消息
  void _resetPostMsg(int position) {
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.isTemporary = false;
    chatDataModel.isHaveAnimation = true;
    chatDataModel.msg = chatDataList[position].msg;
    chatDataModel.msg.sentStatus = 10;
    chatDataModel.msg.sentTime = new DateTime.now().millisecondsSinceEpoch;
    judgeAddAlertTime();
    chatDataList.removeAt(position);
    chatDataList.insert(0, chatDataModel);
    animateToBottom();

    if (mounted) {
      _textController.text = "";
      isHaveTextLen = false;
      EventBus.getDefault().post(registerName: CHAT_BOTTOM_MORE_BTN);
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    resetPostMessage(chatDataList[0], () {
      // EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    });
  }

  ///------------------------------------发送消息  end-----------------------------------------------------------------------///
  ///------------------------------------一些功能 方法  start-----------------------------------------------------------------------///

  //设置消息的状态
  void resetSettingStatus(List<int> list) {
    if (list == null || list.length < 2) {
      return;
    }
    int messageId = list[0];
    int status = list[1];
    print("更新消息状态-----------messageId：$messageId, status:$status");
    if (messageId == null || status == null || chatDataList == null || chatDataList.length < 1) {
      return;
    } else {
      for (ChatDataModel dataModel in chatDataList) {
        if (dataModel.msg?.messageId == messageId) {
          if (dataModel.msg?.sentStatus == status) {
            return;
          } else {
            dataModel.msg?.sentStatus = status;
            if (status == RCSentStatus.Failed) {
              profileCheckBlack();
            } else if (status == RCSentStatus.Sent) {
              getHistoryMessage(dataModel);
            }
            EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
            return;
          }
        }
      }
    }
  }

  void withdrawMessage(Message message){
    if (message == null) {
      return;
    }
    if (message.targetId != conversation.conversationId) {
      return;
    }
    if(message.conversationType != conversation.getType()){
      return;
    }
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      //撤回消息
      for (ChatDataModel model in chatDataList) {
        if (model.msg.messageUId == message.messageUId) {
          model.msg = message;
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
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
    if (message.targetId != conversation.conversationId) {
      return;
    }
    if(message.conversationType != conversation.getType()){
      return;
    }

    //当进入聊天界面,没有任何聊天记录,这时对方给我发消息就可能会照成崩溃
    if (chatDataList.length > 0 && message.messageUId == chatDataList[0].msg.messageUId) {
      return;
    }
    ChatDataModel chatDataModel = getMessage(message, isHaveAnimation: scrollPositionPixels < 500);
    print("scrollPositionPixels：$scrollPositionPixels");
    judgeAddAlertTime();
    chatDataList.insert(0, chatDataModel);
    insertSourceList(chatDataModel);
    //判断是不是群通知
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF &&
        conversation.getType() == RCConversationType.Group) {
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
    isHaveReceiveChatDataList = true;
    if (scrollPositionPixels < 500) {
      isHaveReceiveChatDataList = false;
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
    //清聊天未读数
    ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
  }

  // 大图预览插入数据
  insertSourceList(ChatDataModel model) {
    print("插入数据前sourceList：：${sourceList.length} ———————— ${sourceList.toString()}");
    if (model.msg.objectName == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      TextMessage textMessage = ((model.msg.content) as TextMessage);
      try {
        Map<String, dynamic> mapModel = json.decode(textMessage.content);
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        String imageUrl = map["showImageUrl"];
        if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
          DemoSourceEntity demoSourceEntity = DemoSourceEntity("${model.msg.messageId}", 'image', imageUrl);
          sourceList.add(demoSourceEntity);
        }
        if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
          DemoSourceEntity demoSourceEntity = DemoSourceEntity("${model.msg.messageId}", 'video', imageUrl);
          sourceList.add(demoSourceEntity);
        }
      } catch (e) {
        // return getTextMsg(text: "2版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo);
      }
    }
    print("插入数据后sourceList：：${sourceList.length} ____ ${sourceList.toString()}");
  }

  //获取数据库内的messageUId
  void getHistoryMessage(ChatDataModel model) async {
    if (null == model.msg.messageUId || model.msg.messageUId.length < 1) {
      model.msg = await Application.rongCloud.getMessageById(model.msg.messageId);
    }
  }

//判断是否退出群聊或者加入群聊
  void _judgeResetPage(Message message) {
    print("判断是否退出群聊或者加入群聊");

    if (message == null) {
      print(message == null);
      return;
    }
    Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
    if (dataMap["groupChatId"].toString() != conversation.conversationId) {
      print("message.targetId:${message.targetId},${conversation.conversationId}");
      return;
    }
    _resetChatGroupUserModelList(message);
    print("dataMap[subType]0:${dataMap["subType"]}");
    if(dataMap["subType"]==0||dataMap["subType"]==2) {
      print("dataMap[subType]0:${dataMap["subType"]}");
      insertExitGroupMsg(message, conversation.conversationId, (Message msg, int code) {
        if (code == 0) {
          print("scrollPositionPixels加入：$scrollPositionPixels");
          chatDataList.insert(0, getMessage(msg, isHaveAnimation: scrollPositionPixels < 500));
          isHaveReceiveChatDataList = true;
          if (scrollPositionPixels < 500) {
            isHaveReceiveChatDataList = false;

            EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
          }
        }
      });
    }else{
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
  }

  //重新刷新群聊人数
  void _resetChatGroupUserModelList(Message message){
    if (message == null) {
      return;
    }
    Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
    if (dataMap["groupChatId"].toString() != conversation.conversationId) {
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
    editWidget = _editWidget();
  }

  initScrollController() {
    _scrollController.addListener(() {
      scrollPositionPixels = _scrollController.position.pixels;
      // print("scrollPositionPixels3：$scrollPositionPixels");
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (loadStatus == LoadingStatus.STATUS_IDEL) {
          // 先设置状态，防止下拉就直接加载reload
          if (mounted) {
            loadStatus = LoadingStatus.STATUS_LOADING;
            chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
          }
          if (conversation.getType() != RCConversationType.System) {
            _onRefresh();
          } else {
            _onRefreshSystemInformation();
          }
        }
      } else if (_scrollController.position.pixels <= 0) {
        if (mounted && isHaveReceiveChatDataList) {
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
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
      // print("值改变了");
      print("监听文字光标${_textController.selection}");

      List<Rule> rules = context.read<ChatEnterNotifier>().rules;
      int atIndex = context.read<ChatEnterNotifier>().atCursorIndex;
      print("当前值￥${_textController.text}");
      print(context.read<ChatEnterNotifier>().textFieldStr);
      // 获取光标位置
      int cursorIndex = _textController.selection.baseOffset;
      print("实时光标位置$cursorIndex");
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
        print("at位置&$atIndex");
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
            EventBus.getDefault().post(registerName: CHAT_AT_GROUP_PANEL);
          }
        }
      }
      isSwitchCursor = true;
    });
  }

  initReleaseFeedInputFormatter() {
    _formatter = ReleaseFeedInputFormatter(
      controller: _textController,
      maxNumberOfBytes: 6000,
      correctRulesListener: () {
        _resetEditText();
      },
      rules: context.read<ChatEnterNotifier>().rules,
      // @回调
      triggerAtCallback: (String str) async {
        print("打开@功能--str：$str------------------------");
        bool isHaveUser=true;
        if (context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0) {
          if (context.watch<GroupUserProfileNotifier>().isNoHaveMe()) {
            isHaveUser=false;
          }
        } else {
          if (Application.chatGroupUserInformationMap["${conversation.conversationId}_${Application.profile.uid}"] ==
              null) {
            isHaveUser=false;
          }
        }
        if(isHaveUser) {
          if (conversation.getType() == RCConversationType.Group) {
            context.read<ChatEnterNotifier>().openAtCallback(str);
            isClickAtUser = false;
            EventBus.getDefault().post(registerName: CHAT_AT_GROUP_PANEL);
          }
        }
        return "";
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        print("取消艾特功能3");
        print('----------------------------关闭视图');
        context.read<ChatEnterNotifier>().openAtCallback("");
        EventBus.getDefault().post(registerName: CHAT_AT_GROUP_PANEL);
      },
      valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
          String topicSearchStr, bool isAdd) {
        rules = rules;
        // //print("输入框值回调：$value");
        // //print(rules);
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

  //滚动到底部
  void animateToBottom() {
    try {
      _scrollController.animateTo(0.0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    } catch (e) {}
  }

  //向上滚动
  void animateToTop({int milliseconds = 200}) {
    if (isHaveAtMeMsgIndex < 0) {
      oldMaxScrollExtent = _scrollController.position.maxScrollExtent;
    } else {
      oldMaxScrollExtent += 100.0;
    }
    _scrollController.animateTo(oldMaxScrollExtent,
        duration: Duration(milliseconds: milliseconds), curve: Curves.easeInOut);
  }

  //向上滚动
  void _animateToTopHeight({int milliseconds = 200, double scrollExtent}) {
    _scrollController.animateTo(scrollExtent, duration: Duration(milliseconds: milliseconds), curve: Curves.easeInOut);
  }

  //检查黑名单状态
  void profileCheckBlack() async {
    print("-------------------------");
    if (conversation.type == PRIVATE_TYPE) {
      print("22222222222222222");
      BlackModel blackModel = await ProfileCheckBlack(int.parse(conversation.conversationId));
      print("blackModel:${blackModel?.toJson().toString()}");
      if (blackModel != null) {
        if (blackModel.inYouBlack == 1) {
          print("发送失败，你已将对方加入黑名单");
          ToastShow.show(msg: "发送失败，你已将对方加入黑名单", context: _context,gravity: 1);
        } else if (blackModel.inThisBlack == 1) {
          print("发送失败，你已被对方加入黑名单");
          ToastShow.show(msg: "发送失败，你已被对方加入黑名单", context: _context,gravity: 1);
        }
      }
    }
  }

  ///------------------------------------一些功能 方法  end-----------------------------------------------------------------------///
  ///------------------------------------各种点击事件  start-----------------------------------------------------------------------///

  //聊天内容的点击事件
  _messageInputBodyClick() {
    print("_messageInputBodyClick");
    try{
      if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0 || _bottomSettingPanelState) {
        _emojiStateOld=false;
        print("_emojiStateOld1:$_emojiStateOld");

        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).requestFocus(new FocusNode());
        }

        _bottomSettingPanelState = false;
        bottomSettingChildKey.currentState.bottomSettingPanelState = false;
        if (_emojiState) {
          _emojiState = false;
          bottomSettingChildKey.currentState.setData(
            bottomSettingPanelState: false,
            emojiState: _emojiState,
          );
        } else {
          bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
        }
      }
    }catch (e){}
  }

  //表情的点击事件
  void onEmojioClick() {
    if (_focusNode.hasFocus) {
      cursorIndexPr = _textController.selection.baseOffset;
      bottomSettingChildKey.currentState.setCursorIndexPr(cursorIndexPr);
      _focusNode.unfocus();
    }
    _emojiState = !_emojiState;
    bottomSettingChildKey.currentState.setEmojiState(_emojiState);
    _isVoiceState = false;
    messageInputBarChildKey.currentState.setIsVoice(_isVoiceState);
  }

  //图片的点击事件
  onPicAndVideoBtnClick() {
    //print("=====图片的点击事件");
    _messageInputBodyClick();
    SelectedMediaFiles selectedMediaFiles = new SelectedMediaFiles();
    AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, false, startPageGallery, false, (result) async {
      SelectedMediaFiles files = Application.selectedMediaFiles;
      if (true != result || files == null) {
        //print("没有选择媒体文件");
        return;
      }
      Application.selectedMediaFiles = null;
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
    await [Permission.microphone].request();
    bool isGranted = (await Permission.microphone.status)?.isGranted;
    if(isGranted) {
      _focusNode.unfocus();
      _isVoiceState = !_isVoiceState;
      messageInputBarChildKey.currentState.setIsVoice(_isVoiceState);
      if (_emojiState) {
        _emojiState = false;
        bottomSettingChildKey.currentState.setEmojiState(_emojiState);
      }
    }
  }

  //头部-更多按钮的点击事件
  _topMoreBtnClick() {
    // Message msg = chatDataList[chatDataList.length - 2].msg;
    // AtMsg atMsg = new AtMsg(groupId: int.parse(msg.targetId), sendTime: msg.sentTime, messageUId: msg.messageUId);
    // Application.atMesGroupModel.add(atMsg);
    _messageInputBodyClick();
    judgeJumpPage(conversation.getType(), this.conversation.conversationId, conversation.type, context, getChatName(),
        _morePageOnClick, _moreOnClickExitChatPage, conversation.id);
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
      print("修改了用户名");
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    } else if (type == 1) {
      conversation.name = name;
      //修改了群名
      // _postUpdateGroupName(name);
      context.read<ConversationNotifier>().updateConversationName(name, conversation);
      EventBus.getDefault().post(registerName: EVENTBUS_CHAT_BAR);
    } else if (type == 2) {
      //拉黑
      _insertMessageMenu("你拉黑了这个用户!");
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
              .profileUiChangeModel
              .containsKey(int.parse(conversation.conversationId))) {
            print('=================个人主页同步');
            context.read<UserInteractiveNotifier>().changeIsFollow(true, false, int.parse(conversation.conversationId));
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
    // //print("+++++++++++++++++++++++++++++++++++++++++++++++++++" + content);
    // At的文字长度
    int atLength = userModel.nickName.length + 1;
    // 获取输入框内的规则
    var rules = context.read<ChatEnterNotifier>().rules;
    // 检测是否添加过
    if (rules.isNotEmpty) {
      for (Rule rule in rules) {
        if (rule.clickIndex == userModel.uid && rule.isAt == true) {
          ToastShow.show(msg: "你已经@过Ta啦！", context: _context, gravity: Toast.CENTER);
          //print("你已经@过Ta啦！");
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
    //print(searchStr);
    //print("controller.text:${_textController.text}");
    //print("atBeforeStr$atBeforeStr");
    // isSwitchCursor = false;
    if (searchStr != "" && searchStr != null && searchStr.isNotEmpty) {
      //print("atIndex:$atIndex");
      //print("searchStr:$searchStr");
      //print("controller.text:${_textController.text}");
      atRearStr = _textController.text.substring(atIndex + searchStr.length, _textController.text.length);
      //print("atRearStr:$atRearStr");
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
    //print("controller.text:${_textController.text}");
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
        //print("进入");
        //print(rules[i]);
        rules[i] = Rule(rules[i].startIndex + atLength, rules[i].endIndex + atLength, rules[i].params,
            rules[i].clickIndex, rules[i].isAt);
        //print(rules[i]);
      }
    }
    // 存储规则
    context
        .read<ChatEnterNotifier>()
        .addRules(Rule(atIndex - 1, atIndex + atLength, "@" + userModel.nickName + " ", userModel.uid, true));

    print("取消艾特功能4");
    context.read<ChatEnterNotifier>().setAtSearchStr("");
    // 关闭视图
    context.read<ChatEnterNotifier>().openAtCallback("");
    EventBus.getDefault().post(registerName: CHAT_AT_GROUP_PANEL);
    _resetEditText();
  }

  //刷新数据--加载更多以前的数据
  _onRefresh() async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(conversation.getType(), conversation.conversationId,
        chatDataList[chatDataList.length - 1].msg.sentTime, chatAddHistoryMessageCount, 0);
    List<ChatDataModel> dataList = <ChatDataModel>[];
    if (msgList != null && msgList.length > 1) {
      dataList.clear();
      for (int i = 1; i < msgList.length; i++) {
        dataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
      if (dataList != null && dataList.length > 0) {
        getTimeAlert(dataList, conversation.conversationId);
        print("value:${chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime}-----------");
        if (chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime < 5 * 60 * 1000) {
          chatDataList.removeAt(chatDataList.length - 1);
        }
        chatDataList.addAll(dataList);
      }
      //判断有没有艾特我的消息
      if (isHaveAtMeMsg || isHaveAtMeMsgPr) {
        judgeNowChatIsHaveAt();
      }
      loadStatus = LoadingStatus.STATUS_IDEL;
    } else {
      // 加载完毕
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
    EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
  }

  //加载更多的系统消息
  _onRefreshSystemInformation() async {
    List<ChatDataModel> dataList = await getSystemInformationNet();
    if (dataList != null && dataList.length > 0) {
      getTimeAlert(dataList, conversation.conversationId);
      if (chatDataList[chatDataList.length - 2].msg.sentTime - dataList[0].msg.sentTime < 5 * 60 * 1000) {
        chatDataList.removeAt(chatDataList.length - 1);
      }
      chatDataList.addAll(dataList);

      loadStatus = LoadingStatus.STATUS_IDEL;
    } else {
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    chatDetailsBodyChildKey.currentState.setLoadStatus(loadStatus);
  }

  //所有的item长按事件
  void onItemLongClickCallBack(
      {int position, String settingType, Map<String, dynamic> map, String contentType, String content}) {
    if (conversation.type == MANAGER_TYPE && position != null) {
      position--;
    }

    if (settingType == null || settingType.isEmpty || settingType.length < 1) {
      //print("暂无此配置");
    } else if (settingType == "删除") {
      RongCloud.init().deleteMessageById(chatDataList[position].msg, (code) {
        //print("====" + code.toString());
        updateMessagePageAlert(conversation, context);
        if (mounted) {
          chatDataList.removeAt(position);
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      });
      // ToastShow.show(msg: "删除-第$position个", context: _context);
    } else if (settingType == "撤回") {
      recallMessage(chatDataList[position].msg, position);
    } else if (settingType == "复制") {
      if (context != null && content != null) {
        Clipboard.setData(ClipboardData(text: content));
        ToastShow.show(msg: "复制成功", context: _context);
      }
    } else {
      //print("暂无此配置");
    }
    //print("position:$position-----------------------------------------");
    // //print("position：$position--$contentType---${content==null?map.toString():content}----${chatDataList[position].msg.toString()}");
  }

  //所有的item点击事件
  void onMessageClickCallBack(
      {String contentType, String content, int position, Map<String, dynamic> map, bool isUrl, String msgId}) {
    if (conversation.type == MANAGER_TYPE && position != null) {
      position--;
    }

    if (contentType == null || contentType.isEmpty || contentType.length < 1) {
      //print("暂无此配置");
    }
    if (contentType == ChatTypeModel.MESSAGE_TYPE_TEXT && isUrl) {
      _launchUrl(content);
      // ToastShow.show(msg: "跳转网页地址: $content", context: _context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_FEED) {
      // ToastShow.show(msg: "跳转动态详情页", context: context);
      getFeedDetail(map["id"], context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_USER) {
      // ToastShow.show(msg: "跳转用户界面", context: _context);
      _messageInputBodyClick();
      AppRouter.navigateToMineDetail(context, map["uid"], avatarUrl: map["avatarUri"], userName: map["nikeName"],
          callback: (dynamic result) {
        print("result:$result");
        getRelation();
      });
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
      // ToastShow.show(msg: "跳转直播课详情界面", context: _context);
      LiveVideoModel liveModel = LiveVideoModel.fromJson(map);
      AppRouter.navigateToLiveDetail(context, liveModel.id,
          heroTag: msgId, liveModel: liveModel, isHaveStartTime: false);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
      // ToastShow.show(msg: "跳转视频课详情界面", context: _context);
      LiveVideoModel videoModel = LiveVideoModel.fromJson(map);
      AppRouter.navigateToVideoDetail(context, videoModel.id, heroTag: msgId, videoModel: videoModel);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // ToastShow.show(msg: "播放录音", context: _context);
      updateMessage(chatDataList[position], (code) {
        if (mounted) {
          EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
        }
      });
    } else if (contentType == RecallNotificationMessage.objectName) {
      recallNotificationMessagePosition = -2;
      print("position:$position");
      // ToastShow.show(msg: "重新编辑消息", context: _context);
      // FocusScope.of(context).requestFocus(_focusNode);
      _textController.text += json.decode(map["content"])["data"];
      Future.delayed(Duration(milliseconds: 100), () {
        textScrollController.jumpTo(textScrollController.position.maxScrollExtent);
      });
      if (Application.platform == 0) {
        var setCursor = TextSelection(
          baseOffset: _textController.text.length,
          extentOffset: _textController.text.length,
        );
        _textController.selection = setCursor;
      }
    } else if (contentType == ChatTypeModel.CHAT_SYSTEM_BOTTOM_BAR) {
      ToastShow.show(msg: "管家界面-底部点击了：$content", context: _context);
      _postSelectMessage(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      ToastShow.show(msg: "选择列表选择了-底部点击了：$content", context: _context);
      if (ClickUtil.isFastClick(time: 200)) {
        return;
      }
      // _textController.text=content;
      _postText(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_CLICK_ERROR_BTN) {
      print("点击了发送失败的按钮-重新发送：$position");

      // profileCheckBlack();
      _resetPostMessage(position);
      // _textController.text=content;
      // _postText(content);
    } else {
      //print("暂无此类型");
    }
  }

  // 打开大图预览
  _openGallery(int position) {
    sourceList.clear();
    for (int i = chatDataList.length - 1; i >= 0; i--) {
      ChatDataModel v = chatDataList[i];
      if (v.msg != null) {
        String msgType = v.msg.objectName;
        print("消息类型：$msgType");
        if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
          TextMessage textMessage = ((v.msg.content) as TextMessage);
          try {
            Map<String, dynamic> mapModel = json.decode(textMessage.content);
            Map<String, dynamic> map = json.decode(mapModel["data"]);
            String imageUrl = map["showImageUrl"];
            if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
              DemoSourceEntity demoSourceEntity = DemoSourceEntity("${v.msg.messageId}", 'image', imageUrl);
              sourceList.add(demoSourceEntity);
            }
            if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
              DemoSourceEntity demoSourceEntity = DemoSourceEntity("${v.msg.messageId}", 'video', imageUrl);
              sourceList.add(demoSourceEntity);
            }
          } catch (e) {
            // ToastShow.show(msg: "版本过低请升级版本!", context: _context,gravity: Toast.CENTER);
            // return getTextMsg(text: "2版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo);
          }
        }
      }
    }
    print("查看sourceList长度：${sourceList.length} ------ ${sourceList.toString()}");
    int initIndex = 0;
    print("position::$position");
    print("当前点击的messageID：${chatDataList[position].msg.messageId}");
    for (int i = sourceList.length - 1; i >= 0; i--) {
      DemoSourceEntity source = sourceList[i];
      if (int.parse(source.heroId) == chatDataList[position].msg.messageId) {
        initIndex = i;
      }
    }
    print("图片索引值:$initIndex");
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        builder: (BuildContext context) => InteractiveviewerGallery<DemoSourceEntity>(
            sources: sourceList, initIndex: initIndex, itemBuilder: itemBuilder),
      ),
    );
  }

// 大图预览内部的Item
  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    DemoSourceEntity sourceEntity = sourceList[index];
    print("____sourceEntity:${sourceEntity.toString()}");
    if (sourceEntity.type == 'video') {
      return DemoVideoItem(
        sourceEntity,
        isFocus: isFocus,
      );
    } else {
      return DemoImageItem(sourceEntity);
    }
  }

  _launchUrl(String url) async {
    if (!(url.contains("http://") || url.contains("https://"))) {
      url = "https://" + url;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void endCanvasPage() {
    print("停止改变屏幕高度");
    if (MediaQuery.of(this.context).viewInsets.bottom > 0) {
      if (Application.keyboardHeightChatPage != MediaQuery.of(this.context).viewInsets.bottom) {
        Application.keyboardHeightChatPage = MediaQuery.of(this.context).viewInsets.bottom;
        print("Application.keyboardHeightChatPage:${Application.keyboardHeightChatPage}");
        bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
      }
    }
  }

  @override
  void startCanvasPage(bool isOpen) {
    print("开始改变屏幕高度:${isOpen ? "打开" : "关闭"}");
    print("_bottomSettingPanelState:$_bottomSettingPanelState,_emojiStateOld:$_emojiStateOld");
    if(isOpen){
      if(!_emojiStateOld){
        if (_bottomSettingPanelState != isOpen) {
          _bottomSettingPanelState = isOpen;
          bottomSettingChildKey.currentState.setBottomSettingPanelState(_bottomSettingPanelState);
        }
      }
    }else{
      _bottomSettingPanelState = false;
      bottomSettingChildKey.currentState.setBottomSettingPanelState(false);
    }
    if(isOpen){
      _emojiStateOld=false;
    }
  }

  @override
  void keyBoardHeightThanZero() {
    if(!_emojiStateOld) {
      if (MediaQuery
          .of(this.context)
          .viewInsets
          .bottom > 0 && !_bottomSettingPanelState) {
        _focusNode.unfocus();
      }
    }
  }

  @override
  void secondListener() {
    if (scrollPositionPixels < 500 && chatDataList.length > 100) {
      List<ChatDataModel> list = [];
      list = chatDataList.sublist(0, 100);
      chatDataList.clear();
      chatDataList.addAll(list);
      EventBus.getDefault().post(registerName: CHAT_PAGE_LIST_MESSAGE_RESET);
    }
  }
}

///------------------------------------各种点击事件  end-----------------------------------------------------------------------///}


