import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/message/chat_voice_setting.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:provider/provider.dart';

import 'currency_msg.dart';

///语音消息
// ignore: must_be_immutable
class VoiceMsg extends StatefulWidget {
  final _VoiceMsgState _state = _VoiceMsgState();
  final String userUrl;
  final String name;
  final String messageUId;
  final bool isMyself;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final bool isTemporary;
  final int sendTime;
  final bool isCanLongClick;
  final ChatVoiceModel chatVoiceModel;
  final int status;
  final int position;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Function(void Function(),String longClickString) setCallRemoveOverlay;

  VoiceMsg(
      {this.chatVoiceModel,
      this.isMyself,
      this.sendTime,
      this.messageUId,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
      this.isTemporary,
      this.userUrl,
      this.name,
      this.status,
      this.position,
      this.voidMessageClickCallBack,
      this.setCallRemoveOverlay,
      this.voidItemLongClickCallBack});

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class _VoiceMsgState extends State<VoiceMsg> with TickerProviderStateMixin {
  int showTime = 0;
  int getWidgetArrayState = 0;

  Duration duration;
  Timer timer;
  String urlMd5String;
  String urlString;

  @override
  void initState() {
    super.initState();
    _initTimeDuration();
    // _getIsRead();
  }

  @override
  Widget build(BuildContext context) {
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: widget.isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: getBody(context),
          ),
        ],
      ),
    );
  }

  //最外层body 加载状态和消息结构
  List<Widget> getBody(BuildContext context) {
    var body = [
      Row(
        mainAxisAlignment: widget.isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: widget.isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(widget.status,
            isRead: widget.chatVoiceModel.read != 0,
            isMyself: widget.isMyself,
            position: widget.position,
            voidMessageClickCallBack: widget.voidMessageClickCallBack),
      ),
      Spacer(),
    ];
    if (widget.isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //里面的结构-头像和消息
  List<Widget> getSmallBody(BuildContext context) {
    var body = [
      GestureDetector(
        child: getUserImage(widget.userUrl, 38, 38),
        onTap: () {
          if (widget.isCanLongClick) {
            widget.voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(widget.sendChatUserId)).toJson());
          }
        },
      ),
      SizedBox(
        width: 7,
      ),
      getNameAndContentUi(context),
    ];
    if (widget.isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //判断有没有名字
  Widget getNameAndContentUi(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: widget.isMyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.isShowChatUserName,
            child: Container(
              margin: widget.isMyself
                  ? const EdgeInsets.only(right: 10, bottom: 4)
                  : const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              ),
            ),
          ),
          _getVoiceUiLongClick(),
        ],
      ),
    );
  }

  //长按事件
  Widget _getVoiceUiLongClick() {
    List<String> longClickStringList = getLongClickStringList(
        isMySelf: widget.isMyself,
        status: widget.status,
        sendTime: widget.sendTime,
        contentType: ChatTypeModel.MESSAGE_TYPE_VOICE);

    return LongClickPopupMenu(
      onValueChanged: (int value) {
        Map<String, dynamic> map =Map();
        map["urlMd5String"]=urlMd5String;
        map["filePathMd5"]=_getUrlMd5String();
        widget.voidItemLongClickCallBack(
            position: widget.position,
            settingType: longClickStringList[value],
            map:map,
            contentType: ChatTypeModel.MESSAGE_TYPE_VOICE);
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      setCallRemoveOverlay:widget.setCallRemoveOverlay,
      isCanLongClick: widget.isCanLongClick,
      position:widget.position,
      contentType: ChatTypeModel.MESSAGE_TYPE_VOICE,
      isMySelf: widget.isMyself,
      actions: longClickStringList,
      contentWidth: getNowWidth(context, widget.chatVoiceModel.longTime),
      contentHeight:
          MessageItemHeightUtil.init().getVoiceMsgDataHeight(widget.isShowChatUserName, isOnlyContentHeight: true),
      child: _getVoiceUi(context),
    );
  }

  //获取动态框
  Widget _getVoiceUi(BuildContext context) {
    String stateImg = "assets/png/message_bubble_arrow_white.png";
    if (widget.isMyself) {
      stateImg = "assets/png/message_bubble_arrow_black.png";
    }
    return Container(
      margin: widget.isMyself ? const EdgeInsets.only(right: 2.0) : const EdgeInsets.only(left: 2.0),
      child: Stack(
        alignment: widget.isMyself ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9.0),
            child: Image.asset(
              stateImg,
              width: 10.5,
              height: 17,
              fit: BoxFit.fill,
            ),
          ),
          Container(
              margin: widget.isMyself ? const EdgeInsets.only(right: 7.0) : const EdgeInsets.only(left: 7.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: widget.isMyself ? AppColor.textPrimary2 : AppColor.white,
                    child: new InkWell(
                      child: _getShowTextBox(),
                      splashColor: widget.isMyself ? AppColor.textPrimary1 : AppColor.textHint,
                      onTap: () {
                        if (ClickUtil.isFastClick(time: 300)) {
                          return;
                        }
                        String filePathMd5=_getUrlMd5String();
                        if(context.read<VoiceSettingNotifier>().getIsPlaying(idMd5String:filePathMd5)){
                          context.read<VoiceSettingNotifier>().judgePlayModel(urlString, context, filePathMd5);
                        }else {
                          context.read<VoiceSettingNotifier>().judgePlayModel(urlString, context, urlMd5String);
                        }
                        Map<String, dynamic> map =Map();
                        map["urlMd5String"]=urlMd5String;
                        map["filePathMd5"]=filePathMd5;
                        widget.voidMessageClickCallBack(
                            contentType: ChatTypeModel.MESSAGE_TYPE_VOICE,
                            position: widget.position,
                            map:map,
                        );
                      },
                    )),
              )),
        ],
      ),
    );
  }

  Widget _getShowTextBox() {
    return Container(
      width: getNowWidth(context, widget.chatVoiceModel.longTime),
      padding: const EdgeInsets.only(left: 11, right: 11, top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: _getShowText(),
    );
  }

  //底部文字
  Widget _getShowText() {
    var body = [
      getWidgetArray(),
      SizedBox(
        width: 12,
      ),
      Text(
        widget.chatVoiceModel.longTime.toString(),
        style: TextStyle(color: widget.isMyself ? AppColor.white : AppColor.textPrimary1, fontSize: 16),
      ),
      Expanded(child: SizedBox()),
    ];

    if (widget.isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }

    return Container(
      child: Row(
        mainAxisAlignment: widget.isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: body,
      ),
    );
  }

  // Widget getWidgetArrayBox(){
  //   return Consumer<VoiceSettingNotifier>(
  //     builder: (context, notifier, child) {
  //       // getWidgetArrayState=notifier.getShowTime(widget.chatVoiceModel.longTime,urlMd5String)%4;
  //       return getWidgetArray();
  //     },
  //   );
  // }

  //获取条数的动画
  Widget getWidgetArray() {
    if (getWidgetArrayState == 1) {
      return Row(
        children: [
          getWidget(10, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(13, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(20, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(16, 3),
        ],
      );
    } else if (getWidgetArrayState == 2) {
      return Row(
        children: [
          getWidget(16, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(10, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(13, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(20, 3),
        ],
      );
    } else if (getWidgetArrayState == 3) {
      return Row(
        children: [
          getWidget(20, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(16, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(10, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(13, 3),
        ],
      );
    } else {
      return Row(
        children: [
          getWidget(13, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(20, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(16, 3),
          SizedBox(
            width: 3,
          ),
          getWidget(10, 3),
        ],
      );
    }
  }

  //每一个条
  Widget getWidget(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: widget.isMyself ? AppColor.white : AppColor.textPrimary1,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }

  //获取欧最大宽度
  double getMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width - (16 + 7 + 38 + 2) * 2;
  }

  //获取当前的宽度
  double getNowWidth(BuildContext context, int longTime) {
    double minWidth;
    if (longTime >= 60) {
      minWidth = getMaxWidth(context);
    } else if (longTime >= 10) {
      minWidth = getMaxWidth(context) / 14 * (9 + longTime ~/ 10);
    } else if (longTime >= 2) {
      minWidth = getMaxWidth(context) / 14 * (longTime - 1);
    } else {
      minWidth = getMaxWidth(context) / 14;
    }
    if (minWidth < 85) {
      minWidth = 85;
    }
    return minWidth;
  }

  //获取地址，以及md5加密后的地址
  String _getUrlMd5String() {
    if (widget.isTemporary) {
      urlString = widget.chatVoiceModel.filePath;
      urlMd5String = StringUtil.generateMd5(widget.chatVoiceModel.filePath);
      return urlMd5String;
      // print("地址Benin1：${widget.chatVoiceModel.filePath}");
    } else {
      if (widget.chatVoiceModel.pathUrl != null) {
        urlString = widget.chatVoiceModel.pathUrl;
        urlMd5String = StringUtil.generateMd5(widget.chatVoiceModel.pathUrl);
        // print("地址Benin2：${widget.chatVoiceModel.pathUrl},messageUId:${widget.chatVoiceModel.filePath}");
        return StringUtil.generateMd5(widget.chatVoiceModel.filePath);
      } else {
        urlString = widget.chatVoiceModel.filePath;
        urlMd5String = StringUtil.generateMd5(widget.chatVoiceModel.filePath);
        // print("地址Benin3：${widget.chatVoiceModel.filePath}");
        // print("urlMd5String：$urlMd5String");
        return urlMd5String;
      }
    }
  }

  //监听动画是否开始
  void _initTimeDuration() {
    duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (timer) {
      try {
        bool isPlaying = false;
        String filePathMd5 = _getUrlMd5String();
        if (context.read<VoiceSettingNotifier>().getIsPlaying(idMd5String: filePathMd5)) {
          isPlaying = true;
        } else if (context.read<VoiceSettingNotifier>().getIsPlaying(idMd5String: urlMd5String)) {
          isPlaying = true;
        }
        if (isPlaying) {
          getWidgetArrayState++;
          if (getWidgetArrayState > 3) {
            getWidgetArrayState = 0;
          }
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 取消定时器
    if (timer != null) {
      timer.cancel();
    }
  }
}
