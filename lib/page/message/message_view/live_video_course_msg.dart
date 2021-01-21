import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/util/date_util.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class LiveVideoCourseMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final LiveVideoModel liveVideoModel;
  final bool isLiveOrVideo;
  final String msgId;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final int status;
  final int position;
  final bool isCanLongClick;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  LiveVideoCourseMsg(
      {this.liveVideoModel,
      this.isMyself,
      this.userUrl,
      this.msgId,
      this.name,
      this.status,
      this.isShowChatUserName = false,
      this.isCanLongClick = true,
      this.sendChatUserId,
      this.position,
      this.isLiveOrVideo,
      this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack});

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
            mainAxisAlignment:
                isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
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
        mainAxisAlignment:
        isMyself ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getSmallBody(context),
      ),
      Container(
        margin: isShowChatUserName ? const EdgeInsets.only(top: 16) : null,
        child: getMessageState(status),
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
            voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_USER,
                map: new UserModel(uid: int.parse(sendChatUserId)).toJson());
          }
        },
      ),
      SizedBox(
        width: 7,
      ),
      getNameAndContentUi(context),
    ];
    if (isMyself) {
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
          _getLiveVideoCourseUiLongClick(context),
        ],
      ),
    );
  }

  //长按事件
  Widget _getLiveVideoCourseUiLongClick(BuildContext context) {
    List<String> longClickStringList = getLongClickStringList(
        isMySelf: isMyself,
        contentType: isLiveOrVideo ? ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE : ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(longClickStringList[value]),
          duration: Duration(milliseconds: 500),
        ));
      },
      isCanLongClick: isCanLongClick,
      contentType: isLiveOrVideo ? ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE : ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: 180.0,
      child: GestureDetector(
        child: _getLiveVideoCourseUi(),
        onTap: () {
          if (isLiveOrVideo) {
            // ToastShow.show(msg: "点击了直播课-该跳转", context: context);
            voidMessageClickCallBack(contentType: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE,
                map: liveVideoModel.toJson(), msgId: msgId);
          } else {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE,
                map: liveVideoModel.toJson(), msgId: msgId);
            // ToastShow.show(msg: "点击了视频课-该跳转", context: context);
          }
        },
      ),
    );
  }

  //获取动态框
  Widget _getLiveVideoCourseUi() {
    return Container(
      width: 180,
      height: 180 + 68.5,
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
    String imageUrl;
    if (liveVideoModel.picUrl != null) {
      imageUrl = liveVideoModel.picUrl;
    } else if (liveVideoModel.coursewareDto?.picUrl != null) {
      imageUrl = liveVideoModel.coursewareDto?.picUrl;
    } else if (liveVideoModel.coursewareDto?.previewVideoUrl != null) {
      imageUrl = liveVideoModel.coursewareDto?.previewVideoUrl;
    }
    return Container(
      width: double.infinity,
      height: 180,
      child: Stack(
        children: [
          Hero(
            child: Container(
              color: AppColor.white,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(3), topLeft: Radius.circular(3)),
                child: CachedNetworkImage(
                  height: double.infinity,
                  width: double.infinity,
                  imageUrl: imageUrl == null ? "" : imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Image.asset(
                        "images/test/bg.png",
                        fit: BoxFit.cover,
                      ),
                  errorWidget: (context, url, error) =>
                      Image.asset(
                        "images/test/bg.png",
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
            tag: msgId,
          ),

          Offstage(
            offstage: !isLiveOrVideo,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x40000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Offstage(
              offstage: !isLiveOrVideo,
              child: getLiveStateUi(),
            ),
            top: 13,
            left: 12,
          ),
        ],
      ),
    );
  }

  //底部文字
  Widget _getBottomText() {
    return Container(
      width: double.infinity,
      height: 68.5,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: Row(
                children: [
                  Icon(
                    Icons.flash_on_outlined,
                    size: 20,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Container(
                    height: 20,
                    width: 120.0,
                    child: Center(
                      child: Text(
                        liveVideoModel.title ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.textPrimary1,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            // ignore: null_aware_before_operator
            child: Text(liveVideoModel.coursewareDto?.levelDto?.name +
                "·" +
                DateUtil.formatSecondToStringCn(
                    liveVideoModel.totalTrainingTime)),
          ),
        ],
      ),
    );
  }
}
