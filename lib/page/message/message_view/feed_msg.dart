import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class FeedMsg extends StatelessWidget {
  final String userUrl;
  final String name;
  final bool isMyself;
  final HomeFeedModel homeFeedMode;
  final int status;

  FeedMsg(
      {this.homeFeedMode, this.isMyself, this.userUrl, this.name, this.status});

  //0--pic    1-video  -1-都不是
  int isPicOrVideo = -1;

  @override
  Widget build(BuildContext context) {
    init();
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
        child: _getFeedUi(),
        onTap: () {
          ToastShow.show(msg: "点击了动态-改跳转", context: context);
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
      String showUrl = (isPicOrVideo == 0
          ? homeFeedMode.picUrls[0].url
          : FileUtil.getVideoFirstPhoto(homeFeedMode.videos[0].url));

      int ms = 0;
      if (isPicOrVideo == 1) {
        ms = homeFeedMode.videos[0].duration;
      }

      return Expanded(
        child: SizedBox(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(3), topLeft: Radius.circular(3)),
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
                      DateUtil.formatSecondToStringNum(ms),
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
    var textStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary1);
    var textStyle1 = TextStyle(fontSize: 16, color: AppColor.textPrimary2);
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
                      homeFeedMode.avatarUrl,
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
                          child: Text(homeFeedMode.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle),
                          constraints: BoxConstraints(
                            maxWidth: 180 - 12 - 4 - 12 - 6 - 80.0,
                          ),
                        ),
                        Container(
                          child: Text(" 的动态", style: textStyle),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle1),
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
      double value =
          homeFeedMode.picUrls[0].width / homeFeedMode.picUrls[0].height;
      if (value == 1) {
        return 180.0 + 75.0;
      } else if (value == 0.8) {
        return 225.0 + 75.0;
      } else {
        return 95.0 + 75.0;
      }
    } else if (isPicOrVideo == 1) {
      double value =
          homeFeedMode.videos[0].width / homeFeedMode.videos[0].height;
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
  void init() {
    if (homeFeedMode.picUrls != null && homeFeedMode.picUrls.length > 0) {
      isPicOrVideo = 0;
    } else if (homeFeedMode.videos != null &&
        homeFeedMode.videos.length > 0) {
      isPicOrVideo = 1;
    } else {
      isPicOrVideo = -1;
    }
  }
}
