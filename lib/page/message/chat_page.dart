import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
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
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
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

////////////////////////////////
//
/////////////聊天会话页面
//
///////////////////////////////

class ChatPage extends StatefulWidget {
  final ChatPageState state = ChatPageState();
  final ConversationDto conversation;
  final Message shareMessage;

  ChatPage({Key key, @required this.conversation, this.shareMessage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    initData();
    initSetData();
    initTime();
    initTextController();
    initReleaseFeedInputFormatter();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (loadStatus == LoadingStatus.STATUS_IDEL) {
          // 先设置状态，防止下拉就直接加载
          setState(() {
            loadText = "加载中...";
            loadStatus = LoadingStatus.STATUS_LOADING;
          });
          _onRefresh();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chatUserName == null) {
      initData();
    }
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: isResizeToAvoidBottomInset,
        appBar: getAppBar(),
        body: MessageInputBody(
          onTap: () => _messageInputBodyClick(),
          decoration: BoxDecoration(color: Color(0xffefefef)),
          child: Column(children: getBody()),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Application.chatGroupUserModelList.clear();
    if (Application.appContext != null) {
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
    return [
      Expanded(
        child: SizedBox(
          child: Stack(
            fit: StackFit.expand,
            children: [
              (chatDataList != null && chatDataList.length > 0) ? getChatDetailsBody() : Container(),
              ChatAtUserList(
                  isShow: context.watch<ChatEnterNotifier>().keyWord == "@", onItemClickListener: atListItemClick),
            ],
          ),
        ),
      ),
      getMessageInputBar(),
      bottomSettingBox(),
      Offstage(
        offstage: true,
        child: judgeReceiveMessages(),
      )
    ];
  }

  //获取列表内容
  Widget getChatDetailsBody() {
    return ChatDetailsBody(
      scrollController: _scrollController,
      chatDataList: chatDataList,
      onTap: () => _messageInputBodyClick(),
      vsync: this,
      voidItemLongClickCallBack: onItemLongClickCallBack,
      voidMessageClickCallBack: onMessageClickCallBack,
      chatUserName: chatUserName,
      isPersonalButler: isPersonalButler,
      refreshController: _refreshController,
      isHaveAtMeMsg: isHaveAtMeMsg,
      isHaveAtMeMsgIndex: isHaveAtMeMsgIndex,
      onRefresh: _onRefresh,
      loadText: loadText,
      loadStatus: loadStatus,
      isShowChatUserName: widget.conversation.getType() == RCConversationType.Group,
      onAtUiClickListener: onAtUiClickListener,
      firstEndCallback: (int firstIndex, int lastIndex) {
        firstEndCallbackListView(firstIndex, lastIndex);
      },
    );
  }

  //获取appbar
  Widget getAppBar() {
    return AppBar(
      title: GestureDetector(
        child: Text(
          chatUserName + "-" + chatType,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Message msg = chatDataList[chatDataList.length - 2].msg;
          AtMsg atMsg = new AtMsg(groupId: int.parse(msg.targetId), sendTime: msg.sentTime, messageUId: msg.messageUId);
          Application.atMesGroupModel.add(atMsg);
        },
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              //print("-----------------------");
              _focusNode.unfocus();
              ToastShow.show(msg: "点击了更多那妞", context: context);
              judgeJumpPage(chatTypeId, this.chatUserId, widget.conversation.type, context, chatUserName, () {
                Application.chatGroupUserModelMap.clear();
                for (ChatGroupUserModel userModel in Application.chatGroupUserModelList) {
                  Application.chatGroupUserModelMap[userModel.uid.toString()] = userModel.groupNickName;
                }
                delayedSetState();
              }, () {
                //退出群聊
                MessageManager.removeConversation(
                    context, chatUserId, Application.profile.uid, widget.conversation.type);
                Navigator.of(context).pop();
              });
            },
          ),
        )
      ],
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
    return TextSpanField(
      controller: _textController,
      focusNode: _focusNode,
      // 多行展示
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //不限制行数
      // 光标颜色
      cursorColor: Color.fromRGBO(253, 137, 140, 1),
      scrollPadding: EdgeInsets.all(0),
      inputFormatters: [_formatter],
      style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
      rangeStyles: getTextFieldStyle(Application.appContext.read<ChatEnterNotifier>().rules),
      //内容改变的回调
      onChanged: _changTextLen,
      // rangeStyles: getTextFieldStyle(rules),
      // 装饰器修改外观
      decoration: InputDecoration(
        // 去除下滑线
        border: InputBorder.none,
        // 提示文本
        hintText: "\uD83D\uDE02123\uD83D\uDE01",
        // 提示文本样式
        hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
        // 设置为true,contentPadding才会生效，TextField会有默认高度。
        isCollapsed: true,
        contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
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
      color: Colors.white,
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
    //
    return AnimatedContainer(
      height: emojiHeight,
      duration: Duration(milliseconds: 300),
      child: Offstage(
        offstage: !_emojiState,
        child: Container(
          height: emojiHeight,
          width: double.infinity,
          color: Colors.white,
          child: emojiList(),
        ),
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
        setState(() {});
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
      setState(() {});
    }
  }

  //初始化一些数据
  void initData() {
    chatUserName = "聊天界面";
    chatUserId = "0";
    chatType = "测试聊天";
    chatTypeId = RCConversationType.Private;
    isPersonalButler = false;
    if (widget.conversation == null) {
      //print("未知信息");
    } else {
      // //print("-*----------------------"+widget.conversation.toMap().toString());
      chatUserName = widget.conversation.name;
      chatUserId = widget.conversation.conversationId;
      chatType = getMessageType(widget.conversation, context);
      chatTypeId = widget.conversation.getType();

      if (widget.conversation.type == MANAGER_TYPE) {
        isPersonalButler = true;
      }
    }
    context.read<ChatMessageProfileNotifier>().setData(chatTypeId, chatUserId);
    if (chatTypeId == RCConversationType.Group) {
      getChatGroupUserModelList(chatUserId);
    }
  }

  //初始化一些数据
  void initSetData() async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(widget.conversation.getType(),
        widget.conversation.conversationId, new DateTime.now().millisecondsSinceEpoch, 20, 0);
    print("历史记录${msgList.length}");
    if (msgList != null && msgList.length > 0) {
      for (int i = 0; i < msgList.length; i++) {
        chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
    }
    if (widget.shareMessage != null) {
      chatDataList[0].isHaveAnimation = true;
      // if(chatDataList[chatDataList.length-1].msg.messageId==widget.shareMessage?.messageId){
      //   chatDataList[chatDataList.length-1].isHaveAnimation=true;
      // }else{
      //   chatDataList.insert(0, getMessage(widget.shareMessage));
      // }
    }

    //判断是不是加入时间提示
    // postTimeChatDataModel(isSetState: false);

    //获取有没有at我的消息
    judgeIsHaveAtMeMsg();

    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {});
    });
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
        msgList = await RongCloud.init().getHistoryMessages(widget.conversation.getType(),
            widget.conversation.conversationId, chatDataList[chatDataList.length - 1].msg.sentTime, 20, 0);
        if (msgList != null && msgList.length > 0) {
          for (int i = 1; i < msgList.length; i++) {
            chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
          }
          judgeNewChatIsHaveAt();
        } else {
          isHaveAtMeMsgIndex = -1;
          isHaveAtMeMsg = false;
          isHaveAtMeMsgPr = false;
          Application.atMesGroupModel.remove(atMeMsg);
          break;
        }

        setState(() {});
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
      int count = 0;
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
    mentionedInfo.mentionedContent = gteAtUserName(atUserIdList);
    chatDataModel.mentionedInfo = mentionedInfo;

    chatDataList.insert(0, chatDataModel);
    animateToBottom();
    setState(() {
      _textController.text = "";
      isHaveTextLen = false;
    });

    postText(chatDataList[0], widget.conversation.conversationId, chatTypeId, mentionedInfo, () {
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
      chatDataList.insert(0, chatDataModel);
      modelList.add(chatDataList[0]);
    }
    animateToBottom();
    setState(() {});
    postImgOrVideo(modelList, widget.conversation.conversationId, selectedMediaFiles.type, chatTypeId, () {
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
    chatDataList.insert(0, chatDataModel);
    animateToBottom();
    setState(() {});
    postVoice(chatDataList[0], widget.conversation.conversationId, chatTypeId, chatTypeId, () {
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
    chatDataList.insert(0, chatDataModel);
    animateToBottom();
    setState(() {
      _textController.text = "";
      isHaveTextLen = false;
    });
    postSelectMessage(chatDataList[0], widget.conversation.conversationId, chatTypeId, () {
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
      animateToBottom();
      setState(() {});
    }
  }

  //发送间隔时间
  void postTimeChatDataModel({bool isSetState = true}) {
    if (chatDataList != null && chatDataList.length > 0 && chatDataList[0].msg != null && !getNewestIsAlertMessage()) {
      getTimeChatDataModel(
        targetId: widget.conversation.conversationId,
        conversationType: chatTypeId,
        finished: (Message msg, int code) {
          ChatDataModel chatDataModel = new ChatDataModel();
          chatDataModel.msg = msg;
          chatDataModel.isTemporary = false;
          chatDataModel.isHaveAnimation = true;
          chatDataList.insert(0, chatDataModel);
          animateToBottom();
          if (isSetState) {
            setState(() {});
          }
        },
      );
    }
  }

  ///------------------------------------发送消息  end-----------------------------------------------------------------------///
  ///------------------------------------一些功能 方法  start-----------------------------------------------------------------------///

  //判断最后一个消息是不是时间提示
  bool getNewestIsAlertMessage() {
    try {
      bool isTextMessage = chatDataList[0].msg.objectName == TextMessage.objectName;
      if (isTextMessage) {
        TextMessage textMessage = chatDataList[0].msg.content as TextMessage;
        Map<String, dynamic> map = json.decode(textMessage.content);
        bool isAlertTimeMessage = map["type"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME;
        if (isAlertTimeMessage) {
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  //计时
  initTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timerCount++;
      // //print(_timerCount.toString());
      if (_timerCount >= 300) {
        _timerCount = 0;
        // //print("-----"+_timerCount.toString());
        postTimeChatDataModel();
      }
    });
  }

  //延迟更新
  void delayedSetState() {
    Future.delayed(Duration(milliseconds: 200), () {
      //print("setState--delayedSetState");
      setState(() {});
    });
  }

//判断接收消息
  Widget judgeReceiveMessages() {
    return Consumer<ChatMessageProfileNotifier>(
      builder: (context, notifier, child) {
        Message message = context.select((ChatMessageProfileNotifier value) => value.message);
        bool isSettingStatus = context.select((ChatMessageProfileNotifier value) => value.isSettingStatus);
        if (message == null || message.targetId != this.chatUserId && message.conversationType != chatTypeId) {
          if (isSettingStatus) {
            return judgeResetStatus();
          }
          return Container();
        } else {
          Application.appContext.read<ChatMessageProfileNotifier>().clearMessage();
        }
        ChatDataModel chatDataModel = getMessage(message, isHaveAnimation: true);
        chatDataList.insert(0, chatDataModel);
        delayedSetState();
        return Container();
      },
    );
  }

  //判断有没有刷新消息的状态
  Widget judgeResetStatus() {
    Application.appContext.read<ChatMessageProfileNotifier>().setSettingStatus(false);
    int messageId = context.select((ChatMessageProfileNotifier value) => value.messageId);
    int status = context.select((ChatMessageProfileNotifier value) => value.status);
    if (messageId == null || status == null || chatDataList == null || chatDataList.length < 1) {
      return Container();
    } else {
      for (ChatDataModel dataModel in chatDataList) {
        if (dataModel.msg?.messageId == messageId) {
          if (dataModel.msg?.sentStatus == status) {
            return Container();
          } else {
            dataModel.msg?.sentStatus = status;
            delayedSetState();
            return Container();
          }
        }
      }
    }
  }

  initTextController() {
    _textController.addListener(() {
      // //print("值改变了");
      // //print("监听文字光标${_textController.selection}");
      // // 每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      // //print("::::::$isSwitchCursor");
      if (isSwitchCursor) {
        List<Rule> rules = context
            .read<ChatEnterNotifier>()
            .rules;
        int atIndex = context
            .read<ChatEnterNotifier>()
            .atCursorIndex;

        // 获取光标位置
        int cursorIndex = _textController.selection.baseOffset;
        for (Rule rule in rules) {
          // 是否光标点击到了@区域
          if (cursorIndex >= rule.startIndex && cursorIndex <= rule.endIndex) {
            // 获取中间值用此方法是因为当atRule.startIndex和atRule.endIndex为负数时不会溢出。
            int median = rule.startIndex + (rule.endIndex - rule.startIndex) ~/ 2;
            TextSelection setCursor;
            if (cursorIndex > median) {
              setCursor = TextSelection(
                baseOffset: rule.endIndex,
                extentOffset: rule.endIndex,
              );
            }
            if (cursorIndex <= median) {
              setCursor = TextSelection(
                baseOffset: rule.startIndex,
                extentOffset: rule.startIndex,
              );
            }
            // 设置光标
            _textController.selection = setCursor;
          }
        }
        // 唤起@#后切换光标关闭视图
        if (cursorIndex != atIndex) {
          context.read<ChatEnterNotifier>().openAtCallback("");
        }
      }
      isSwitchCursor = true;
    });
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
        }
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        context.read<ChatEnterNotifier>().openAtCallback("");
      },
      valueChangedCallback:
          (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr, String topicSearchStr) {
        rules = rules;
        // //print("输入框值回调：$value");
        // //print(rules);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<ChatEnterNotifier>().getAtCursorIndex(atIndex);
        }
        context.read<ChatEnterNotifier>().setAtSearchStr(atSearchStr);
        context.read<ChatEnterNotifier>().changeCallback(value);
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
      oldMaxScrollExtent += 50.0;
    }
    _scrollController.animateTo(oldMaxScrollExtent,
        duration: Duration(milliseconds: milliseconds), curve: Curves.easeInOut);
  }

  ///------------------------------------一些功能 方法  end-----------------------------------------------------------------------///
  ///------------------------------------各种点击事件  start-----------------------------------------------------------------------///

  //聊天内容的点击事件
  _messageInputBodyClick() {
    if (_emojiState || MediaQuery.of(context).viewInsets.bottom > 0) {
      setState(() {
        _emojiState = false;
        isContentClickOrEmojiClick = true;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          isResizeToAvoidBottomInset = !_emojiState;
        });
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
    setState(() {});
  }

  //图片的点击事件
  onPicAndVideoBtnClick() {
    //print("=====图片的点击事件");
    _focusNode.unfocus();
    SelectedMediaFiles selectedMediaFiles = new SelectedMediaFiles();
    AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, false, startPageGallery, false, false,
        (result) async {
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
    await [Permission.microphone].request();

    _focusNode.unfocus();
    _emojiState = false;
    isContentClickOrEmojiClick = true;
    _isVoiceState = !_isVoiceState;
    setState(() {});
  }

  //at 了那个用户
  void atListItemClick(ChatGroupUserModel userModel, int index) {
    // //print("+++++++++++++++++++++++++++++++++++++++++++++++++++" + content);
    // At的文字长度
    int atLength = userModel.nickName.length + 1;
    // 获取输入框内的规则
    var rules = context.read<ChatEnterNotifier>().rules;
    // 检测是否添加过
    // if (rules.isNotEmpty) {
    //   for (Rule rule in rules) {
    //     if (rule.clickIndex == index && rule.isAt == true) {
    //       //print("已经添加过了");
    //       return;
    //     }
    //   }
    // }
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
    if (searchStr != "" || searchStr.isNotEmpty) {
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
    //print("controller.text:${_textController.text}");
    // 这是替换输入的文本修改后面输入的@的规则
    if (searchStr != "" || searchStr.isNotEmpty) {
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
    var setCursor = TextSelection(
      baseOffset: _textController.text.length,
      extentOffset: _textController.text.length,
    );
    //print("设置光标$setCursor");
    _textController.selection = setCursor;
    context.read<ChatEnterNotifier>().setAtSearchStr("");
    // 关闭视图
    context.read<ChatEnterNotifier>().openAtCallback("");
  }

  //刷新数据--加载更多以前的数据
  _onRefresh() async {
    List msgList = new List();
    msgList = await RongCloud.init().getHistoryMessages(widget.conversation.getType(),
        widget.conversation.conversationId, chatDataList[chatDataList.length - 1].msg.sentTime, 30, 0);
    if (msgList != null && msgList.length > 0) {
      for (int i = 1; i < msgList.length; i++) {
        chatDataList.add(getMessage((msgList[i] as Message), isHaveAnimation: false));
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
      setState(() {});
    });
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
        setState(() {
          chatDataList.removeAt(position);
        });
      });
      // ToastShow.show(msg: "删除-第$position个", context: context);
    } else if (settingType == "撤回") {
      recallMessage(chatDataList[position].msg, position);
    } else if (settingType == "复制") {
      if (context != null && content.isNotEmpty) {
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
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => FeedDetailPage(model: feedModel)),
    );
  }

  //所有的item点击事件
  void onMessageClickCallBack(
      {String contentType, String content, int position, Map<String, dynamic> map, bool isUrl}) {
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
      jumpPage(ProfileDetailPage(userId: map["uid"]), false, context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
      ToastShow.show(msg: "跳转直播课详情界面", context: context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
      ToastShow.show(msg: "跳转视频课详情界面", context: context);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      ToastShow.show(msg: "播放录音", context: context);
      updateMessage(chatDataList[position], (code) {
        setState(() {});
      });
    } else if (contentType == RecallNotificationMessage.objectName) {
      ToastShow.show(msg: "重新编辑消息", context: context);
      // FocusScope.of(context).requestFocus(_focusNode);
      _textController.text = json.decode(map["content"])["content"];
      setState(() {});
    } else if (contentType == ChatTypeModel.CHAT_SYSTEM_BOTTOM_BAR) {
      ToastShow.show(msg: "管家界面-底部点击了：$content", context: context);
      _postSelectMessage(content);
    } else if (contentType == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      ToastShow.show(msg: "选择列表选择了-底部点击了：$content", context: context);
      // _textController.text=content;
      _postText(content);
    } else {
      //print("暂无此类型");
    }
  }

  ///------------------------------------各种点击事件  end-----------------------------------------------------------------------///
}
