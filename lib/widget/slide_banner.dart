import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/image_preview/image_preview_page.dart';
import 'package:mirror/page/image_preview/image_preview_view.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// 轮播图
class SlideBanner extends StatefulWidget {
  SlideBanner(
      {Key key, this.height, this.model, this.index, this.pageName, this.isDynamicDetails = false, this.isHero = false})
      : super(key: key);
  HomeFeedModel model;
  double height;
  String pageName;
  int index;

  bool isDynamicDetails;
  bool isHero;

  @override
  _SlideBannerState createState() => _SlideBannerState();
}

class _SlideBannerState extends State<SlideBanner> {
  int zindex = 0; //要移入的下标
  Timer timer;

  // 图片张数
  int imageCount = 0;

  // 图片宽度
  int imageWidth = 0;

  // scroll_to_index定位
  AutoScrollController controller;
  SwiperController swiperController = SwiperController();

  // 指示器横向布局
  final scrollDirection = Axis.horizontal;

  @override
  void initState() {
    super.initState();
    if ( widget.model!= null && widget.model.selectedMediaFiles != null) {
      print("图片显示问题:::${widget.model.selectedMediaFiles.list.first.file}");
      imageCount = widget.model.selectedMediaFiles.list.length;
      imageWidth = widget.model.selectedMediaFiles.list.first.sizeInfo.width;
    }
    if (widget.model.picUrls.isNotEmpty) {
      imageCount = widget.model.picUrls.length;
      imageWidth = widget.model.picUrls.first.width;
    }
    swiperController.addListener(() {
      print(swiperController.index);
    });
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  // 滑动回调
  autoPlay(int index) {
    slidingPosition(index);
    print("轮播图回调");
    setState(() {
      zindex = index;
    });
  }

  // 返回指示器的总宽度
  double getWidth() {
    var num = imageCount;
    if (num <= 5) {
      return 3 * 8.0 + 6 + 10;
    } else {
      if (zindex == 0 || zindex == 1 || zindex == 2 || zindex == num - 1 || zindex == num - 2 || zindex == num - 3) {
        return 3 * 8.0 + 6 + 10;
      }
      if (zindex >= 3 && zindex + 3 < num) {
        return 2 * 8.0 + 2 * 5.0 + 10 + 2;
      }
    }
    return 5 * 8.0;
  }

  // 通过代码滑动指示器位置。
  slidingPosition(int index) async {
    print("索引$index");
    if (imageCount > 5) {
      if (index >= 3 && index + 2 < imageCount) {
        await controller.scrollToIndex(index - 2, preferPosition: AutoScrollPosition.begin);
        controller.highlight(index - 2);
      }
      if (index == 2) {
        await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.end);
        controller.highlight(index);
      }
    }
  }

  // 返回指示器内部元素size。
  double elementSize(int index) {
    if (imageCount <= 5) {
      if (index == zindex) {
        return 7;
      } else {
        return 5;
      }
    } else {
      if (zindex == 0 || zindex == 1 || zindex == 2) {
        if (index == zindex) {
          return 7;
        } else if (index == 4) {
          return 3;
        } else {
          return 5;
        }
      }
      if (zindex >= 3 && zindex + 3 < imageCount) {
        if (index == zindex) {
          return 7;
        } else if (zindex - index == 2 || index - zindex == 2) {
          return 3;
        } else {
          return 5;
        }
      }
      if (zindex == imageCount - 1 || zindex == imageCount - 2 || zindex == imageCount - 3) {
        if (index == zindex) {
          return 7;
        } else if (index + 2 == zindex && zindex == imageCount - 3) {
          return 3;
        } else if (index + 3 == zindex && zindex == imageCount - 2) {
          return 3;
        } else if (index + 4 == zindex && zindex == imageCount - 1) {
          return 3;
        } else {
          return 5;
        }
      }
    }
  }

