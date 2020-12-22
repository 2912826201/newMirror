import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/page/message/test_message_post.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';

import 'ChatDetailsBody.dart';
import 'item/chat_more_icon.dart';
import 'item/emoji_manager.dart';
import 'item/message_body_input.dart';
import 'item/message_input_bar.dart';

////////////////////////////////
//
/////////////聊天会话页面
//
///////////////////////////////

enum ButtonType { voice, more }

class ChatPage1 extends StatefulWidget {
  final _ChatPageState1 _state = _ChatPageState1();

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class _ChatPageState1 extends State<ChatPage1>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<ChatDataModel> chatDataList = <ChatDataModel>[];
  bool _emojiState = false;
  TextEditingController _textController = TextEditingController();
  FocusNode _focusNode = new FocusNode();
  ScrollController _scrollController = ScrollController();
  bool isHaveTextLen = false;
  double bottomSettingBoxHeight = Application.keyboardHeight;
  bool isContentClickOrEmojiClick = true;
  bool isResizeToAvoidBottomInset = true;
  List<EmojiModel> emojiModelList = <EmojiModel>[];

  @override
  void initState() {
    super.initState();
    //初始化
    WidgetsBinding.instance.addObserver(this);
    _getEmojiModelList();
  }

  @override
  Widget build(BuildContext context) {
    var body = [
      (chatDataList != null && chatDataList.length > 0)
          ? ChatDetailsBody(
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
            "聊天界面" * 10,
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
      voiceOnTap: null,
      onEmojio: () {
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
      },
      isVoice: false,
      edit: edit,
      value: _textController.text,
      more: ChatMoreIcon(
        value: _textController.text,
        onTap: () {
          _handleSubmittedData();
        },
        moreTap: () => onTapHandle(ButtonType.more),
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
              height: bottomSettingBoxHeight,
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

  //发送文字信息
  _handleSubmittedData() {
    String text = _textController.text;
    chatDataList.insert(0, postText(text));
    setState(() {
      _textController.text = "";
      isHaveTextLen = false;
    });
  }

  onTapHandle(ButtonType type) {
    // print("=====${type}");
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

  //获取表情的数据
  _getEmojiModelList() async {
    emojiModelList = await EmojiManager.getEmojiModelList();
    setState(() {});
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

  @override
  void dispose() {
    //销毁
    WidgetsBinding.instance.removeObserver(this);
    // _childController.dispose();
    super.dispose();
  }

  //键盘的监听
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        //关闭键盘
      } else {
        //显示键盘
        if (bottomSettingBoxHeight <= Application.keyboardHeight) {
          bottomSettingBoxHeight = Application.keyboardHeight;
          setState(() {});
        }
      }
    });
  }
}
