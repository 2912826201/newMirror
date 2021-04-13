import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';

import 'currency_msg.dart';

///动态消息
// ignore: must_be_immutable
class FeedMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final HomeFeedModel homeFeedMode;
  final int status;
  final int position;
  final int sendTime;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final bool isCanLongClick;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  FeedMsg({
    this.userUrl,
    this.name,
    this.sendTime,
    this.isShowChatUserName = false,
    this.isCanLongClick = true,
    this.sendChatUserId,
    this.isMyself,
    this.homeFeedMode,
    this.status,
    this.position,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
  });

  //0--pic    1-video  -1-都不是------动态
  int isPicOrVideo = -1;

  @override
  Widget build(BuildContext context) {
    init(context);
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        mainAxisAlignment: isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status, position: position, voidMessageClickCallBack: voidMessageClickCallBack),
      ),
      Spacer(),
    ];
    if (isMyself) {
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
        child: getUserImage(userUrl, 38, 38),
        onTap: () {
          if (isCanLongClick) {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(sendChatUserId)).toJson());
          }
        },
      ),
      SizedBox(
        width: 7,
      ),
      getNameAndContentUi(),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
  }

  //判断有没有名字
  Widget getNameAndContentUi() {
    return Container(
      child: Column(
        crossAxisAlignment: isMyself ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isShowChatUserName,
            child: Container(
              margin:
                  isMyself ? const EdgeInsets.only(right: 10, bottom: 4) : const EdgeInsets.only(left: 10, bottom: 4),
              child: Text(
                name,
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              ),
            ),
          ),
          _getFeedUiLongClickUi(),
        ],
      ),
    );
  }

  //获取动态的长按事件
  Widget _getFeedUiLongClickUi() {
    List<String> longClickStringList = getLongClickStringList(
      isMySelf: isMyself,
      contentType: ChatTypeModel.MESSAGE_TYPE_FEED,
      sendTime: sendTime,
    );
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
            position: position, settingType: longClickStringList[value], contentType: ChatTypeModel.MESSAGE_TYPE_FEED);
        // Scaffold.of(context).showSnackBar(SnackBar(content: Text(longClickStringList[value]), duration: Duration(milliseconds: 500),));
      },
      isCanLongClick: isCanLongClick,
      contentType: ChatTypeModel.MESSAGE_TYPE_FEED,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: 180.0,
      contentHeight: MessageItemHeightUtil.init()
          .getFeedMsgDataHeight(homeFeedMode.toJson(), isShowChatUserName, isOnlyContentHeight: true),
      child: GestureDetector(
        child: _getFeedUi(),
        onTap: () {
          voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_FEED, map: homeFeedMode.toJson());
          // ToastShow.show(msg: "点击了动态-改跳转", context: context);
        },
      ),
    );
  }

  //获取动态框
  Widget _getFeedUi() {
    return Container(
      width: 180,
      height: _getFeedHeight(),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          _getShowPic(),
          _getBottomText(),
        ],
      ),
    );
  }

  //获取显示的图片
  Widget _getShowPic() {
    if (isPicOrVideo < 0) {
      return Container();
    } else {
      String showUrl =
          (isPicOrVideo == 0 ? homeFeedMode.picUrls[0].url : FileUtil.getVideoFirstPhoto(homeFeedMode.videos[0].url));

      int ms = 0;
      if (isPicOrVideo == 1) {
        ms = homeFeedMode.videos[0].duration;
      }

      return Expanded(
        child: SizedBox(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(3), topLeft: Radius.circular(3)),
                child: CachedNetworkImage(
                  height: double.infinity,
                  width: double.infinity,
                  imageUrl: showUrl == null ? "" : showUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    "images/test/bg.png",
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "images/test/bg.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                color: AppColor.black.withOpacity(0.15),
              ),
              Offstage(
                offstage: isPicOrVideo == 0,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 28,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Offstage(
                  offstage: isPicOrVideo == 0,
                  child: Container(
                    child: Text(
                      DateUtil.formatSecondToStringNumShowMinute(ms),
                      style: TextStyle(fontSize: 11, color: AppColor.white),
                    ),
                  ),
                ),
                bottom: 6,
                right: 12,
              ),
            ],
          ),
        ),
      );
    }
  }

  //底部文字
  Widget _getBottomText() {
    return Container(
      width: double.infinity,
      height: 75.0,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
              child: SizedBox(
            child: Container(
              width: double.infinity,
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.network(
                      homeFeedMode.avatarUrl ?? "",
                      fit: BoxFit.cover,
                      width: 20,
                      height: 20,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Expanded(
                      child: SizedBox(
                    child: Row(
                      children: [
                        Container(
                          child: Text(homeFeedMode.name ?? "",
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppStyle.textMedium16),
                          constraints: BoxConstraints(
                            maxWidth: 180 - 12 - 4 - 12 - 6 - 80.0,
                          ),
                        ),
                        Container(
                          child: Text(" 的动态", style: AppStyle.textMedium16),
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
          )),
          Expanded(
              child: SizedBox(
            child: Center(
              child: Container(
                width: double.infinity,
                child: Text(homeFeedMode.content,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: AppStyle.textPrimary2Regular16),
              ),
            ),
          )),
        ],
      ),
    );
  }

  //获取动态的高度
  double _getFeedHeight() {
    if (isPicOrVideo == 0) {
      double value = homeFeedMode.picUrls[0].width / homeFeedMode.picUrls[0].height;
      if (value == 1) {
        return 180.0 + 75.0;
      } else if (value == 0.8) {
        return 225.0 + 75.0;
      } else {
        return 95.0 + 75.0;
      }
    } else if (isPicOrVideo == 1) {
      double value = homeFeedMode.videos[0].width / homeFeedMode.videos[0].height;
      if (value == 1) {
        return 180.0 + 75.0;
      } else if (value == 0.8) {
        return 225.0 + 75.0;
      } else {
        return 95.0 + 75.0;
      }
    } else {
      return 75.0;
    }
  }

  //初始化数据
  void init(BuildContext context) {
    if (homeFeedMode.picUrls != null && homeFeedMode.picUrls.length > 0) {
      isPicOrVideo = 0;
    } else if (homeFeedMode.videos != null && homeFeedMode.videos.length > 0) {
      isPicOrVideo = 1;
    } else {
      isPicOrVideo = -1;
    }
  }
}
