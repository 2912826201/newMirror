
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/message/item/chat_voice.dart';
import 'package:mirror/widget/icon.dart';

typedef VoiceFile = void Function(String path, int time);

//聊天的底部bar
class MessageInputBar extends StatefulWidget {
  final GestureTapCallback voiceOnTap;
  final bool isVoice;
  final Widget edit;
  final VoidCallback onEmojio;
  final VoiceFile voiceFile;
  final Widget more;
  final String id;
  final int type;
  final String value;

  MessageInputBar({
    Key key,
    this.voiceOnTap,
    this.isVoice,
    this.edit,
    this.more,
    this.id,
    this.type,
    this.onEmojio,
    this.value,
    this.voiceFile,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageInputBarState(isVoice);
}

class MessageInputBarState extends State<MessageInputBar> {
  bool isVoice;

  setIsVoice(bool isVoice) {
    this.isVoice = isVoice;
    streamVoiceWidget.sink.add(isVoice);
  }


  StreamController<bool> streamVoiceWidget = StreamController<bool>();

  MessageInputBarState(this.isVoice);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    streamVoiceWidget.close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        // padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 48.0,
                    padding: EdgeInsets.only(left: 6, right: 6),
                    child: AppIconButton(
                      onTap: () {
                        if (widget.voiceOnTap != null) {
                          widget.voiceOnTap();
                        }
                      },
                      iconSize: 24,
                      buttonWidth: 36,
                      buttonHeight: 36,
                      svgName: isVoice ? AppIcon.input_keyboard : AppIcon.input_voice,
                    ),
                  ),
                  Expanded(
                      child: SizedBox(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 32.0,
                        maxHeight: 5 * 16.0,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColor.bgWhite.withOpacity(0.65), borderRadius: BorderRadius.circular(16.0)),
                      child: StreamBuilder(
                        stream: streamVoiceWidget.stream,
                        builder: (context, snapshot) {
                          return isVoice ? ChatVoice(voiceFile: widget.voiceFile) : widget.edit;
                        },
                      ),
                      // child: isVoice ? ChatVoice(voiceFile: widget.voiceFile) : widget.edit,
                    ),
                  )),
                  Container(
                    height: 48.0,
                    padding: EdgeInsets.only(left: 10),
                    child: AppIconButton(
                      onTap: () {
                        widget.onEmojio();
                      },
                      iconSize: 24,
                      buttonWidth: 36,
                      buttonHeight: 36,
                      svgName: AppIcon.input_emotion,
                    ),
                  ),
                  Container(
                    height: 48.0,
                    child: widget.more,
                  )
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