  /// 列表中的每个条目的Widget
  /// [choseIndex] 列表条目对应的索引
  // buildOpenContainerItem(int index) {
  //   return OpenContainer(
  //     // 动画时长
  //     transitionDuration: const Duration(milliseconds: 700),
  //     transitionType: ContainerTransitionType.fade,
  //     //阴影
  //     closedElevation: 0.0,
  //     //圆角
  //     closedShape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(Radius.circular(0.0)),
  //     ),
  //     ///将要打开的页面
  //     openBuilder:
  //         (BuildContext context, void Function({Object returnValue}) action) {
  //       return Item2Page(photoUrl: widget.model.picUrls[index].url,);
  //     },
  //     ///现在显示的页面
  //     closedBuilder: (BuildContext context, void Function() action) {
  //       ///条目显示的一张图片
  //       return buildShowItemContainer(index);
  //     },
  //   );
  // }
  // 轮播图图片设置
  Widget buildShowItemContainer(int indexs, double height) {
    return widget.isDynamicDetails
        ? CupertinoButton(
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.zero,
            onPressed: () {
              ImagePreview.preview(
                context,
                initialIndex: indexs,
                onIndexChanged: (ind) {
                  // 移动到指定下标，设置不播放动画
                  swiperController.move(ind, animation: false);
                  autoPlay(ind);
                },
                images: List.generate(widget.model.picUrls.length, (index) {
                  return ImageOptions(
                    url: widget.model.picUrls[index].url != null ? widget.model.picUrls[index].url : "",
                    tag: widget.model.picUrls[index].url + "$indexs",
                  );
                }),
              );
            },
            child: ImagePreviewHero(
              tag: widget.model.picUrls[indexs].url + "$indexs",
              child: CachedNetworkImage(
                imageUrl: widget.model.picUrls[indexs].url,
                width: ScreenUtil.instance.width,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
          )
        : widget.model.picUrls.isNotEmpty
            ? Container(
                width: ScreenUtil.instance.width,
                height: height,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  placeholder: (context, url) => new Container(
                      child: new Center(
                    child: new CircularProgressIndicator(),
                  )),
                  imageUrl: widget.model.picUrls[indexs].url != null ? widget.model.picUrls[indexs].url : "",
                  errorWidget: (context, url, error) => new Image.asset("images/test.png"),
                ))
            : widget.model != null && widget.model.selectedMediaFiles != null
                ? Container(
                    width: ScreenUtil.instance.width,
                    height: height,
                    child:  widget.model.selectedMediaFiles.list[indexs].file != null
                            ? Image.file(
                                widget.model.selectedMediaFiles.list[indexs].file,
                                fit: BoxFit.cover,
                              )
                            : Container())
                : Container();
  }

  // 宽高比
  double setAspectRatio(double height) {
    if (height == 0) {
      return ScreenUtil.instance.width;
    } else {
      return (ScreenUtil.instance.width / imageWidth) * height;
    }
  }

  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      BaseResponseModel model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      if (model.code == CODE_BLACKED) {
        ToastShow.show(msg: "你已被拉黑", context: context, gravity: Toast.CENTER);
      } else {

        context
            .read<FeedMapNotifier>()
            .setLaud(widget.model.isLaud, context.read<ProfileNotifier>().profile.avatarUri, widget.model.id);
        context.read<ProfilePageNotifier>().loadChange(widget.model.pushId, context.read<FeedMapNotifier>().feedMap[widget.model.id].isLaud);
        // } else {
        //   // 失败
        //   print("shib ");
        // }
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.instance.screenWidthDp;
    print("轮播图builder：${widget.model.id}");

    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onDoubleTap: () {
                  // 获取是否点赞
                  int isLaud = widget.model.isLaud;
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                  // 动画
                },
                child: Container(
                    width: width,
                    height: setAspectRatio(widget.height),
                    // setAspectRatio(widget.height)

                    // child: Swiper(
                    //   controller: swiperController,
                    //   itemCount: widget.model.picUrls.length,
                    //   itemBuilder: (BuildContext context, int index) {
                    //     print("index:${widget.index}-widget.isHero:${widget.isHero}- widget.isDynamicDetails:${ widget.isDynamicDetails}, widget.pageName :${widget.model.id}");
                    //     return widget.isDynamicDetails||(!widget.isHero)
                    //         ? buildShowItemContainer(
                    //             index,
                    //             setAspectRatio(widget.height),
                    //           )
                    //         : Hero(
                    //             tag: widget.pageName + "${widget.model.id}${widget.index}",
                    //             child: buildShowItemContainer(
                    //               index,
                    //               setAspectRatio(widget.height),
                    //             ));
                    //     // buildOpenContainerItem(index);
                    //   },
                    //   loop: false,
                    //   onIndexChanged: (index) {
                    //     autoPlay(index);
                    //   },
                    //   onTap: (index) {
                    //
                    //   },
                    // ),
                    child: widget.model.picUrls.isNotEmpty
                        ? Swiper.children(
                            children: [
                              for (PicUrlsModel item in widget.model.picUrls)
                                widget.isDynamicDetails || (!widget.isHero)
                                    ? buildShowItemContainer(
                                        widget.model.picUrls.indexOf(item),
                                        setAspectRatio(widget.height),
                                      )
                                    : Hero(
                                        tag: widget.pageName + "${widget.model.id}${widget.index}",
                                        child: buildShowItemContainer(
                                          widget.model.picUrls.indexOf(item),
                                          setAspectRatio(widget.height),
                                        ))
                            ],
                            controller: swiperController,
                            loop: false,
                            onIndexChanged: (index) {
                              autoPlay(index);
                            },
                            onTap: (index) {},
                          )
                        : widget.model != null && widget.model.selectedMediaFiles != null
                            ? Swiper.children(
                                children: [
                                  for (MediaFileModel item in widget.model.selectedMediaFiles.list)
                                    widget.isDynamicDetails || (!widget.isHero)
                                        ? buildShowItemContainer(
                                            widget.model.selectedMediaFiles.list.indexOf(item),
                                            setAspectRatio(widget.height),
                                          )
                                        : Hero(
                                            tag: widget.pageName + "${widget.model.id}${widget.index}",
                                            child: buildShowItemContainer(
                                              widget.model.selectedMediaFiles.list.indexOf(item),
                                              setAspectRatio(widget.height),
                                            ))
                                ],
                                controller: swiperController,
                                loop: false,
                                onIndexChanged: (index) {
                                  autoPlay(index);
                                },
                                onTap: (index) {},
                              )
                            : Container()),
              ),
              Positioned(
                top: 13,
                right: 16,
                child: Offstage(
                  offstage: imageCount == 1,
                  child: Container(
                    padding: EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: AppColor.textPrimary1.withOpacity(0.5)),
                    child: Text(
                      "${zindex + 1}/${imageCount}",
                      style: TextStyle(color: AppColor.white, fontSize: 12),
                    ),
                  ),
                ),
                // child:
              )
            ],
          ),
          Offstage(
            offstage: imageCount == 1,
            child: Container(
              width: getWidth(),
              height: 10,
              margin: const EdgeInsets.only(top: 5),
              // color: Colors.orange,
              child: ListView.builder(
                  scrollDirection: scrollDirection,
                  controller: controller,
                  itemCount: imageCount,
                  // 禁止手动滑动
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AutoScrollTag(
                        key: ValueKey(index),
                        controller: controller,
                        index: index,
                        child: Container(
                            width: elementSize(index),
                            height: elementSize(index),
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                                color: index == zindex ? AppColor.black : AppColor.textPrimary1.withOpacity(0.12),
                                shape: BoxShape.circle)));
                  }),
            ),
          )
        ],
      ),
    );
  }
}
