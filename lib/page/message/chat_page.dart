import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
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
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:text_span_field/range_style.dart';
import 'package:text_span_field/text_span_field.dart';
import 'chat_details_body.dart';
import 'item/chat_at_user_name_list.dart';
import 'item/chat_more_icon.dart';
import 'item/emoji_manager.dart';
import 'item/message_body_input.dart';
import 'item/message_input_bar.dart';
import 'package:provider/provider.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';


////////////////////////////////
//
/////////////聊天会话页面
//
///////////////////////////////

class ChatPage extends StatefulWidget {
  final ConversationDto conversation;
  final Message shareMessage;

  ChatPage({Key key, @required this.conversation, this.shareMessage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState(conversation,shareMessage);
  }
}

class ChatPageState extends XCState with TickerProviderStateMixin {



  ConversationDto conversation;
  Message shareMessage;
  
  ChatPageState(this.conversation, this.shareMessage);
  
  

  ///所有的会话消息
  List<ChatDataModel> chatDataList = <ChatDataModel>[];

  ///是否显示表情
  bool _emojiState = false;

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

  ///内容的点击事件还是表情的点击
  bool isContentClickOrEmojiClick = true;

  ///界面能不能被输入法顶起
  bool isResizeToAvoidBottomInset = true;

  ///表情的列表
  List<EmojiModel> emojiModelList = <EmojiModel>[];

  ///对话的用户的名字
  String chatUserName;

  ///对话用户id
  String chatUserId;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  String chatType;

  ///这是什么类型的对话--融云的分类-数字
  ///[chatTypeId] 会话类型，参见枚举 [RCConversationType]
  int chatTypeId;

  ///是不是私人管家
  bool isPersonalButler;

  // 是否点击了弹起的@用户列表
  bool isClickAtUser = false;

  ///计时
  Timer _timer;
  int _timerCount = 0;

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

  String systemLastTime;
  int systemPage = 0;

  //是否可以显示头部关注box
  bool isShowTopAttentionUi = false;

