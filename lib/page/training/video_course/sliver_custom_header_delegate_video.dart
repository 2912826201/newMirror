import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';

///视频课-头部折叠滑动
class SliverCustomHeaderDelegateVideo extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final double paddingTop;
  final String coverImgUrl;
  final String title;
  final String heroTag;
  String statusBarMode = 'dark';
  final List<String> valueArray;
  final List<String> titleArray;
  bool isGoneTitle = true;
  double titleSize = 30;
  String startTime;
  String endTime;
  bool isFavor;
  final VoidCallback shareBtnClick;
  final VoidCallback favorBtnClick;
  final GlobalKey globalKey;

  SliverCustomHeaderDelegateVideo({
    this.collapsedHeight,
    this.expandedHeight,
    this.paddingTop,
    this.coverImgUrl,
    this.title,
    this.valueArray,
    this.titleArray,
    this.heroTag,
    this.startTime,
    this.endTime,
    this.isFavor,
    this.shareBtnClick,
    this.favorBtnClick,
    this.globalKey,
  });

  @override
  double get minExtent => this.collapsedHeight + this.paddingTop;

  @override
  double get maxExtent => this.expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void updateStatusBarBrightness(shrinkOffset) {
    this.statusBarMode = 'light';
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Color makeStickyHeaderBgColor(shrinkOffset) {
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
        .clamp(0, 255)
        .toInt();
    if (alpha > 220) {
      titleSize = 20;
      isGoneTitle = false;
    } else {
      titleSize = 30 - alpha / 22;
      isGoneTitle = true;
    }
    return Color.fromARGB(alpha, 0, 0, 0);
  }

  Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
    if (shrinkOffset <= 50) {
      return isIcon ? Colors.white : Colors.transparent;
    } else {
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
          .clamp(0, 255)
          .toInt();
      return Color.fromARGB(alpha, 0, 0, 0);
    }
  }

  Color makeStickyHeaderTextColor1(shrinkOffset, isIcon) {
    if (shrinkOffset <= 160) {
      return isIcon ? Colors.white : Colors.transparent;
    } else {
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
          .clamp(0, 255)
          .toInt();
      return Color.fromARGB(alpha, 51, 51, 51);
    }
  }

  Widget _getTitleWidgetArray() {
    return Container(
      padding: const EdgeInsets.only(left: 17.5, bottom: 16),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: AppColor.white,
            size: 18,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            DateUtil.formatDateNoYearString(
                DateUtil.stringToDateTime(startTime)) +
                "${DateUtil.isToday(DateUtil.stringToDateTime(startTime)) ? " (今天) " : "  "}" +
                "${DateUtil.formatTimeString(DateUtil.stringToDateTime(startTime))}"
                    "-"
                    "${DateUtil.formatTimeString(DateUtil.stringToDateTime(endTime))}",
            style: TextStyle(
              color: AppColor.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.updateStatusBarBrightness(shrinkOffset);
    return Container(
      key: globalKey,
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          //背景图
          Container(
              child: Hero(
            child: CachedNetworkImage(
              height: double.infinity,
              width: double.infinity,
              imageUrl: this.coverImgUrl == null ? "" : this.coverImgUrl,
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
            tag: heroTag,
          )),
          //文字背景色
          Positioned(
            left: 0,
            top: this.maxExtent / 5,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x20000000),
                  ],
                ),
              ),
            ),
          ),
          //数据显示
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: _getTitleWidgetArray(),
            ),
            bottom: 0,
            left: 0,
          ),
          //中间文字
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Offstage(
                  offstage: !isGoneTitle,
                  child: Text(
                    this.title,
                    style: TextStyle(
                      fontSize: 21,
                      // color: this.makeStickyHeaderTextColor1(shrinkOffset, true),
                      color: AppColor.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
            bottom: 53,
            left: 0,
          ),
          //头部信息
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: this.makeStickyHeaderBgColor(shrinkOffset),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 2),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: this.collapsedHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColor.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                          child: SizedBox(
                            child: Offstage(
                              offstage: isGoneTitle,
                              child: Container(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  this.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite_border_rounded,
                              color: isFavor ? AppColor.mainRed : AppColor.white,
                            ),
                            onPressed: () {
                              if (favorBtnClick != null) {
                                favorBtnClick();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              color: AppColor.white,
                            ),
                            onPressed: shareBtnClick,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
