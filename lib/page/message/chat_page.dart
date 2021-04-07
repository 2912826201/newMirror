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
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/item/chat_page_ui.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:toast/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'chat_details_body.dart';
import 'item/chat_at_user_name_list.dart';
import 'item/chat_more_icon.dart';
import 'item/emoji_manager.dart';
import 'item/message_body_input.dart';
import 'item/message_input_bar.dart';
import 'package:provider/provider.dart';
import 'package:mirror/widget/should_build_keyboard.dart';

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

  ChatPage({Key key,
    @required this.conversation,
    this.shareMessage,
    this.chatDataList,
    this.systemLastTime,
    this.systemPage,
    this.context}
      ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState(conversation, shareMessage,context,systemLastTime,systemPage,chatDataList);
  }
}

class ChatPageState extends XCState with TickerProviderStateMixin, WidgetsBindingObserver {
  final ConversationDto conversation;
  final Message shareMessage;
  final BuildContext _context;
  ///所有的会话消息
  final List<ChatDataModel> chatDataList;

  String systemLastTime;
  int systemPage = 0;

  ChatPageState(
      this.conversation,
      this.shareMessage,
      this._context,
      this.systemLastTime,
      this.systemPage,
      this.chatDataList);



  ///是否显示表情
  bool _emojiState = false;
  bool _bottomSettingPanelState = false;

  ///是不是显示语音按钮
  bool _isVoiceState = false;

  ///输入框的监听
  TextEditingController _textController = TextEditingController();

  ///输入框的焦点
  FocusNode _focusNode = new FocusNode();

  ///输入框内是不是有字符--作用是来判断是否刷新界面
  bool isHaveTextLen = false;

  ///列表的滑动监听
  ScrollController _scrollController = ScrollController();

  ///界面能不能被输入法顶起
  // bool isResizeToAvoidBottomInset = true;

  ///表情的列表
  List<EmojiModel> emojiModelList = <EmojiModel>[];


  // 是否点击了弹起的@用户列表
  bool isClickAtUser = false;


  // 判断是否只是切换光标
  bool isSwitchCursor = true;
  ReleaseFeedInputFormatter _formatter;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

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

  // 加载中默认文字
  String loadText = "加载中...";

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

  // bool isShowEmjiPageWhite=false;

  ScrollController textScrollController = ScrollController();

  bool isShowHaveAnimation=false;


  // 大图预览组装数据
  List<DemoSourceEntity> sourceList = [];


  bool isShowTopFirst=true;


  Widget appbarWidget;


