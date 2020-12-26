import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/message/item/chat_voice.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';

typedef VoiceFile = void Function(String path, int time);

class MessageInputBar extends StatefulWidget {
  final GestureTapCallback voiceOnTap;
  final bool isVoice;
  final LayoutWidgetBuilder edit;
  final VoidCallback onEmojio;
  final VoiceFile voiceFile;
  final Widget more;
  final String id;
  final int type;
  final String value;

  MessageInputBar({
    this.voiceOnTap,
    this.isVoice,
    this.edit,
    this.more,
    this.id,
    this.type,
    this.onEmojio,
    this.value,
    this.voiceFile,
  });

  @override
  State<StatefulWidget> createState() => MessageInputBarState();
}

class MessageInputBarState extends State<MessageInputBar> {
  String path;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
            bottom: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: 4.0 * 16 + 16 + 18, //宽度尽可能大
                //最小高度为50像素
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(color: AppColor.bgWhite, width: 0.2),
                  bottom: BorderSide(color: AppColor.bgWhite, width: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 13.0, right: 13.0),
                      decoration: BoxDecoration(
                          color: AppColor.bgWhite_65,
                          // color: Colors.red,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: widget.isVoice
                          ? ChatVoice(voiceFile: widget.voiceFile,)
                          : LayoutBuilder(builder: widget.edit),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  StringUtil.strNoEmpty(widget.value)
                      ? SizedBox(
                          width: 63,
                        )
                      : SizedBox(
                          width: 36,
                        ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: 48, //宽度尽可能大
                //最小高度为50像素
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: 48,
                      width: 48,
                      padding: EdgeInsets.only(left: 16.0, right: 13.0),
                      child: Icon(
                        Icons.settings_voice,
                        size: 21,
                      ),
                    ),
                    onTap: () {
                      if (widget.voiceOnTap != null) {
                        widget.voiceOnTap();
                      }
                    },
                  ),
                  Expanded(child: SizedBox()),
                  GestureDetector(
                    child: Container(
                      width: 32,
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.emoji_emotions_outlined,
                            size: 24,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      widget.onEmojio();
                    },
                  ),
                  widget.more,
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {},
    );
  }
}
