import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/toast_util.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class LiveVideoCourseMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final LiveModel liveVideoModel;
  final bool isLiveOrVideo;
  final int status;

  LiveVideoCourseMsg(
      {this.liveVideoModel,
      this.isMyself,
      this.userUrl,
      this.name,
      this.status,
      this.isLiveOrVideo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.0),
      child: Column(
        children: [
          getLongClickBox(),
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
      getMessageState(status),
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
      getUserImage(userUrl, 38, 38),
      SizedBox(
        width: 7,
      ),
      GestureDetector(
        child: _getLiveVideoCourseUi(),
        onTap: () {
          if (isLiveOrVideo) {
            ToastShow.show(msg: "点击了直播课-该跳转", context: context);
          } else {
            ToastShow.show(msg: "点击了视频课-该跳转", context: context);
          }
        },
      ),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return body;
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
    if (liveVideoModel.playBackUrl != null) {
      imageUrl = liveVideoModel.playBackUrl;
    } else if (liveVideoModel.videoUrl != null) {
      imageUrl = FileUtil.getVideoFirstPhoto(liveVideoModel.videoUrl);
    }
    return Container(
      width: double.infinity,
      height: 180,
      child: Stack(
        children: [
          Container(
            color: AppColor.white,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3), topLeft: Radius.circular(3)),
              child: CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                imageUrl: imageUrl == null ? "" : imageUrl,
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
                    child: Center(
                      child: Text(
                        liveVideoModel.name,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.textPrimary1,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
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