  @override
  void initState() {
    super.initState();

    context.read<ChatMessageProfileNotifier>().setData(conversation.getType(), conversation.conversationId);
    context.read<ChatMessageProfileNotifier>().isResetPage = false;


    if (conversation.getType() == RCConversationType.Group) {
      EventBus.getDefault().registerNoParameter(_resetCharPageBar, EVENTBUS_CHAT_PAGE,registerName: EVENTBUS_CHAT_BAR);
      EventBus.getDefault().registerSingleParameter(_judgeResetPage, EVENTBUS_CHAT_PAGE,registerName: CHAT_JOIN_EXIT);
    }
    EventBus.getDefault().registerSingleParameter(resetSettingStatus, EVENTBUS_CHAT_PAGE,registerName: RESET_MSG_STATUS);
    EventBus.getDefault().registerSingleParameter(getReceiveMessages, EVENTBUS_CHAT_PAGE,registerName: CHAT_GET_MSG);
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
  Widget shouldBuild(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appbarWidget,
        body: MessageInputBody(
          onTap: () => _messageInputBodyClick(),
          decoration: BoxDecoration(color: AppColor.bgWhite),
          child: Column(children: getBody()),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    if (Application.appContext != null) {
      //清聊天未读数
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
      //清其他数据
      Application.appContext.read<GroupUserProfileNotifier>().clearAllUser();
      Application.appContext.read<VoiceSettingNotifier>().stop();
      Application.appContext.read<ChatMessageProfileNotifier>().clear();
      _textController.text = "";
      Application.appContext.read<ChatEnterNotifier>().clearRules();
    }

    if (conversation.getType() == RCConversationType.Group) {
      EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE,registerName: EVENTBUS_CHAT_BAR);
      EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE,registerName: CHAT_JOIN_EXIT);
    }
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE,registerName: RESET_MSG_STATUS);
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE,registerName: CHAT_GET_MSG);

    deletePostCompleteMessage(conversation);
  }


  ///----------------------------------------ui start---------------------------------------------///

  //获取显示的ui主体
  List<Widget> getBody() {
    List<Widget> bodyArray = [];

    //接收当前会话的新的消息
    bodyArray.add(getTopAttentionUi());
    //添加主体聊天界面
    bodyArray.add(Expanded(
      child: SizedBox(
        child: Stack(
          fit: StackFit.expand,
          children: [
            (chatDataList != null && chatDataList.length > 0) ? getChatDetailsBody() : Container(),
            (conversation.type!=GROUP_TYPE)?Container():
            ChatAtUserList(
              isShow: context.read<ChatEnterNotifier>().keyWord == "@",
              onItemClickListener: atListItemClick,
              groupChatId: conversation.conversationId,
              delayedSetState: (){
                //print("delayedSetState-uuuuuuuuuuuuuuuuuuuuu");
                delayedSetState();
              },
            ),
          ],
        ),
      ),
    ));

    if (conversation.getType() != RCConversationType.System) {
      bodyArray.add(getMessageInputBar());
      bodyArray.add(bottomSettingBox());
      bodyArray.add(Container(
        height: ScreenUtil.instance.bottomBarHeight,
        color: AppColor.white,
      ));
    }

    return bodyArray;
  }


  //获取列表内容
  Widget getChatDetailsBody() {
    bool isShowName = conversation.getType() == RCConversationType.Group;
    if (chatDataList.length > 1) {
      if (!(chatDataList[0].isTemporary || chatDataList[1].isTemporary)) {
        if (chatDataList[0].msg.messageId == chatDataList[1].msg.messageId) {
          chatDataList.removeAt(0);
        }
      }
    }
    isShowHaveAnimation=MessageItemHeightUtil.init().judgeMessageItemHeightIsThenScreenHeight(chatDataList, isShowName);
    if(!isShowHaveAnimation&&isShowTopFirst){
      isShowTopFirst=false;
      if(conversation.getType() != RCConversationType.System){
        _onRefresh();
      }else{
        _onRefreshSystemInformation();
      }
    }
    return ChatDetailsBody(
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
      refreshController: _refreshController,
      isHaveAtMeMsg: isHaveAtMeMsg,
      isHaveAtMeMsgIndex: isHaveAtMeMsgIndex,
      isShowTop: !isShowHaveAnimation,
      onRefresh: (conversation.getType() != RCConversationType.System) ? _onRefresh : _onRefreshSystemInformation,
      loadText: loadText,
      isShowHaveAnimation: isShowHaveAnimation,
      loadStatus: loadStatus,
      isShowChatUserName: isShowName,
      onAtUiClickListener: onAtUiClickListener,
      firstEndCallback: firstEndCallbackListView,
    );
  }


  //头部显示关注遮挡
  Widget getTopAttentionUi() {
    if (conversation.type != PRIVATE_TYPE) {
      isShowTopAttentionUi = false;
    }
    return Visibility(
      visible: isShowTopAttentionUi,
      child: UnconstrainedBox(
        alignment: Alignment.topCenter,
        child: Container(
          height: 48,
          padding: const EdgeInsets.only(right: 16),
          width: MediaQuery.of(context).size.width,
          color: AppColor.textSecondary.withOpacity(0.1),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  height: 48,
                  width: 48,
                  color: AppColor.transparent,
                  child: Icon(Icons.close, size: 16, color: AppColor.colorb9b9b9),
                ),
                onTap: () {
                  isShowTopAttentionUi = false;
                  if (mounted) {
                    reload(() {
                      //print("reload111111111111111");
                    });
                  }
                },
              ),
              Expanded(
                  child: SizedBox(
                      child: Text(
                "点击关注,及时看到对方动态",
                style: TextStyle(color: AppColor.textPrimary1, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))),
              GestureDetector(
                child: Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColor.transparent,
                    border: Border.all(width: 1, color: AppColor.textPrimary1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: AppColor.textPrimary1),
                      Text("关注",
                          style: TextStyle(color: AppColor.textPrimary1, fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2),
                    ],
                  ),
                ),
                onTap: _attntionOnClick,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //输入框bar
  Widget getMessageInputBar() {
    return MessageInputBar(
      voiceOnTap: _voiceOnTapClick,
      onEmojio: () {
        onEmojioClick();
      },
      isVoice: _isVoiceState,
      voiceFile: _voiceFile,
      edit: edit,
      value: _textController.text,
      more: ChatMoreIcon(
        isComMomButton: StringUtil.strNoEmpty(_textController.text) && Application.platform == 0,
        onTap: () {
          //print("231");
          _onSubmitClick();
        },
        moreTap: () => onPicAndVideoBtnClick(),
      ),
      id: null,
      type: null,
    );
  }

  //输入框bar内的edit
  Widget edit(context, size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 80.0,
          minHeight: 16.0,
          maxWidth: Platform.isIOS
              ? ScreenUtil.instance.screenWidthDp - 32 - 32 - 64
              : ScreenUtil.instance.screenWidthDp - 32 - 32 - 64 - 52 - 12),
      child: TextSpanField(
        onTap: () {
          _bottomSettingPanelState=true;
          if (_emojiState) {
            reload(() {
              //print("reload2222222222222222222");
              _emojiState = !_emojiState;
            });
          }
        },
        onLongTap: (){
          _bottomSettingPanelState=true;
          if (_emojiState) {
            reload(() {
              //print("reload-33333333333333333");
              _emojiState = !_emojiState;
            });
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
        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
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

  //键盘与表情的框
  Widget bottomSettingBox() {
    List<Widget> widgetList=[];

    double keyboardHeight = 300.0;

    if (Application.keyboardHeightChatPage > 0) {
      keyboardHeight = Application.keyboardHeightChatPage;
    }else if(Application.keyboardHeightIfPage>0){
      Application.keyboardHeightChatPage = Application.keyboardHeightIfPage;
      keyboardHeight = Application.keyboardHeightChatPage;
    }
    if (keyboardHeight < 90) {
      keyboardHeight = 300.0;
    }

    widgetList.add(bottomSettingPanel(keyboardHeight));


    if((_emojiState ? keyboardHeight : 0.0)>0){
      widgetList.add(emoji(keyboardHeight));
    }

    return Container(
      child: Stack(
        children: widgetList,
      ),
    );
  }

  Widget bottomSettingPanel(double keyboardHeight){
    print("bottomSettingPanel:$_bottomSettingPanelState,$keyboardHeight");
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: _bottomSettingPanelState ? keyboardHeight : 0.0,
      child: Container(
        height: _bottomSettingPanelState ? keyboardHeight : 0.0,
        width: double.infinity,
        color: AppColor.white,
      ),
    );
  }


  //表情框
  Widget emoji(double keyboardHeight) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: _emojiState ? keyboardHeight : 0.0,
      child: Container(
        height: _emojiState ? keyboardHeight : 0.0,
        width: double.infinity,
        color: AppColor.white,
        child: emojiList(keyboardHeight),
      ),
    );
  }

  //emoji具体是什么界面
  Widget emojiList(double keyboardHeight) {
    if (emojiModelList == null || emojiModelList.length < 1) {
      return Center(
        child: Text("暂无表情"),
      );
    } else {
      return GestureDetector(
        child: Container(
          width: double.infinity,
          color: AppColor.transparent,
          child: ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 0.2,
                    color: Colors.grey,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _emojiGridTop(keyboardHeight),
                ),
                SliverToBoxAdapter(
                  child: _emojiBottomBox(),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      );
    }
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop(double keyboardHeight) {
    return Container(
      height: keyboardHeight - 45.0,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: emojiModelList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1),
        itemBuilder: (context, index) {
          return _emojiGridItem(emojiModelList[index], index);
        },
      ),
    );
  }

  //表情的bar
  Widget _emojiBottomBox() {
    TextStyle textStyle = const TextStyle(
      fontSize: 24,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: AppColor.bgWhite, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      height: 44,
      child: Row(
        children: [
          AppIconButton(
            iconSize: 24,
            svgName: AppIcon.message_emotion,
            buttonWidth: 44,
            buttonHeight: 44,
            onTap: () {},
          ),
          Spacer(),
          AppIconButton(
            iconSize: 24,
            svgName: _textController.text == null || _textController.text.isEmpty
                ? AppIcon.message_cant_send
                : AppIcon.message_send,
            buttonWidth: 44,
            buttonHeight: 44,
            onTap: () => _onSubmitClick(),
          ),
        ],
      ),
    );
  }

  //每一个_emojiGridItem
  Widget _emojiGridItem(EmojiModel emojiModel, int index) {
    TextStyle textStyle = const TextStyle(
      fontSize: 24,
    );
    return Material(
        color: Colors.white,
        child: new InkWell(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              emojiModel.emoji,
              style: textStyle,
            ),
          ),
          onTap: () {
            // _textController.text = emojiModel.code;
            // 获取输入框内的规则
            var rules = context.read<ChatEnterNotifier>().rules;

            if (_textController.text == null || _textController.text.length < 1) {
              _textController.text = "";
              cursorIndexPr = 0;
            }
            if (cursorIndexPr >= 0) {
              _textController.text = _textController.text.substring(0, cursorIndexPr) +
                  emojiModel.code +
                  _textController.text.substring(cursorIndexPr, _textController.text.length);
            } else {
              _textController.text += emojiModel.code;
            }
            _changTextLen(_textController.text);
            if (rules.isNotEmpty) {
              print("不为空");
              int diffLength = emojiModel.code.length;
              print("diffLength:$diffLength");
              for (int i = 0; i < rules.length; i++) {
                if (rules[i].startIndex >= cursorIndexPr) {
                  int newStartIndex = rules[i].startIndex + diffLength;
                  int newEndIndex = rules[i].endIndex + diffLength;
                  rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                }
              }
            }
            cursorIndexPr += emojiModel.code.length;
            // 替换
            context.read<ChatEnterNotifier>().replaceRules(rules);
            Future.delayed(Duration(milliseconds: 100), () {
              textScrollController.jumpTo(textScrollController.position.maxScrollExtent);
            });
          },
        ));
  }

  ///------------------------------------ui end--------------------------------------------------------------------------------///
  ///------------------------------------数据初始化和各种回调   start--------------------------------------------------------------------------------///