  @override
  void initState() {
    super.initState();
    initData();
    context.read<ChatMessageProfileNotifier>().isResetPage = false;
    if (conversation.getType() != RCConversationType.System) {
      initSetData();
      initTime();
      initTextController();
      initReleaseFeedInputFormatter();
    } else {
      getSystemInformation();
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (loadStatus == LoadingStatus.STATUS_IDEL) {
          // 先设置状态，防止下拉就直接加载reload
          if (mounted) {
            reload(() {
              _timerCount = 0;
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
      }
    });
  }

  @override
  Widget shouldBuild(BuildContext context) {
    print("0000000000000000000000000000000000000000000000000000000000");
    if (chatUserName == null) {
      initData();
    }
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: isResizeToAvoidBottomInset,
        appBar: getAppBar(),
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
    _scrollController.dispose();
    if (Application.appContext != null) {
      //清聊天未读数
      MessageManager.clearUnreadCount(Application.appContext, conversation.conversationId,
          Application.profile.uid, conversation.type);
      //清其他数据
      Application.appContext.read<GroupUserProfileNotifier>().clearAllUser();
      Application.appContext.read<VoiceSettingNotifier>().stop();
      Application.appContext.read<ChatMessageProfileNotifier>().clear();
      _textController.text = "";
      Application.appContext.read<ChatEnterNotifier>().clearRules();
    }
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
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
            ChatAtUserList(
              isShow: context.read<ChatEnterNotifier>().keyWord == "@",
              onItemClickListener: atListItemClick,
              groupChatId: chatUserId,
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

    //接收当前会话的新的消息
    bodyArray.add(Offstage(
      offstage: true,
      child: judgeReceiveMessages(),
    ));

    //判断有没有加入群聊或者退出群聊需要插入数据-刷新界面的
    bodyArray.add(Offstage(
      offstage: true,
      child: judgeResetPage(),
    ));

    return bodyArray;
  }

  //获取列表内容
  Widget getChatDetailsBody() {
    bool isShowName= conversation.getType() == RCConversationType.Group;
    return ChatDetailsBody(
      scrollController: _scrollController,
      chatDataList: chatDataList,
      onTap: () => _messageInputBodyClick(),
      vsync: this,
      voidItemLongClickCallBack: onItemLongClickCallBack,
      voidMessageClickCallBack: onMessageClickCallBack,
      chatUserName: chatUserName,
      conversationDtoType: conversation.type,
      isPersonalButler: isPersonalButler,
      refreshController: _refreshController,
      isHaveAtMeMsg: isHaveAtMeMsg,
      isHaveAtMeMsgIndex: isHaveAtMeMsgIndex,
      isShowTop:!MessageItemHeightUtil.init().judgeMessageItemHeightIsThenScreenHeight(chatDataList, isShowName),
      onRefresh: (conversation.getType() != RCConversationType.System) ?
        _onRefresh : _onRefreshSystemInformation,
      loadText: loadText,
      loadStatus: loadStatus,
      isShowChatUserName: isShowName,
      onAtUiClickListener: onAtUiClickListener,
      firstEndCallback: (int firstIndex, int lastIndex) {
        firstEndCallbackListView(firstIndex, lastIndex);
      },
    );
  }

  //获取appbar
  Widget getAppBar() {
    return CustomAppBar(
      titleString: chatUserName??"",
      actions: [
        CustomAppBarIconButton(Icons.more_horiz, AppColor.black, false, _topMoreBtnClick),
      ],
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
                    reload(() {});
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
      onEmojio: onEmojioClick,
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
          if (text.isNotEmpty) {
            _postText(text);
          }
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
          contentPadding: EdgeInsets.only(top: 6, bottom: 4, left: 16,right: 16),
        ),

        rangeStyles: getTextFieldStyle(Application.appContext.read<ChatEnterNotifier>().rules),
        inputFormatters: [_formatter],
      ),
    );
  }

  //键盘与表情的框
  Widget bottomSettingBox() {
    bool isOffstage = true;
    if (!_focusNode.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0 && !isContentClickOrEmojiClick) {
      isOffstage = false;
    }
    return Container(
      color: AppColor.white,
      child: Stack(
        children: [
          emoji(),
          Offstage(
            offstage: isOffstage,
            child: Container(
              height: Application.keyboardHeight,
              width: double.infinity,
            ),
          )
        ],
      ),
    );
  }

  //表情框
  Widget emoji() {
    //fixme 这里的300高度只是临时方案 其实应该是获取键盘的高度 但是在没有打开键盘时 暂时不知道键盘高度是多少
    double emojiHeight = Application.keyboardHeight > 0 ? Application.keyboardHeight : 300;
    if (!_emojiState) {
      emojiHeight = 0.0;
    }

    // return _emojiState ? AnimatedContainer(
    //   height: emojiHeight,
    //   duration: Duration(milliseconds: 300),
    //   child: Container(
    //     height: emojiHeight,
    //     width: double.infinity,
    //     color: Colors.white,
    //     child: emojiList(),
    //   ),
    // ) : Container();

    return AnimatedContainer(
      height: emojiHeight,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: emojiHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        child: emojiList(),
      ),
    );
  }

