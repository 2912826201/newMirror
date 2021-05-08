import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/long_click_popup_menu.dart';
import 'package:mirror/page/message/message_view/message_item_height_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/live_label_widget.dart';

import 'currency_msg.dart';

///直播课程视频课程消息
// ignore: must_be_immutable
class LiveVideoCourseMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final CourseModel liveVideoModel;
  final bool isLiveOrVideo;
  final String msgId;
  final String sendChatUserId;
  final bool isShowChatUserName;
  final int status;
  final int position;
  final int sendTime;
  final bool isCanLongClick;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;

  LiveVideoCourseMsg(
      {this.liveVideoModel,
      this.isMyself,
      this.userUrl,
      this.sendTime,
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
    return liveVideoModel != null ?
      getContentBoxItem(context) : Container();
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
        sendTime: sendTime,
        contentType: isLiveOrVideo ? ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE : ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE);
    return LongClickPopupMenu(
      onValueChanged: (int value) {
        voidItemLongClickCallBack(
          position: position,
          settingType: longClickStringList[value],
          contentType: isLiveOrVideo ? ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE : ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE,
        );
      },
      isCanLongClick: isCanLongClick,
      contentType: isLiveOrVideo ? ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE : ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE,
      isMySelf: isMyself,
      actions: longClickStringList,
      contentWidth: 180.0,
      contentHeight:
          MessageItemHeightUtil.init().getLiveVideoCourseMsgHeight(isShowChatUserName, isOnlyContentHeight: true),
      child: GestureDetector(
        child: _getLiveVideoCourseUi(),
        onTap: () {
          if (isLiveOrVideo) {
            // ToastShow.show(msg: "点击了直播课-该跳转", context: context);
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE, map: liveVideoModel.toJson(), msgId: msgId);
          } else {
            voidMessageClickCallBack(
                contentType: ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE, map: liveVideoModel.toJson(), msgId: msgId);
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
                borderRadius: BorderRadius.only(topRight: Radius.circular(3), topLeft: Radius.circular(3)),
                child: CachedNetworkImage(
                  height: double.infinity,
                  width: double.infinity,
                  imageUrl: imageUrl == null ? "" : FileUtil.getLargeImage(imageUrl),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColor.bgWhite,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColor.bgWhite,
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
                    AppColor.textPrimary1.withOpacity(0.35),
                    AppColor.textPrimary1.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: isLiveOrVideo ? LiveLabelWidget(isWhiteBorder: false) : Container(),
            top: 13,
            left: 12,
          ),
        ],
      ),
    );
  }

  //底部文字
  Widget _getBottomText() {
    String name="";
    if(liveVideoModel!=null&&liveVideoModel.coursewareDto!=null&&liveVideoModel.coursewareDto.levelDto!=null&&
        liveVideoModel.coursewareDto.levelDto.name!=null){
      name=liveVideoModel.coursewareDto.levelDto.name;
    }
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
                  AppIcon.getAppIcon(AppIcon.tag_course_white, 16,
                      containerHeight: 20, containerWidth: 20, bgColor: AppColor.textPrimary2, isCircle: true),
                  SizedBox(
                    width: 4,
                  ),
                  Container(
                    height: 20,
                    width: 120.0,
                    child: Text(
                      liveVideoModel.title ?? "",
                      style: AppStyle.textMedium14,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Text(name??"" + "·${((liveVideoModel.times ?? 0) ~/ 60000)}分钟"),
          ),
        ],
      ),
    );
  }
}
