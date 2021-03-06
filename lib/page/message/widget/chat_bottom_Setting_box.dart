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

import '../util/emoji_manager.dart';

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
  bool isShowCanIcon=false;

  List<EmojiModel> emojiModelList = [];

  ChatBottomSettingBoxState(this.bottomSettingPanelState, this.emojiState);

  @override
  void initState() {
    EventBus.init().registerSingleParameter(_resetPostBtn, EVENTBUS_CHAT_PAGE, registerName: CHAT_BOTTOM_MORE_BTN);
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.init().unRegister(pageName: EVENTBUS_CHAT_PAGE, registerName: CHAT_BOTTOM_MORE_BTN);
  }

  _resetPostBtn(bool isVoiceState) {

    bool isShowCanIcon=!(widget.textController.text == null || widget.textController.text.isEmpty)&&!isVoiceState;

    if(this.isShowCanIcon==isShowCanIcon){
      return;
    }
    this.isShowCanIcon=isShowCanIcon;

    if(!emojiState){
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  _initData() async {
    //?????????????????????
    isShowCanIcon=!(widget.textController.text == null || widget.textController.text.isEmpty);
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
            color: AppColor.layoutBgGrey,
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

  //?????????
  Widget emoji(double keyboardHeight) {
    keyboardHeight += MediaQuery.of(context).padding.bottom;
    double height = emojiState ? keyboardHeight : 0.0;
    return AnimatedContainer(
      duration: height > 0 ? Duration.zero : Duration(milliseconds: 40),
      height: height,
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColor.layoutBgGrey,
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
        color: AppColor.layoutBgGrey,
      ),
    );
  }

  //emoji?????????????????????
  Widget emojiList(double keyboardHeight) {
    if (emojiModelList == null || emojiModelList.length < 1) {
      return Center(
        child: Text("????????????"),
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
                    color: AppColor.dividerWhite8,
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
                    color: AppColor.layoutBgGrey,
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

  //?????????bar
  Widget _emojiBottomBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: AppColor.dividerWhite8, width: 1),
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
          //????????????????????????
          AppIconButton(
            iconSize: 24,
            svgName: AppIcon.message_delete,
            buttonWidth: 44,
            buttonHeight: 44,
            iconColor: AppColor.textWhite60,
            onTap: () {
              if (widget.deleteEditText != null) {
                widget.deleteEditText();
              }
            },
          ),
          //????????????????????????
          AppIconButton(
              iconSize: 24,
              svgName: !isShowCanIcon
                  ? AppIcon.message_cant_send
                  : AppIcon.message_send,
              iconColor: isShowCanIcon ? AppColor.white : AppColor.textWhite40,
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

  //????????????????????? ???????????????
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

  //?????????_emojiGridItem
  Widget _emojiGridItem(EmojiModel emojiModel, int index) {
    TextStyle textStyle = const TextStyle(
      fontSize: 24,
    );
    return Material(
        color: AppColor.layoutBgGrey,
        child: new InkWell(
          splashColor: AppColor.white.withOpacity(0.1),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              emojiModel.emoji,
              style: textStyle,
            ),
          ),
          onTap: () {
            if (!widget.focusNode.hasFocus) {
              FocusScope.of(context).requestFocus(widget.focusNode);
              return;
            }

            // ??????????????????????????????
            if(cursorIndexPr<0){
              cursorIndexPr=0;
            }else if(widget.textController.text.length<cursorIndexPr){
              cursorIndexPr=widget.textController.text.length;
            }
            int changeFrontPosition = cursorIndexPr ?? 0;
            //print("changeFrontPosition:1:$changeFrontPosition");
            // ???????????????????????????
            var rules = context.read<ChatEnterNotifier>().rules;

            if (cursorIndexPr != null&&cursorIndexPr>=0) {
              //print("???????????????????????????${widget.textController.text.substring(0, cursorIndexPr)}");
              //print("????????????emoji::::${emojiModel.code}");
              //print("???????????????????????????${widget.textController.text.substring(cursorIndexPr, widget.textController.text.length)}");
              widget.textController.text = widget.textController.text.substring(0, cursorIndexPr) +
                  emojiModel.code +
                  widget.textController.text.substring(cursorIndexPr, widget.textController.text.length);
            } else {
              widget.textController.text += emojiModel.code;
            }
            context.read<ChatEnterNotifier>().changeCallback(widget.textController.text);
            // ????????????emoji????????????
            cursorIndexPr = cursorIndexPr + emojiModel.code.length;

            var setCursor = TextSelection(
              baseOffset: cursorIndexPr,
              extentOffset: cursorIndexPr,
            );
            widget.textController.selection = setCursor;

            //print(emojiModel.code.length);
            //print("cursorIndexPr:$cursorIndexPr");
            // ????????????????????????????????????????????????@?????????
            if (rules.isNotEmpty) {
              //print("?????????");
              //print("changeFrontPosition:2:$changeFrontPosition");
              int diffLength = cursorIndexPr - changeFrontPosition;
              //print("diffLength:$diffLength");
              //print(rules.toString());
              for (int i = 0; i < rules.length; i++) {
                if (rules[i].startIndex >= changeFrontPosition) {
                  //print("????????????????????????????????????????????????????????????????????????????????????");
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