  //emoji具体是什么界面
  Widget emojiList() {
    if (_emojiState) {
      if (emojiModelList == null || emojiModelList.length < 1) {
        return Center(
          child: Text("暂无表情"),
        );
      } else {
        return GestureDetector(
          child: Container(
            width: double.infinity,
            color: AppColor.transparent,
            child: Column(
              children: [
                Expanded(
                    child: SizedBox(
                  child: _emojiGridTop(),
                )),
                _emojiBottomBox(),
              ],
            ),
          ),
          onTap: () {},
        );
      }
    } else {
      return Container();
    }
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop() {
    return Container(
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
    return SingleChildScrollView(
      child: Container(
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
            Container(
              height: 44,
              width: 44,
              child: Center(
                child: Text(
                  emojiModelList[64].emoji,
                  style: textStyle,
                ),
              ),
            ),
            Spacer(),
            Container(
              height: 44,
              width: 44,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 24,
                  ),
                  onPressed: () => _onSubmitClick(),
                ),
              ),
            ),
          ],
        ),
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
            int startIndex=_textController.text.length??0;
            context
                .read<ChatEnterNotifier>()
                .addRules(Rule(startIndex, startIndex+emojiModel.code.length, emojiModel.code, -1, true));
            _textController.text += emojiModel.code;
            _changTextLen(_textController.text);
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
        isResizeToAvoidBottomInset = !_emojiState;
        b = false;
        if (mounted) {
          reload(() {
            _timerCount = 0;
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
          _timerCount = 0;
        });
      }
    }
  }

  //初始化一些数据
  void initData() {
    chatUserName = "聊天界面";
    chatUserId = "-1";
    chatType = "测试聊天";
    chatTypeId = RCConversationType.Private;
    isPersonalButler = false;
    if (conversation == null) {
      //print("未知信息");
    } else {
      print("-*----------------------"+conversation.toMap().toString());
      if(conversation.name==null||conversation.name.trim().length<1){
        chatUserName=conversation.conversationId;
      }else{
        chatUserName = conversation.name;
      }
      chatUserId = conversation.conversationId;
      chatType = getMessageType(conversation, context);
      chatTypeId = conversation.getType();

      if (conversation.type == MANAGER_TYPE) {
        isPersonalButler = true;
      }
    }
    context.read<ChatMessageProfileNotifier>().setData(chatTypeId, chatUserId);
    if (chatTypeId == RCConversationType.Group) {
      getChatGroupUserModelList(chatUserId, context);
    }
    
    print("----------------------------chatUserName:$chatUserName$chatUserId");
  }

  //初始化一些数据
  void initSetData() async {
    Future.delayed(Duration(milliseconds: 200), ()async {
      List msgList = new List();
      msgList = await RongCloud.init().getHistoryMessages(conversation.getType(),
          conversation.conversationId, new DateTime.now().millisecondsSinceEpoch, 20, 0);
      print("历史记录${msgList.length}");
      if (msgList != null && msgList.length > 0) {
        for (int i = 0; i < msgList.length; i++) {
          chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
        }
      }
      if (shareMessage != null&&chatDataList.length>0) {
        chatDataList[0].isHaveAnimation = true;
      }

      //加入时间提示
      getTimeAlert(chatDataList);

      //获取有没有at我的消息
      judgeIsHaveAtMeMsg();

      //判断有没有显示关注按钮
      await getRelation();

      //获取表情的数据
      emojiModelList = await EmojiManager.getEmojiModelList();
      if (mounted) {
        reload(() {
          _timerCount = 0;
        });
      }
    });
  }

  //查询我是不是关注了对方
  Future<void> getRelation() async {
    if (conversation.type != PRIVATE_TYPE) {
      isShowTopAttentionUi = false;
    } else {
      Map<String, dynamic> map = await relation(Application.profile.uid, int.parse(chatUserId));
      if (map == null || map["relation"] == null || map["relation"] == 1 || map["relation"] == 3) {
        isShowTopAttentionUi = false;
      } else {
        isShowTopAttentionUi = true;
      }
    }
  }

  //获取系统消息
  void getSystemInformation() async {
    List<ChatDataModel> dataList = await getSystemInformationNet();
    if (dataList != null && dataList.length > 0) {
      chatDataList.addAll(dataList);
      //加入时间提示
      getTimeAlert(chatDataList);
      delayedSetState();
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

  //加入时间提示
  void getTimeAlert(List<ChatDataModel> chatDataList) {
    if (chatDataList != null && chatDataList.length > 0) {
      for (int i = chatDataList.length - 1; i >= 0; i--) {
        if (i == chatDataList.length - 1) {
          chatDataList.add(getTimeAlertModel(chatDataList[i].msg.sentTime));
        } else if (chatDataList[i].msg.sentTime - chatDataList[i + 1].msg.sentTime > 5 * 60 * 1000) {
          chatDataList.insert(i + 1, getTimeAlertModel(chatDataList[i].msg.sentTime));
        }
      }
    }
  }

  //获取时间戳
  ChatDataModel getTimeAlertModel(int sentTime) {
    ChatDataModel dataModel = new ChatDataModel();
    dataModel.msg = getAlertTimeMsg(
        time: sentTime, sendTime: sentTime, targetId: chatUserId, conversationType: RCConversationType.Private);
    return dataModel;
  }

  //判断加不加时间提示
  judgeAddAlertTime() {
    if (chatDataList.length > 0) {
      if (new DateTime.now().millisecondsSinceEpoch - chatDataList[0].msg.sentTime >= 5 * 60 * 1000) {
        chatDataList.insert(0, getTimeAlertModel(new DateTime.now().millisecondsSinceEpoch));
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
      atMeMsg = Application.atMesGroupModel.getAtMsg(chatUserId);
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
    if (ClickUtil.isFastClick(time: 200)) {
      return;
    }
    //print('0chatPage----firstIndex: $firstIndex, lastIndex: $lastIndex, isHaveAtMeMsgIndex:$isHaveAtMeMsgIndex，isHaveAtMeMsgPr:$isHaveAtMeMsgPr,isHaveAtMeMsg:$isHaveAtMeMsg');
    if (isHaveAtMeMsgPr) {
      if (isHaveAtMeMsgIndex < 0) {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
          delayedSetState();
          //print('1--------------------------显示标识at');
        }
        isHaveAtMeMsg = true;
        isHaveAtMeMsgPr = true;
      } else if (isHaveAtMeMsgIndex <= lastIndex) {
        if (isHaveAtMeMsg) {
          isHaveAtMeMsg = false;
          //print('2--------------------------关闭标识at');
          delayedSetState();
        }
        //print('2--------------------------已经是关闭--关闭标识at');
        isHaveAtMeMsgPr = false;
        isHaveAtMeMsgIndex = -1;
        Application.atMesGroupModel.remove(atMeMsg);
      } else {
        if (!isHaveAtMeMsg) {
          isHaveAtMeMsg = true;
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
        msgList = await RongCloud.init().getHistoryMessages(conversation.getType(),
            conversation.conversationId, chatDataList[chatDataList.length - 1].msg.sentTime, 20, 0);
        List<ChatDataModel> dataList = <ChatDataModel>[];
        if (msgList != null && msgList.length > 0) {
          for (int i = 1; i < msgList.length; i++) {
            dataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
          }

          if (dataList != null && dataList.length > 0) {
            getTimeAlert(dataList);
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
            _timerCount = 0;
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

  ///------------------------------------数据初始化和各种回调   end--------------------------------------------------------------------------------///

  ///------------------------------------发送消息  start-----------------------------------------------------------------------///

  //发送文字消息
  _postText(String text) {
    if (text == null || text.isEmpty || text.length < 1) {
      ToastShow.show(msg: "消息为空,请输入消息！", context: context);
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
    animateToBottom();

    if (recallNotificationMessagePosition >= 0) {
      _updateRecallNotificationMessage();
    } else {
      if (mounted) {
        reload(() {
          _timerCount = 0;
          _textController.text = "";
          isHaveTextLen = false;
        });
      }
    }

    postText(chatDataList[0], conversation.conversationId, chatTypeId, mentionedInfo, () {
      context.read<ChatEnterNotifier>().clearRules();
      delayedSetState();
    });
  }

  //发送视频以及图片
  _handPicOrVideo(SelectedMediaFiles selectedMediaFiles) {
    List<ChatDataModel> modelList = <ChatDataModel>[];
    for (int i = 0; i < selectedMediaFiles.list.length; i++) {
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.type = (selectedMediaFiles.type == mediaTypeKeyVideo
          ? ChatTypeModel.MESSAGE_TYPE_VIDEO
          : ChatTypeModel.MESSAGE_TYPE_IMAGE);
      chatDataModel.mediaFileModel = selectedMediaFiles.list[i];
      chatDataModel.isTemporary = true;
      chatDataModel.isHaveAnimation = true;
      modelList.add(chatDataModel);
    }
    if (modelList != null) {
      judgeAddAlertTime();
      chatDataList.insertAll(0, modelList);
    }
    animateToBottom();
    if (mounted) {
      reload(() {
        _timerCount = 0;
      });
    }
    postImgOrVideo(modelList, conversation.conversationId, selectedMediaFiles.type, chatTypeId, () {
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
    animateToBottom();
    if (mounted) {
      reload(() {
        _timerCount = 0;
      });
    }
    postVoice(chatDataList[0], conversation.conversationId, chatTypeId, chatTypeId, () {
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
    animateToBottom();
    if (mounted) {
      reload(() {
        _timerCount = 0;
        _textController.text = "";
        isHaveTextLen = false;
      });
    }
    postSelectMessage(chatDataList[0], conversation.conversationId, chatTypeId, () {
      delayedSetState();
    });
  }

  //撤回消息
  void recallMessage(Message message, int position) async {
    RecallNotificationMessage recallNotificationMessage = await RongCloud.init().recallMessage(message);
    if (recallNotificationMessage == null) {
      ToastShow.show(msg: "撤回失败", context: context);
    } else {
      chatDataList[position].msg.objectName = RecallNotificationMessage.objectName;
      chatDataList[position].msg.content = recallNotificationMessage;
      if (mounted) {
        reload(() {
          _timerCount = 0;
        });
      }
    }
  }

  //修改撤回消息
  _updateRecallNotificationMessage() {
    getReChatDataModel(
      targetId: conversation.conversationId,
      conversationType: chatTypeId,
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
            _timerCount = 0;
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
      conversationType: chatTypeId,
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
            isShowTopAttentionUi = true;
            recallNotificationMessagePosition = -1;
            _timerCount = 0;
            _textController.text = "";
            isHaveTextLen = false;
          });
        }
      },
    );
  }

  //重新发送消息
  void _resetPostMessage(int position) async {
    ChatDataModel chatDataModel = new ChatDataModel();
    Message message = chatDataList[position].msg;
    chatDataModel.isTemporary = false;
    chatDataModel.isHaveAnimation = true;
    chatDataModel.msg = message;
    chatDataModel.msg.sentStatus = 10;
    chatDataModel.msg.sentTime = new DateTime.now().millisecondsSinceEpoch;
    judgeAddAlertTime();
    chatDataList.removeAt(position);
    chatDataList.insert(0, chatDataModel);
    animateToBottom();

    if (mounted) {
      reload(() {
        _timerCount = 0;
        isHaveTextLen = false;
      });
    }
    resetPostMessage(chatDataList[0], () {
      // RongCloud.init().deleteMessageById(message, (code)async {});
      delayedSetState();
    });
  }

  ///------------------------------------发送消息  end-----------------------------------------------------------------------///
  ///------------------------------------一些功能 方法  start-----------------------------------------------------------------------///

  //计时
  initTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timerCount++;
      // print(_timerCount.toString());
      if (_timerCount >= 150) {
        _timerCount = 0;
        delayedSetState();
      }
    });
  }

  //延迟更新
  void delayedSetState() {
    Future.delayed(Duration(milliseconds: 200), () {
      //print("setState--delayedSetState");
      _timerCount = 0;
      if (mounted) {
        reload(() {});
      }
    });
  }

//判断接收消息
  Widget judgeReceiveMessages() {
    return Consumer<ChatMessageProfileNotifier>(
      builder: (context, notifier, child) {
        Message message = context.select((ChatMessageProfileNotifier value) => value.message);
        bool isSettingStatus = context.select((ChatMessageProfileNotifier value) => value.isSettingStatus);
        if (message == null || message.targetId != this.chatUserId && message.conversationType != chatTypeId) {
          //是不是更新消息的状态
          if (isSettingStatus) {
            Application.appContext.read<ChatMessageProfileNotifier>().setSettingStatus(false);
            int messageId = context.select((ChatMessageProfileNotifier value) => value.messageId);
            int status = context.select((ChatMessageProfileNotifier value) => value.status);
            print("更新消息状态-----------messageId：$messageId, status:$status");
            if (messageId == null || status == null || chatDataList == null || chatDataList.length < 1) {
              return Container();
            } else {
              for (ChatDataModel dataModel in chatDataList) {
                if (dataModel.msg?.messageId == messageId) {
                  if (dataModel.msg?.sentStatus == status) {
                    return Container();
                  } else {
                    dataModel.msg?.sentStatus = status;
                    if (status == 20) {
                      profileCheckBlack();
                    }
                    delayedSetState();
                    return Container();
                  }
                }
              }
            }
          }
          return Container();
        } else {
          Application.appContext.read<ChatMessageProfileNotifier>().clearMessage();
        }
        //当进入聊天界面,没有任何聊天记录,这时对方给我发消息就可能会照成崩溃
        if (chatDataList.length>0&&message.messageUId == chatDataList[0].msg.messageUId) {
          return Container();
        }
        ChatDataModel chatDataModel = getMessage(message, isHaveAnimation: true);
        judgeAddAlertTime();
        chatDataList.insert(0, chatDataModel);
        if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
          //判断是不是群通知
          if (chatTypeId == RCConversationType.Group) {
            print("--------------------------------");
            getChatGroupUserModelList1(chatUserId, context);
          }
        }
        delayedSetState();
        return Container();
      },
    );
  }

//判断是否退出界面加入群聊
  Widget judgeResetPage() {
    return Consumer<ChatMessageProfileNotifier>(
      builder: (context, notifier, child) {
        bool isResetPage = context.select((ChatMessageProfileNotifier value) => value.isResetPage);
        Message message = context.select((ChatMessageProfileNotifier value) => value.resetMessage);
        if (isResetPage) {
          context.watch<ChatMessageProfileNotifier>().isResetPage = false;
          context.watch<ChatMessageProfileNotifier>().resetMessage = null;
          if (message != null) {
            getChatGroupUserModelList1(chatUserId, context);
            insertExitGroupMsg(message, chatUserId, (Message msg, int code) {
              if (code == 0) {
                chatDataList.insert(0, getMessage(msg));
                delayedSetState();
              }
            });
          }
        }
        return Container();
      },
    );
  }

  initTextController() {
    // print("值改变了");
    print("监听文字光标${_textController.selection}");

    List<Rule> rules = context.read<ChatEnterNotifier>().rules;
    int atIndex = context.read<ChatEnterNotifier>().atCursorIndex;
    print("当前值￥${_textController.text}");
    print(context.read<ChatEnterNotifier>().textFieldStr);
    // 获取光标位置
    int cursorIndex = _textController.selection.baseOffset;
    print("实时光标位置$cursorIndex");
    // 在每次选择@用户后ios设置光标位置。
    if (Platform.isIOS && isClickAtUser) {
      // 设置光标
      var setCursor = TextSelection(
        baseOffset: _textController.text.length,
        extentOffset: _textController.text.length,
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
        Future.delayed(Duration(milliseconds: 100), () {
          context.read<ChatEnterNotifier>().openAtCallback("");
        });
      }
    }
    isSwitchCursor = true;
  }

  initReleaseFeedInputFormatter() {
    _formatter = ReleaseFeedInputFormatter(
      controller: _textController,
      rules: context.read<ChatEnterNotifier>().rules,
      // @回调
      // ignore: missing_return
      triggerAtCallback: (String str) async {
        if (chatTypeId == RCConversationType.Group) {
          context.read<ChatEnterNotifier>().openAtCallback(str);
          isClickAtUser = false;
        }
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        context.read<ChatEnterNotifier>().openAtCallback("");
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

  /// 获得文本输入框样式
  List<RangeStyle> getTextFieldStyle(List<Rule> rules) {
    List<RangeStyle> result = [];
    for (Rule rule in rules) {
      result.add(
        RangeStyle(
          range: TextRange(start: rule.startIndex, end: rule.endIndex),
          style: TextStyle(color: AppColor.mainBlue),
        ),
      );
    }
    return result.length == 0 ? null : result;
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
    if (conversation.type == PRIVATE_TYPE) {
      BlackModel blackModel = await ProfileCheckBlack(int.parse(chatUserId));
      String text = "";
      if (blackModel.inYouBlack == 1) {
        text = "你已经将他拉黑了！";
      } else if (blackModel.inThisBlack == 1) {
        text = "他已经将你拉黑了！";
      }
      // print("--------------text:$text");
      ToastShow.show(msg: text, context: context);
    }
  }

  ///------------------------------------一些功能 方法  end-----------------------------------------------------------------------///
  ///------------------------------------各种点击事件  start-----------------------------------------------------------------------///

  //聊天内容的点击事件
  _messageInputBodyClick() {
    if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0) {
      if (mounted) {
        reload(() {
          _timerCount = 0;
          _emojiState = false;
          isContentClickOrEmojiClick = true;
        });
      }
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          reload(() {
            _timerCount = 0;
            isResizeToAvoidBottomInset = !_emojiState;
          });
        }
      });
    }
  }

  //表情的点击事件
  void onEmojioClick() {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      _emojiState = false;
    }
    _emojiState = !_emojiState;
    isResizeToAvoidBottomInset = !_emojiState;
    if (_emojiState) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    isContentClickOrEmojiClick = false;
    if (mounted) {
      reload(() {
        _timerCount = 0;
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
    String text = _textController.text;
    if (text == null || text.isEmpty || text.length < 1) {
      ToastShow.show(msg: "消息为空,请输入消息！", context: context);
      return;
    }
    _postText(text);
  }

  //录音按钮的点击事件
  _voiceOnTapClick() async {
    // await [Permission.microphone].request();

    _focusNode.unfocus();
    _emojiState = false;
    isContentClickOrEmojiClick = true;
    _isVoiceState = !_isVoiceState;
    if (mounted) {
      reload(() {
        _timerCount = 0;
      });
    }
  }

  //头部-更多按钮的点击事件
  _topMoreBtnClick(){
    _focusNode.unfocus();
    ToastShow.show(msg: "点击了更多那妞", context: context);
    judgeJumpPage(chatTypeId, this.chatUserId, conversation.type, context, chatUserName,
        _morePageOnClick, _moreOnClickExitChatPage);
  }

  //更多的界面-里面进行了一些的点击事件
  _morePageOnClick(int type, String name){
    //type  0-用户名  1--群名 2--拉黑 3--邀请不是相互关注-进行提醒
    if (type == 0) {
      //修改了用户名
      Application.chatGroupUserModelMap.clear();
      for (ChatGroupUserModel userModel in context.read<GroupUserProfileNotifier>().chatGroupUserModelList) {
        Application.chatGroupUserModelMap[userModel.uid.toString()] = userModel.groupNickName;
      }
      delayedSetState();
    } else if (type == 1) {
      chatUserName = name;
      //修改了群名
      // _postUpdateGroupName(name);
    } else if (type == 2) {
      //拉黑
      _insertMessageMenu("你拉黑了这个用户!");
    } else {
      //不是还有关系不能邀请进群
      _insertMessageMenu(name + " 邀请失败!");
    }
  }

  //更多界面点击了退出群聊-要退出聊天界面
  _moreOnClickExitChatPage(){
    //退出群聊
    MessageManager.removeConversation(context, chatUserId, Application.profile.uid, conversation.type);
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pop();
    });
  }

  //头部显示的关注按钮的点击事件
  _attntionOnClick()async{
    if (conversation.type == PRIVATE_TYPE) {
      BlackModel blackModel = await ProfileCheckBlack(int.parse(chatUserId));
      String text = "";
      if (blackModel.inYouBlack == 1) {
        text = "关注失败，你已将对方加入黑名单";
      } else if (blackModel.inThisBlack == 1) {
        text = "关注失败，你已被对方加入黑名单";
      } else {
        int attntionResult = await ProfileAddFollow(int.parse(chatUserId));
        if (attntionResult == 1 || attntionResult == 3) {
          text = "关注成功!";
          isShowTopAttentionUi = false;
          if (mounted) {
            reload(() {});
          }
             if(context.read<ProfilePageNotifier>().profileUiChangeModel.containsKey(int.parse(chatUserId))){
               print('=================个人主页同步');
            context.read<ProfilePageNotifier>().changeIsFollow(true,false, int.parse(chatUserId));
             }
        }
      }
      ToastShow.show(msg: text, context: context);
    } else {
      isShowTopAttentionUi = false;
      if (mounted) {
        reload(() {});
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
          //print("已经添加过了");
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
      context.read<ChatEnterNotifier>().setAtSearchStr("");
      // 关闭视图
      context.read<ChatEnterNotifier>().openAtCallback("");
    });
  }

  //刷新数据--加载更多以前的数据
  _onRefresh() async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(conversation.getType(),
        conversation.conversationId, chatDataList[chatDataList.length - 1].msg.sentTime, 20, 0);
    List<ChatDataModel> dataList = <ChatDataModel>[];
    if (msgList != null && msgList.length > 0) {
      dataList.clear();
      for (int i = 1; i < msgList.length; i++) {
        dataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
      if (dataList != null && dataList.length > 0) {
        getTimeAlert(dataList);
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
          _timerCount = 0;
        });
      }
    });
  }

  //加载更多的系统消息
  _onRefreshSystemInformation() async {
    List<ChatDataModel> dataList = await getSystemInformationNet();
    if (dataList != null && dataList.length > 0) {
      getTimeAlert(dataList);
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
    _timerCount = 0;
    _refreshController.loadComplete();
    delayedSetState();
  }

  //所有的item长按事件
  void onItemLongClickCallBack(
      {int position, String settingType, Map<String, dynamic> map, String contentType, String content}) {
    if (isPersonalButler && position != null) {
      position--;
    }

    if (settingType == null || settingType.isEmpty || settingType.length < 1) {
      //print("暂无此配置");
    } else if (settingType == "删除") {
      RongCloud.init().deleteMessageById(chatDataList[position].msg, (code) {
        //print("====" + code.toString());
        if (mounted) {
          reload(() {
            _timerCount = 0;
            chatDataList.removeAt(position);
          });
        }
      });
      // ToastShow.show(msg: "删除-第$position个", context: context);
    } else if (settingType == "撤回") {
      recallMessage(chatDataList[position].msg, position);
    } else if (settingType == "复制") {
      if (context != null && content != null) {
        Clipboard.setData(ClipboardData(text: content));
        ToastShow.show(msg: "复制成功", context: context);
      }
    } else {
      //print("暂无此配置");
    }
    //print("position:$position-----------------------------------------");
    // //print("position：$position--$contentType---${content==null?map.toString():content}----${chatDataList[position].msg.toString()}");
  }

  // 请求动态详情页数据
  getFeedDetail(int feedId) async {
    HomeFeedModel feedModel = await feedDetail(id: feedId);
    List<HomeFeedModel> list = [];
    list.add(feedModel);
    context.read<FeedMapNotifier>().updateFeedMap(list);
    // print("----------feedModel:${feedModel.toJson().toString()}");
    // 跳转动态详情页
    AppRouter.navigateFeedDetailPage(context: context, model:feedModel, type:1);
  }

  //所有的item点击事件
  void onMessageClickCallBack(
      {String contentType, String content, int position, Map<String, dynamic> map, bool isUrl, String msgId}) {
    if (isPersonalButler && position != null) {
      position--;
    }

    if (contentType == null || contentType.isEmpty || contentType.length < 1) {
      //print("暂无此配置");
    }
    if (contentType == ChatTypeModel.MESSAGE_TYPE_TEXT && isUrl) {
      ToastShow.show(msg: "跳转网页地址: $content", context: context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_FEED) {
      ToastShow.show(msg: "跳转动态详情页", context: context);
      getFeedDetail(map["id"]);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      ToastShow.show(msg: "跳转播放视频页-$content", context: context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      ToastShow.show(msg: "跳转放大图片页-$content", context: context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_USER) {
      // ToastShow.show(msg: "跳转用户界面", context: context);
      AppRouter.navigateToMineDetail(context,map["uid"]);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
      // ToastShow.show(msg: "跳转直播课详情界面", context: context);
      LiveVideoModel liveModel = LiveVideoModel.fromJson(map);
      AppRouter.navigateToLiveDetail(context, liveModel.id, heroTag: msgId, liveModel: liveModel);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
      // ToastShow.show(msg: "跳转视频课详情界面", context: context);
      LiveVideoModel videoModel = LiveVideoModel.fromJson(map);
      AppRouter.navigateToVideoDetail(context, videoModel.id, heroTag: msgId, videoModel: videoModel);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      ToastShow.show(msg: "播放录音", context: context);
      updateMessage(chatDataList[position], (code) {
        if (mounted) {
          reload(() {
            _timerCount = 0;
          });
        }
      });
    } else if (contentType == RecallNotificationMessage.objectName) {
      recallNotificationMessagePosition = position;
      print("position:$position");
      ToastShow.show(msg: "重新编辑消息", context: context);
      // FocusScope.of(context).requestFocus(_focusNode);
      _textController.text = json.decode(map["content"])["data"];
      var setCursor = TextSelection(
        baseOffset: _textController.text.length,
        extentOffset: _textController.text.length,
      );
      _textController.selection = setCursor;
      if (mounted) {
        reload(() {
          _timerCount = 0;
        });
      }
    } else if (contentType == ChatTypeModel.CHAT_SYSTEM_BOTTOM_BAR) {
      ToastShow.show(msg: "管家界面-底部点击了：$content", context: context);
      _postSelectMessage(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      ToastShow.show(msg: "选择列表选择了-底部点击了：$content", context: context);
      // _textController.text=content;
      _postText(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_CLICK_ERROR_BTN) {
      print("点击了发送失败的按钮-重新发送：$position");
      _resetPostMessage(position);
      // _textController.text=content;
      // _postText(content);
    } else {
      //print("暂无此类型");
    }
  }

  ///------------------------------------各种点击事件  end-----------------------------------------------------------------------///
}
