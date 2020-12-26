import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/message/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'chat_details_body.dart';
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
  final _ChatPageState _state = _ChatPageState();
  final ConversationDto conversation;
  final Message shareMessage;

  ChatPage({Key key, @required this.conversation, this.shareMessage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  //所有的会话消息
  List<ChatDataModel> chatDataList = <ChatDataModel>[];

  bool _emojiState = false;
  bool _isVoiceState = false;
  TextEditingController _textController = TextEditingController();
  FocusNode _focusNode = new FocusNode();
  ScrollController _scrollController = ScrollController();
  bool isHaveTextLen = false;
  bool isContentClickOrEmojiClick = true;
  bool isResizeToAvoidBottomInset = true;
  List<EmojiModel> emojiModelList = <EmojiModel>[];

  String chatUserName;
  String chatUserId;
  String chatType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
        () => FocusScope.of(context).requestFocus(new FocusNode()));
    initData();
    initSetData();
  }

  @override
  Widget build(BuildContext context) {
    if (chatUserName == null) {
      initData();
    }
    var body = [
      (chatDataList != null && chatDataList.length > 0) ?
      ChatDetailsBody(
        sC: _scrollController,
        chatData: chatDataList,
        vsync: this,
      )
          : Spacer(),
      getMessageInputBar(),
      bottomSettingBox(),
    ];

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: isResizeToAvoidBottomInset,
        appBar: AppBar(
          title: Text(
            chatUserName + "-" + chatType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  print("-----------------------");
                  ToastShow.show(msg: "点击了更多那妞", context: context);
                },
              ),
            )
          ],
        ),
        body: MessageInputBody(
          onTap: () => _messageInputBodyClick(),
          decoration: BoxDecoration(color: Color(0xffefefef)),
          child: Column(children: body),
        ),
      ),
      onWillPop: _requestPop,
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
        value: _textController.text,
        onTap: () {
          print("231");
          _handleSubmittedData();
        },
        moreTap: () => onPicAndVideoBtnClick(),
      ),
      id: null,
      type: null,
    );
  }

  //输入框bar内的edit
  Widget edit(context, size) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      // 多行展示
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //不限制行数
      // 光标颜色
      cursorColor: Color.fromRGBO(253, 137, 140, 1),
      scrollPadding: EdgeInsets.all(0),
      style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
      //内容改变的回调
      onChanged: _changTextLen,
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
    if (!_focusNode.hasFocus &&
        MediaQuery.of(context).viewInsets.bottom > 0 &&
        !isContentClickOrEmojiClick) {
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
    double emojiHeight =
    Application.keyboardHeight > 0 ? Application.keyboardHeight : 300;
    if (!_emojiState) {
      emojiHeight = 0.0;
    }
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
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: emojiModelList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1),
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
                  onPressed: () => _handleSubmittedData(),
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


  //聊天内容的点击事件
  _messageInputBodyClick() {
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
    bool isReset = false;
    if (StringUtil.strNoEmpty(text)) {
      if (!isHaveTextLen) {
        isReset = true;
        isHaveTextLen = true;
      }
    } else {
      if (isHaveTextLen) {
        isReset = true;
        isHaveTextLen = false;
      }
    }
    if (isReset) {
      setState(() {});
    }
  }


  //初始化一些数据
  void initData() {
    chatUserName = "聊天界面";
    chatUserId = "0";
    chatType = "测试聊天";
    if (widget.conversation == null) {
      print("未知信息");
    } else {
      chatUserName = widget.conversation.name;
      chatUserId = widget.conversation.conversationId;
      chatType = getMessageType(widget.conversation, context);
    }
  }


  //初始化一些数据
  void initSetData() async {
    List msgList = new List();
    msgList =
    await RongCloud.init().getHistoryMessages(widget.conversation.type,
        widget.conversation.conversationId,
        new DateTime.now().millisecondsSinceEpoch, 30, 0);
    if (msgList != null && msgList.length > 0) {
      for (int i = 0; i < msgList.length; i++) {
        chatDataList.add(
            getMessage((msgList[i] as Message), isHaveAnimation: false));
      }
    }
    if (widget.shareMessage != null) {
      chatDataList[chatDataList.length - 1].isHaveAnimation = true;
      // if(chatDataList[chatDataList.length-1].msg.messageId==widget.shareMessage?.messageId){
      //   chatDataList[chatDataList.length-1].isHaveAnimation=true;
      // }else{
      //   chatDataList.insert(0, getMessage(widget.shareMessage));
      // }
    }
    //获取欧表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {});
    });
  }

  //表情的点击事件
  void onEmojioClick() {
    if (MediaQuery
        .of(context)
        .viewInsets
        .bottom > 0) {
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
    print("=====图片的点击事件");
    SelectedMediaFiles selectedMediaFiles = new SelectedMediaFiles();
    AppRouter.navigateToMediaPickerPage(
        context,
        9,
        typeImageAndVideo,
        false,
        startPageGallery,
        false,
        false,
            (result) async {
          SelectedMediaFiles files = Application.selectedMediaFiles;
          if (true != result || files == null) {
            print("没有选择媒体文件");
            return;
          }
          Application.selectedMediaFiles = null;
          selectedMediaFiles.type = files.type;
          selectedMediaFiles.list = files.list;
          _handPicOrVideo(selectedMediaFiles);
        });
  }

  //发送文字信息
  _handleSubmittedData() async {
    String text = _textController.text;
    ChatDataModel chatDataModel = new ChatDataModel();
    chatDataModel.type = ChatTypeModel.MESSAGE_TYPE_TEXT;
    chatDataModel.content = text;
    chatDataModel.isTemporary = true;
    chatDataModel.isHaveAnimation = true;
    chatDataList.insert(0, chatDataModel);
    setState(() {
      _textController.text = "";
      isHaveTextLen = false;
    });
    postText(chatDataList[0], widget.conversation.conversationId, () {
      setState(() {

      });
    });
  }

  //发送视频以及图片
  _handPicOrVideo(SelectedMediaFiles selectedMediaFiles) {
    List<ChatDataModel> modelList = <ChatDataModel>[];
    for (int i = 0; i < selectedMediaFiles.list.length; i++) {
      ChatDataModel chatDataModel = new ChatDataModel();
      chatDataModel.type =
      (selectedMediaFiles.type == mediaTypeKeyVideo ? ChatTypeModel
          .MESSAGE_TYPE_VIDEO : ChatTypeModel.MESSAGE_TYPE_IMAGE);
      chatDataModel.mediaFileModel = selectedMediaFiles.list[i];
      chatDataModel.isTemporary = true;
      chatDataModel.isHaveAnimation = true;
      chatDataList.insert(0, chatDataModel);
      modelList.add(chatDataList[0]);
    }
    setState(() {});
    postImgOrVideo(modelList, widget.conversation.conversationId,
        selectedMediaFiles.type, () {
          setState(() {

          });
        });
  }

  //录音按钮的点击事件
  _voiceOnTapClick() async {
    await [Permission.speech].request();
    _focusNode.unfocus();
    _emojiState = false;
    isContentClickOrEmojiClick = true;
    _isVoiceState = !_isVoiceState;
    setState(() {

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
    setState(() {});
    postVoice(chatDataList[0], widget.conversation.conversationId, () {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<VoiceSettingNotifier>().stop();
    super.dispose();
  }

}
