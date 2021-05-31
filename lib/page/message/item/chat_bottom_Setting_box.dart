import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_enter_notifier.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:provider/provider.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';

import 'emoji_manager.dart';

class ChatBottomSettingBox extends StatefulWidget {
  final bool bottomSettingPanelState;
  final bool emojiState;
  final TextEditingController textController;
  final Function(int cursorIndexPr) callBackCursorIndexPr;
  final Function(String text) changTextLen;
  final Function() deleteEditText;
  final Function() onSubmitClick;
  final FocusNode focusNode;
  final ScrollController textScrollController;

  ChatBottomSettingBox(
      {Key key,
      this.bottomSettingPanelState,
      this.emojiState,
      this.textController,
      this.callBackCursorIndexPr,
      this.changTextLen,
      this.focusNode,
      this.deleteEditText,
      this.onSubmitClick,
      this.textScrollController})
      : super(key: key);

  @override
  ChatBottomSettingBoxState createState() => ChatBottomSettingBoxState(bottomSettingPanelState, emojiState);
}

class ChatBottomSettingBoxState extends State<ChatBottomSettingBox> {
  bool bottomSettingPanelState;
  bool emojiState;
  int cursorIndexPr = 0;

  List<EmojiModel> emojiModelList = [];

  ChatBottomSettingBoxState(this.bottomSettingPanelState, this.emojiState);