// 监听返回
  Future<bool> _requestPop() {
    bool b = false;
    if (MediaQuery.of(context).viewInsets.bottom == 0 && !_emojiState) {
      b = true;
    } else {
      if (_emojiState) {
        _emojiState = false;
        // isResizeToAvoidBottomInset = !_emojiState;
        b = false;
        if (mounted) {
          reload(() {
            //print("reload-44444444444444444");
          });
        }
      } else {
        b = true;
      }
    }
    return new Future.value(b);
  }

  //当改变了输入框内的文字个数
  _changTextLen(String text) {
    //print("------------------------------------------------");
    // 存入最新的值
    context.read<ChatEnterNotifier>().changeCallback(text);
    bool isReset = false;
    if (StringUtil.strNoEmpty(text)) {
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
      //print("111111111111111111111111111111");
      if (mounted) {
        reload(() {
          //print("reload-55555555555555555555");
        });
      }
    }
  }


  String getChatName(){
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

    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
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
    }
  }

  //获取系统消息
  Future<List<ChatDataModel>> getSystemInformationNet() async {
    List<ChatDataModel> dataList = <ChatDataModel>[];
    Map<String, dynamic> dataListMap =
        await querySysMsgList(type: conversation.type, size: 20, lastTime: systemLastTime);
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
        chatDataList.insert(0, getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch, conversation.conversationId));
        if (recallNotificationMessagePosition > 0) {
          recallNotificationMessagePosition++;
        }
      }
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
        isHaveAtMeMsg = false;
        isHaveAtMeMsgPr = true;
        judgeNewChatIsHaveAt();
      }
    }
  }

  //判断当前屏幕内有没有at我的消息
  void judgeNewChatIsHaveAt() {
    isHaveAtMeMsgIndex = -1;
    if (chatDataList == null || chatDataList.length < 1) {
      isHaveAtMeMsg = false;
      isHaveAtMeMsgPr = false;
      Application.atMesGroupModel.remove(atMeMsg);
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
          break;
        }
      }
    }
  }

  //listview 当前显示的是第几个 回调
  void firstEndCallbackListView(int firstIndex, int lastIndex) {
    if (ClickUtil.isFastClickFirstEndCallbackListView(time: 200)) {
      return;
    }
    //print('0chatPage----firstIndex: $firstIndex, lastIndex: $lastIndex, isHaveAtMeMsgIndex:$isHaveAtMeMsgIndex，isHaveAtMeMsgPr:$isHaveAtMeMsgPr,isHaveAtMeMsg:$isHaveAtMeMsg');
    if (isHaveAtMeMsgPr) {
      if (isHaveAtMeMsgIndex < 0) {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
          //print("delayedSetState-1111111111111111111");
          delayedSetState();
          //print('1--------------------------显示标识at');
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
      } else if (isHaveAtMeMsgIndex <= lastIndex) {
        if (isHaveAtMeMsg) {
          isHaveAtMeMsg = false;
          //print('2--------------------------关闭标识at');
          //print("delayedSetState-2222222222222222222222");
          delayedSetState();
        }
        //print('2--------------------------已经是关闭--关闭标识at');
        isHaveAtMeMsgPr = false;
        isHaveAtMeMsgIndex = -1;
        Application.atMesGroupModel.remove(atMeMsg);
      } else {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
          //print("delayedSetState-333333333333333333333");
          delayedSetState();
          //print('3--------------------------显示标识at');
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
      }
    }
  }

  //点击了at标识
  void onAtUiClickListener() async {
    //print("点击了at标识1");
    if (isHaveAtMeMsg && isHaveAtMeMsgIndex > 0) {
      //print("滚动到第$isHaveAtMeMsgIndex个item位置");
    } else {
      //print("加载更多的item");
      while (isHaveAtMeMsg && isHaveAtMeMsgIndex < 0) {
        //print("chatDataList.len:${chatDataList.length}");
        List msgList = new List();
        msgList = await RongCloud.init().getHistoryMessages(conversation.getType(), conversation.conversationId,
            chatDataList[chatDataList.length - 1].msg.sentTime, 20, 0);
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

          judgeNewChatIsHaveAt();
        } else {
          isHaveAtMeMsgIndex = -1;
          isHaveAtMeMsg = false;
          isHaveAtMeMsgPr = false;
          Application.atMesGroupModel.remove(atMeMsg);
          break;
        }

        if (mounted) {
          reload(() {
            //print("reload-66666666666666666666666");
          });
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
  void _resetCharPageBar(){
    Element e = findChild(context as Element, appbarWidget);
    if (e != null) {
      appbarWidget=ChatPageUtil.init(context).getAppBar(conversation, _topMoreBtnClick);
      e.owner.lockState(() {
        e.update(appbarWidget);
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
    if (text == null || text.isEmpty || text.length < 1) {
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
        reload(() {
          //print("reload-7777777777777777777");
          _textController.text = "";
          isHaveTextLen = false;
        });
      }
    }

    print("chatDataList[0]:${chatDataList[0]}");
    postText(chatDataList[0], conversation.conversationId, conversation.getType(), mentionedInfo, () {
      context.read<ChatEnterNotifier>().clearRules();
      //print("delayedSetState-333333333333333333333");
      delayedSetState();
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
      reload(() {
        //print("reload-8888888888888888888888");
      });
    }
    postImgOrVideo(modelList, conversation.conversationId, selectedMediaFiles.type, conversation.getType(), () {
      //print("delayedSetState-444444444444444");
      delayedSetState();
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
      reload(() {
        //print("reload-9999999999999999999");
      });
    }
    postVoice(chatDataList[0], conversation.conversationId, conversation.type, conversation.getType(), () {
      //print("delayedSetState-5555555555555555");
      delayedSetState();
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
      reload(() {
        //print("reload-aaaaaaaaaaaaaaaaaaaaaaaa");
        _textController.text = "";
        isHaveTextLen = false;
      });
    }
    postSelectMessage(chatDataList[0], conversation.conversationId, conversation.getType(), () {
      //print("delayedSetState-555555555555555");
      delayedSetState();
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
        reload(() {
          //print("reload-bbbbbbbbbbbbbbbbbbbbbbb");
        });
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
          reload(() {
            //print("reload-cccccccccccccccccccccccccccc");
            _textController.text = "";
            isHaveTextLen = false;
          });
        }
      },
    );
  }

  // //发送修改群名称
  // _postUpdateGroupName(String name) {
  //   ChatDataModel chatDataModel = new ChatDataModel();
  //   chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_ALERT_UPDATE_GROUP_NAME;
  //   chatDataModel.content = name;
  //   chatDataModel.isTemporary = true;
  //   chatDataModel.isHaveAnimation = true;
  //   judgeAddAlertTime();
  //   chatDataList.insert(0, chatDataModel);
  //   animateToBottom();
  //   if(mounted) {
  //     setState(() {
  //       _timerCount = 0;
  //       isHaveTextLen = false;
  //     });
  //   }
  //   postGroupUpdateName(chatDataList[0], conversation.conversationId, () {
  //     delayedSetState();
  //   });
  // }

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
          reload(() {
            //print("reload-dddddddddddddddddddddddd");
            isShowTopAttentionUi = true;
            recallNotificationMessagePosition = -1;
            _textController.text = "";
            isHaveTextLen = false;
          });
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
      //print("delayedSetState-777777777777777");
      delayedSetState();
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
      reload(() {
        //print("reload-eeeeeeeeeeeeeeeeeeee");
      });
    }
    postImgOrVideo(modelList, conversation.conversationId, mediaFileModel.type, conversation.getType(), () {
      //print("delayedSetState-8888888888888888888888");
      delayedSetState();
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
      reload(() {
        //print("reload-ffffffffffffffffffffffffff");
        isHaveTextLen = false;
      });
    }
    resetPostMessage(chatDataList[0], () {
      //print("delayedSetState-999999999999999999999");
      delayedSetState();
    });
  }

  ///------------------------------------发送消息  end-----------------------------------------------------------------------///
  ///------------------------------------一些功能 方法  start-----------------------------------------------------------------------///


  //延迟更新
  void delayedSetState({int milliseconds = 200}) {
    if (milliseconds <= 0) {
      Future.delayed(Duration.zero, () {
        //print("setState--delayedSetState");
        if (mounted) {
          reload(() {
          });
        }
      });
    } else {
      Future.delayed(Duration(milliseconds: milliseconds), () {
        //print("setState--delayedSetState");
        if (mounted) {
          reload(() {
          });
        }
      });
    }
  }


  //设置消息的状态
  void resetSettingStatus(List<int> list){
    if(list==null||list.length<2){
      return;
    }
    int messageId=list[0];
    int status=list[1];
    print("更新消息状态-----------messageId：$messageId, status:$status");
    if (messageId == null || status == null || chatDataList == null || chatDataList.length < 1) {
      return ;
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
            //print("delayedSetState-aaaaaaaaaaaaaaaaaa");
            delayedSetState();
            return ;
          }
        }
      }
    }
  }

  //接收消息
  void getReceiveMessages(Message message){
    if(message.targetId!=conversation.conversationId){
      return;
    }
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        message.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      //撤回消息
      for (ChatDataModel model in chatDataList) {
        if (model.msg.messageUId == message.messageUId) {
          model.msg = message;
          //print("delayedSetState-bbbbbbbbbbbbbbbbbbbbbb");
          delayedSetState();
          break;
        }
      }
    } else {
      //不是撤回消息

      //当进入聊天界面,没有任何聊天记录,这时对方给我发消息就可能会照成崩溃
      if (chatDataList.length > 0 && message.messageUId == chatDataList[0].msg.messageUId) {
        return ;
      }
      ChatDataModel chatDataModel = getMessage(message, isHaveAnimation: scrollPositionPixels < 500);
      print("scrollPositionPixels：$scrollPositionPixels");
      judgeAddAlertTime();
      chatDataList.insert(0, chatDataModel);
      insertSourceList(chatDataModel);
      //判断是不是群通知
      if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF
          && conversation.getType() == RCConversationType.Group) {
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
        //print("delayedSetState-ccccccccccccccccc");
        delayedSetState();
      }
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

//判断是否退出界面加入群聊
  void _judgeResetPage(Message message) {
    if (message != null) {
      //清聊天未读数
      ChatPageUtil.init(Application.appContext).clearUnreadCount(conversation);
      getChatGroupUserModelList(conversation.conversationId, context);
      insertExitGroupMsg(message, conversation.conversationId, (Message msg, int code) {
        if (code == 0) {
          print("scrollPositionPixels1：$scrollPositionPixels");
          chatDataList.insert(0, getMessage(msg, isHaveAnimation: scrollPositionPixels < 500));
          isHaveReceiveChatDataList = true;
          if (scrollPositionPixels < 500) {
            isHaveReceiveChatDataList = false;

            //print("delayedSetState-eeeeeeeeeeeeeeeeeee");
            delayedSetState();
          }
        }
      });
    }
  }


  initWidget(){
    appbarWidget=ChatPageUtil.init(_context).getAppBar(conversation, _topMoreBtnClick);
  }

  initScrollController(){
    _scrollController.addListener(() {
      scrollPositionPixels = _scrollController.position.pixels;
      // print("scrollPositionPixels3：$scrollPositionPixels");
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (loadStatus == LoadingStatus.STATUS_IDEL) {
          // 先设置状态，防止下拉就直接加载reload
          if (mounted) {
            reload(() {
              //print("reload-iiiiiiiiiiiiiiiiiiiii");
              loadText = "加载中...";
              loadStatus = LoadingStatus.STATUS_LOADING;
            });
          }
          if (conversation.getType() != RCConversationType.System) {
            _onRefresh();
          } else {
            _onRefreshSystemInformation();
          }
        }
      } else if (_scrollController.position.pixels <= 0) {
        if (mounted && isHaveReceiveChatDataList) {
          reload(() {
            //print("reload-jjjjjjjjjjjjjjjjjjjj");
            isHaveReceiveChatDataList = false;
          });
        }
      }
    });
  }

  initTextController() {
    _focusNode.addListener(() {
      cursorIndexPr = _textController.selection.baseOffset;
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
        print("at位置&${atIndex}");
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
          if(context.read<ChatEnterNotifier>().keyWord!="") {
            context.read<ChatEnterNotifier>().openAtCallback("");
            //print("delayedSetState-ffffffffffffffffffffffffff");
            delayedSetState();
          }
        }
      }
      isSwitchCursor = true;
    });
  }

  initReleaseFeedInputFormatter() {
    _formatter = ReleaseFeedInputFormatter(
      controller: _textController,
      correctRulesListener: (){
        //print("delayedSetState-lllllllllllllllllllllllll");
        delayedSetState(milliseconds: 0);
      },
      rules: context.read<ChatEnterNotifier>().rules,
      // @回调
      triggerAtCallback: (String str) async {
        print("打开@功能--str：$str------------------------");
        if (conversation.getType() == RCConversationType.Group) {
          context.read<ChatEnterNotifier>().openAtCallback(str);
          isClickAtUser = false;
          //print("delayedSetState-mmmmmmmmmmmmmmmmmmm");
          delayedSetState();
        }
        return "";
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        print("取消艾特功能3");
        print('----------------------------关闭视图');
        context.read<ChatEnterNotifier>().openAtCallback("");
        //print("delayedSetState-qqqqqqqqqqqqqqqqqqqq");
        delayedSetState();
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
          ToastShow.show(msg: "发送失败，你已将对方加入黑名单", context: _context);
        } else if (blackModel.inThisBlack == 1) {
          print("发送失败，你已被对方加入黑名单");
          ToastShow.show(msg: "发送失败，你已被对方加入黑名单", context: _context);
        }
      }
    }
  }

  ///------------------------------------一些功能 方法  end-----------------------------------------------------------------------///
  ///------------------------------------各种点击事件  start-----------------------------------------------------------------------///

  //聊天内容的点击事件
  _messageInputBodyClick() {
    print("_messageInputBodyClick");
    if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0) {
      if(MediaQuery.of(context).viewInsets.bottom>0) {
        FocusScope.of(context).requestFocus(new FocusNode());
      }
      _bottomSettingPanelState=false;
      if(_emojiState) {
        if (mounted) {
          reload(() {
            //print("reload-kkkkkkkkkkkkkkkkkk");
            _emojiState = false;
          });
        }
      }
    }
  }

  //表情的点击事件
  void onEmojioClick() {
    if (_focusNode.hasFocus) {
      cursorIndexPr = _textController.selection.baseOffset;
      _focusNode.unfocus();
    }
    _emojiState = !_emojiState;
    _isVoiceState = false;
    if (mounted) {
      reload(() {
        //print("reload-mmmmmmmmmmmmmmmmmmmmmmmmmmmm");
      });
    }
  }

  //图片的点击事件
  onPicAndVideoBtnClick() {
    //print("=====图片的点击事件");
    _focusNode.unfocus();
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

  //录音按钮的点击事件
  _voiceOnTapClick() async {
    await [Permission.microphone].request();
    _focusNode.unfocus();
    _emojiState = false;
    _isVoiceState = !_isVoiceState;
    if (mounted) {
      reload(() {
        //print("reload-mmmmmmmmmmmmmmmmmmmmmmmm");
      });
    }
  }

  //头部-更多按钮的点击事件
  _topMoreBtnClick() {
    _focusNode.unfocus();
    // ToastShow.show(msg: "点击了更多按钮", context: _context);
    Message message=chatDataList==null||chatDataList.length<1||chatDataList[0].msg==null?null:chatDataList[0].msg;
    judgeJumpPage(
        conversation.getType(),
        this.conversation.conversationId,
        conversation.type,
        context,
        getChatName(),
        _morePageOnClick,
        _moreOnClickExitChatPage,
        message);
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
      //print("delayedSetState-wwwwwwwwwwwwwwwwwwwwwww");
      delayedSetState();
    } else if (type == 1) {
      conversation.name = name;
      //修改了群名
      // _postUpdateGroupName(name);
      context.read<ConversationNotifier>().updateConversationName(name, conversation);
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
          if (mounted) {
            reload(() {

              //print("reload-nnnnnnnnnnnnnnnnnnnnnnnn");
            });
          }
          context.read<UserInteractiveNotifier>().changeFollowCount(int.parse(conversation.conversationId), true);
          if (context.read<UserInteractiveNotifier>().profileUiChangeModel.containsKey(int.parse(conversation.conversationId))) {
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
      if (mounted) {
        reload(() {

          //print("reload-rrrrrrrrrrrrrrrrrrrrrrrrrrr");
        });
      }
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
    // 设置光标
    // var setCursor = TextSelection(
    //   baseOffset: _textController.text.length,
    //   extentOffset: _textController.text.length,
    // );
    //print("设置光标$setCursor");
    // _textController.selection = setCursor;
    Future.delayed(Duration(milliseconds: 100), () {
      print("取消艾特功能4");
      context.read<ChatEnterNotifier>().setAtSearchStr("");
      // 关闭视图
      context.read<ChatEnterNotifier>().openAtCallback("");
      //print("delayedSetState-rrrrrrrrrrrrrrr");
      delayedSetState();
    });
  }

  //刷新数据--加载更多以前的数据
  _onRefresh() async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(
        conversation.getType(), conversation.conversationId, chatDataList[chatDataList.length - 1].msg.sentTime, 20, 0);
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
        judgeNewChatIsHaveAt();
      }
      loadStatus = LoadingStatus.STATUS_IDEL;
      loadText = "加载中...";
    } else {
      // 加载完毕
      loadText = "已加载全部动态";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    Future.delayed(Duration(milliseconds: 500), () {
      _refreshController.loadComplete();
      if (mounted) {
        reload(() {
          //print("reload-sssssssssssssssssssssss");
        });
      }
    });
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
      loadText = "加载中...";
    } else {
      loadText = "已加载全部动态";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    _refreshController.loadComplete();
    //print("delayedSetState-ttttttttttttttttttttttttttt");
    delayedSetState();
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
          reload(() {
            //print("reload-tttttttttttttttttttt");
            chatDataList.removeAt(position);
          });
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
      ToastShow.show(msg: "跳转网页地址: $content", context: _context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_FEED) {
      // ToastShow.show(msg: "跳转动态详情页", context: context);
      getFeedDetail(map["id"], context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      _openGallery(position);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_USER) {
      // ToastShow.show(msg: "跳转用户界面", context: _context);
      AppRouter.navigateToMineDetail(context, map["uid"]);
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
          reload(() {
            //print("reload-uuuuuuuuuuuuuuuuuuuuuuu");
          });
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
      if (mounted) {
        reload(() {
          //print("reload-vvvvvvvvvvvvvvvvvvvvvvv");
        });
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
        print("消息类型：${msgType}");
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

  @override
  void endCanvasPage() {
    print("停止改变屏幕高度");
    if(MediaQuery.of(this.context).viewInsets.bottom>0){
      if(Application.keyboardHeightChatPage!=MediaQuery.of(this.context).viewInsets.bottom){
        Application.keyboardHeightChatPage=MediaQuery.of(this.context).viewInsets.bottom;
        if (mounted) {
          reload(() {

            //print("reload-wwwwwwwwwwwwwwwwwwwwwwwwwwww");
          });
        }
      }
    }
  }

  @override
  void startCanvasPage(bool isOpen) {
    print("开始改变屏幕高度:${isOpen?"打开":"关闭"}");
    _bottomSettingPanelState=isOpen;
    if (mounted) {
      reload(() {

        //print("reload-zzzzzzzzzzzzzzzzzzzzzzz");
      });
    }
  }
}

///------------------------------------各种点击事件  end-----------------------------------------------------------------------///}