  @override
  void initState() {
    EventBus.getDefault().registerSingleParameter(_resetPostBtn, EVENTBUS_CHAT_PAGE, registerName: CHAT_BOTTOM_MORE_BTN);
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_BOTTOM_MORE_BTN);
  }

  _resetPostBtn(bool isVoiceState) {
    if (mounted) {
      setState(() {});
    }
  }

  _initData() async {
    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: emojiState ? 0.0 : MediaQuery.of(context).padding.bottom,
            color: AppColor.white,
          ),
          Stack(
            children: [
              bottomSettingPanel(getKeyBoardHeight()),
              emoji(getKeyBoardHeight()),
            ],
          ),
        ],
      ),
    );
  }

  //表情框
  Widget emoji(double keyboardHeight) {
    keyboardHeight += MediaQuery.of(context).padding.bottom;
    double height = emojiState ? keyboardHeight : 0.0;
    return AnimatedContainer(
      duration: height > 0 ? Duration.zero : Duration(milliseconds: 40),
      height: height,
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColor.white,
        child: emojiState ? emojiList(keyboardHeight) : Container(),
      ),
    );
  }

  Widget bottomSettingPanel(double keyboardHeight) {
    //print("bottomSettingPanelState:$bottomSettingPanelState");
    //print("widget.textController:${widget.textController.text},${widget.textController.selection.baseOffset}");
    double height = bottomSettingPanelState ? keyboardHeight : 0.0;
    return AnimatedContainer(
      duration: height > 0 ? Duration.zero : Duration(milliseconds: 40),
      height: height,
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColor.white,
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
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery
                        .of(context)
                        .padding
                        .bottom,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      );
    }
  }

  //表情的bar
  Widget _emojiBottomBox() {
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
          //表情面板删除按钮
          AppIconButton(
            iconSize: 24,
            svgName: AppIcon.message_delete,
            buttonWidth: 44,
            buttonHeight: 44,
            onTap: () {
              if (widget.deleteEditText != null) {
                widget.deleteEditText();
              }
            },
          ),
          //表情面板发送按钮
          AppIconButton(
              iconSize: 24,
              svgName: widget.textController.text == null || widget.textController.text.isEmpty
                  ? AppIcon.message_cant_send
                  : AppIcon.message_send,
              buttonWidth: 44,
              buttonHeight: 44,
              onTap: () {
                if (widget.onSubmitClick != null) {
                  widget.onSubmitClick();
                }
              }),
        ],
      ),
    );
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop(double keyboardHeight) {
    return Container(
      height: keyboardHeight - 45.0 - MediaQuery
          .of(context)
          .padding
          .bottom,
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

            if(!widget.focusNode.hasFocus){
              FocusScope.of(context).requestFocus(widget.focusNode);
              return;
            }

            // 表情光标改动前的位置
            if(cursorIndexPr<0){
              cursorIndexPr=0;
            }else if(widget.textController.text.length<cursorIndexPr){
              cursorIndexPr=widget.textController.text.length;
            }
            int changeFrontPosition = cursorIndexPr ?? 0;
            //print("changeFrontPosition:1:$changeFrontPosition");
            // 获取输入框内的规则
            var rules = context.read<ChatEnterNotifier>().rules;

            if (cursorIndexPr != null&&cursorIndexPr>=0) {
              //print("光标前文字：：：：${widget.textController.text.substring(0, cursorIndexPr)}");
              //print("当前选择emoji::::${emojiModel.code}");
              //print("光标后文字：：：：${widget.textController.text.substring(cursorIndexPr, widget.textController.text.length)}");
              widget.textController.text = widget.textController.text.substring(0, cursorIndexPr) +
                  emojiModel.code +
                  widget.textController.text.substring(cursorIndexPr, widget.textController.text.length);
            } else {
              widget.textController.text += emojiModel.code;
            }
            context.read<ChatEnterNotifier>().changeCallback(widget.textController.text);
            // 记录新的emoji光标位置
            cursorIndexPr = cursorIndexPr + emojiModel.code.length;

            var setCursor = TextSelection(
              baseOffset: cursorIndexPr,
              extentOffset: cursorIndexPr,
            );
            widget.textController.selection = setCursor;

            //print(emojiModel.code.length);
            //print("cursorIndexPr:$cursorIndexPr");
            // 这是替换输入的文本修改后面输入的@的规则
            if (rules.isNotEmpty) {
              //print("不为空");
              //print("changeFrontPosition:2:$changeFrontPosition");
              int diffLength = cursorIndexPr - changeFrontPosition;
              //print("diffLength:$diffLength");
              //print(rules.toString());
              for (int i = 0; i < rules.length; i++) {
                if (rules[i].startIndex >= changeFrontPosition) {
                  //print("改光标了————————————————————————");
                  int newStartIndex = rules[i].startIndex + diffLength;
                  int newEndIndex = rules[i].endIndex + diffLength;
                  rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                }
              }
              //print(rules.toString());
              //print(widget.textController.text);
            }
            if (widget.callBackCursorIndexPr != null) {
              widget.callBackCursorIndexPr(cursorIndexPr);
            }
          },
        ));
  }

  double getKeyBoardHeight() {
    double keyboardHeight = 300.0;

    if (Application.keyboardHeightChatPage > 0) {
      keyboardHeight = Application.keyboardHeightChatPage;
    } else if (Application.keyboardHeightIfPage > 0) {
      Application.keyboardHeightChatPage = Application.keyboardHeightIfPage;
      keyboardHeight = Application.keyboardHeightChatPage;
    }
    if (keyboardHeight < 90) {
      keyboardHeight = 300.0;
    }
    keyboardHeight -= MediaQuery
        .of(context)
        .padding
        .bottom;

    return keyboardHeight;
  }

  setCursorIndexPr(int cursorIndexPr) {
    this.cursorIndexPr = cursorIndexPr;
  }

  setBottomSettingPanelState(bool bottomSettingPanelState) {
    this.bottomSettingPanelState = bottomSettingPanelState;
    try{
      if (mounted) {
        setState(() {});
      }
    }catch (e){}
  }

  setEmojiState(bool emojiState) {
    this.emojiState = emojiState;
    try{
      if (mounted) {
        setState(() {});
      }
    }catch (e){}
  }

  setData({bool bottomSettingPanelState, bool emojiState}) {
    if (bottomSettingPanelState != null) {
      this.bottomSettingPanelState = bottomSettingPanelState;
    }
    if (emojiState != null) {
      this.emojiState = emojiState;
    }
    try{
      if (mounted) {
        setState(() {});
      }
    }catch (e){}
  }
}
