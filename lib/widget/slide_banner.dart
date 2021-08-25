import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube_transition/cube_transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/test/tik_tok_test/tikTokGesture.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/image_cached_observer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/banner_view/banner_view.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:provider/provider.dart';

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

class _SlideBannerState extends State<SlideBanner> with WidgetsBindingObserver {
  int zindex = 0; //要移入的下标

  // 图片张数
  int imageCount = 0;

  // 图片宽度
  int imageWidth = 0;

  //小圆点
  final double smallDotsSize = 2;

  //中号圆点
  final double mediumDotsSize = 4;

  //大号圆点
  final double bigDotsSize = 6;

  //中间间隔
  final double spacingWidth = 4;

  // scroll_to_index定位
  // AutoScrollController controller;
  ScrollController scrollController = ScrollController();

  // SwiperController swiperController = SwiperController();

  // 指示器横向布局
  final scrollDirection = Axis.horizontal;

  /*
   初始化一个StreamController<任何数据> 简单的可以扔一个int,string,开发中经常扔一个网络请求的model进去，具体看你使用场景了
   */
  // 分页指示器下方的小点
  final StreamController<int> pagingIndicatorStreamController = StreamController<int>();

  // 分页标签数字
  StreamController<int> paginationTabStreamController;
  List<Widget> cupertinoButtonList = [];
  int beforIndex = 0;

  // 是否可点赞
  bool isSetUpLuad = true;
  var indicatorTransform = Matrix4.identity();

  @override
  void dispose() {
    // TODO: implement dispose
    // 关流，不管流会消耗资源，同时会引起内存泄漏
    print("轮播图页面销毁了");
    pagingIndicatorStreamController.close();
    paginationTabStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    paginationTabStreamController = StreamController.broadcast();
    //初始化
    WidgetsBinding.instance.addObserver(this);
    if (widget.model != null && widget.model.selectedMediaFiles != null) {
      print("图片显示问题:::${widget.model.selectedMediaFiles.list.first.file}");
      imageCount = widget.model.selectedMediaFiles.list.length;
      imageWidth = widget.model.selectedMediaFiles.list.first.sizeInfo.width;
    }
    if (widget.model.picUrls.isNotEmpty) {
      imageCount = widget.model.picUrls.length;
      imageWidth = widget.model.picUrls.first.width;
    }
    // swiperController.addListener(() {
    //   print(swiperController.index);
    // });

    // controller = AutoScrollController(
    //     viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
    //     axis: scrollDirection);
  }

  // 滑动回调
  autoPlay(int index) {
    print("轮播图回调$index");
    pagingIndicatorStreamController.sink.add(index);
    paginationTabStreamController.sink.add(index);
  }

  // 轮播图设置预览设置
  List<Widget> buildShowItemContainer(double height) {
    List<Widget> cupertinoButtons = [];
    List.generate(widget.model.picUrls.length, (indexs) {
      PicUrlsModel item = widget.model.picUrls[indexs];
      // if(indexs == 2) {
      //   item.url = null;
      // }
      // 查看大图设置
      // cupertinoButtons.add(CupertinoButton(
      //          borderRadius: BorderRadius.zero,
      //          padding: EdgeInsets.zero,
      //          onPressed: () {
      //            print('---------------------------------大图预览');
      //            ImagePreview.preview(
      //              context,
      //              initialIndex: indexs,
      //              onIndexChanged: (ind) {
      //                // 移动到指定下标，设置不播放动画
      //                swiperController.move(ind, animation: false);
      //                autoPlay(ind);
      //              },
      //              images: List.generate(widget.model.picUrls.length, (index) {
      //                return ImageOptions(
      //                  url: widget.model.picUrls[index].url != null ? widget.model.picUrls[index].url : "",
      //                  tag: widget.model.picUrls[index].url + "$indexs",
      //                );
      //              }),
      //            ).then((value) {
      //              context.read<FeedMapNotifier>().changeImageDetailsStatus(false);
      //            });
      //          },
      //          child: ImagePreviewHero(
      //            tag: item.url + "$indexs",
      //            child: CachedNetworkImage(
      //              /// imageUrl的淡入动画的持续时间。
      //              // fadeInDuration: Duration(milliseconds: 0),
      //              imageUrl: item.url != null ? FileUtil.getImageSlim(item.url) : "",
      //              width: ScreenUtil.instance.width,
      //              height: height,
      //              fit: BoxFit.cover,
      //              placeholder: (context, url) => Container(
      //                color: AppColor.bgWhite,
      //              ),
      //              errorWidget: (context, url, e) {
      //                return Container(
      //                  color: AppColor.bgWhite,
      //                );
      //              },
      //            ),
      //          ),
      //        ));

      // 轮播图设置
      cupertinoButtons.add((!widget.isHero)
          ? Container(
              width: ScreenUtil.instance.width,
              height: height,
              // color: AppColor.mainRed,
              child: CachedNetworkImage(
                /// imageUrl的淡入动画的持续时间。
                fadeInDuration: Duration(milliseconds: 0),
                // useOldImageOnUrlChange: true,
                fit: BoxFit.cover,
                useOldImageOnUrlChange: true,
                imageUrl: item.url != null
                    ?
                    // FileUtil.getThumbnail(item.url)
                    FileUtil.getImageSlim(item.url)
                    : "",
                placeholder: (context, url) {
                  return CachedNetworkImage(
                    /// imageUrl的淡入动画的持续时间。
                    fadeInDuration: Duration(milliseconds: 0),
                    // useOldImageOnUrlChange: true,
                    fit: BoxFit.cover,
                    useOldImageOnUrlChange: true,
                    imageUrl: item.url != null
                        ?
                        // FileUtil.getThumbnail(item.url)
                        FileUtil.getThumbnail(item.url)
                        : "",
                    placeholder: (context, url) {
                      return Container(
                        color: AppColor.bgWhite,
                      );
                    },
                    errorWidget: (context, url, e) {
                      return Container(
                        color: AppColor.bgWhite,
                      );
                    },
                  );
                  return Image.network(
                    FileUtil.getThumbnail(item.url),
                    fit: BoxFit.cover,
                  );
                },
                errorWidget: (context, url, e) {
                  return Container(
                    color: AppColor.bgWhite,
                  );
                },
              ))
          : Hero(
              tag: widget.pageName + "${widget.model.id}${widget.index}",
              child: Container(
                  width: ScreenUtil.instance.width,
                  height: setAspectRatio(widget.height),
                  child: CachedNetworkImage(
                    /// imageUrl的淡入动画的持续时间。
                    fadeInDuration: Duration(milliseconds: 0),
                    fit: BoxFit.cover,
                    imageUrl: item.url != null ? FileUtil.getImageSlim(item.url) : "",
                    placeholder: (context, url) {
                      return Image.network(
                        FileUtil.getThumbnail(item.url),
                        fit: BoxFit.cover,
                      );
                      // return Container(
                      //   color: AppColor.bgWhite,
                      // );
                    },
                    errorWidget: (context, url, e) {
                      return Container(
                        color: AppColor.imageBgGrey,
                        alignment: Alignment.center,
                        child: getImageAsset("assets/png/image_error.png"),
                      );
                    },
                  )),
            ));
    });
    return cupertinoButtons;
  }

  Widget getImageAsset(String assetPath) {
    //print("assetPath:${assetPath}");
    return UnconstrainedBox(
      child: Image.asset(
        assetPath ?? "",
        width: ScreenUtil.instance.width * 0.53,
        height: ScreenUtil.instance.width * 0.53,
        fit: BoxFit.cover,
      ),
    );
  }

  // 本地图片
  // List<Widget> localPicture(double height) {
  //   List<Widget> localImages = [];
  //   for (MediaFileModel item in widget.model.selectedMediaFiles.list) {
  //     int indexs = widget.model.selectedMediaFiles.list.indexOf(item);
  //     localImages.add(widget.isDynamicDetails || (!widget.isHero)
  //         ? Container(
  //             width: ScreenUtil.instance.width,
  //             height: height,
  //             child: widget.model.selectedMediaFiles.list[indexs].file != null
  //                 ? Image.file(
  //                     widget.model.selectedMediaFiles.list[indexs].file,
  //                     fit: BoxFit.cover,
  //                   )
  //                 : Container())
  //         : Hero(
  //             tag: widget.pageName + "${widget.model.id}${widget.index}",
  //             child: Container(
  //                 width: ScreenUtil.instance.width,
  //                 height: height,
  //                 child: widget.model.selectedMediaFiles.list[indexs].file != null
  //                     ? Image.file(
  //                         widget.model.selectedMediaFiles.list[indexs].file,
  //                         fit: BoxFit.cover,
  //                       )
  //                     : Container()),
  //           ));
  //   }
  //   return localImages;
  // }

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
      if (isSetUpLuad) {
        isSetUpLuad = false;
        BaseResponseModel model = await laud(
            id: widget.model.id,
            laud: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0);
        print('===================================model.code==${model.code}');
        // 点赞/取消赞成功
        if (model.code == CODE_BLACKED) {
          ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
        } else {
          context.read<FeedMapNotifier>().setLaud(
              context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0,
              context.read<ProfileNotifier>().profile.avatarUri,
              widget.model.id);
          context
              .read<UserInteractiveNotifier>()
              .laudedChange(widget.model.pushId, context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud);
        }
        isSetUpLuad = true;
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  Size getDotsSize(int choseIndex, index) {
    if (index != choseIndex) {
      if (imageCount < 6) {
        return Size(mediumDotsSize, mediumDotsSize);
      }
      if (choseIndex < 3) {
        if (index == 4) {
          return Size(smallDotsSize, smallDotsSize);
        }
        return Size(mediumDotsSize, mediumDotsSize);
      } else {
        if (choseIndex < imageCount - 3) {
          if (index == choseIndex - 2 || index == choseIndex + 2) {
            return Size(smallDotsSize, smallDotsSize);
          } else {
            return Size(mediumDotsSize, mediumDotsSize);
          }
        } else {
          if (index == imageCount - 5) {
            return Size(smallDotsSize, smallDotsSize);
          } else {
            return Size(mediumDotsSize, mediumDotsSize);
          }
        }
      }
    } else {
      return Size(bigDotsSize, bigDotsSize);
    }
  }

  double getDotsWidth(int choseIndex) {
    if (imageCount < 6) {
      //多加一点边距
      return (imageCount - 1) * mediumDotsSize +
          bigDotsSize +
          (imageCount - 1) * spacingWidth +
          mediumDotsSize.toDouble();
    } else if (imageCount > 6) {
      if (choseIndex < 3 || choseIndex >= imageCount - 3) {
        return mediumDotsSize * 3 + bigDotsSize + smallDotsSize + spacingWidth * 4 + mediumDotsSize.toDouble();
      } else {
        return smallDotsSize * 2 + mediumDotsSize * 2 + bigDotsSize + spacingWidth * 4 + mediumDotsSize.toDouble();
      }
    } else {
      return mediumDotsSize * 3 + bigDotsSize + smallDotsSize + spacingWidth * 4 + mediumDotsSize.toDouble();
    }
  }

  // 3d轮播
  _3DSlideBanner() {
    return CubePageView.builder(
      itemCount: widget.model.picUrls.length,
      onPageChanged: (index) {
        autoPlay(index);
        print("index::::$index");
        if (index > 1) {
          if (index < imageCount - 3) {
            scrollController.animateTo(((index - 2) * (mediumDotsSize + spacingWidth)).toDouble(),
                duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
          } else if (index >= imageCount - 3) {
            scrollController.animateTo(scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
          }
        } else if (beforIndex != null && beforIndex > index) {
          scrollController.animateTo(scrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
        }
        beforIndex = index;
      },
      itemBuilder: (context, index, notifier) {
        PicUrlsModel item = widget.model.picUrls[index];
        final transform = Matrix4.identity();
        final t = (index - notifier).abs();
        final scale = lerpDouble(1.5, 0, t);
        transform.scale(scale, scale);
        indicatorTransform = transform;
        return CubeWidget(
            index: index,
            pageNotifier: notifier,
            child: Stack(children: [
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () {
                    // 获取是否点赞
                    int isLaud = context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud;
                    if (isLaud != 1) {
                      setUpLuad();
                    }
                    // 动画
                  },
                  child: CachedNetworkImage(
                    /// imageUrl的淡入动画的持续时间。
                    fadeInDuration: Duration(milliseconds: 0),
                    // useOldImageOnUrlChange: true,
                    fit: BoxFit.cover,
                    useOldImageOnUrlChange: true,
                    imageUrl: item.url != null
                        ?
                        // FileUtil.getThumbnail(item.url)
                        FileUtil.getImageSlim(item.url)
                        : "",
                    placeholder: (context, url) {
                      return CachedNetworkImage(
                        /// imageUrl的淡入动画的持续时间。
                        fadeInDuration: Duration(milliseconds: 0),
                        // useOldImageOnUrlChange: true,
                        fit: BoxFit.cover,
                        useOldImageOnUrlChange: true,
                        imageUrl: item.url != null
                            ?
                            // FileUtil.getThumbnail(item.url)
                            FileUtil.getThumbnail(item.url)
                            : "",
                        placeholder: (context, url) {
                          return Container(
                            color: AppColor.bgWhite,
                          );
                        },
                        errorWidget: (context, url, e) {
                          return Container(
                            color: AppColor.bgWhite,
                          );
                        },
                      );
                      return Image.network(
                        FileUtil.getThumbnail(item.url),
                        fit: BoxFit.cover,
                      );
                    },
                    errorWidget: (context, url, e) {
                      return Container(
                        color: AppColor.bgWhite,
                      );
                    },
                  )),
              Positioned(
                top: 13,
                right: 16,
                // width: getTextSize("9/9",  TextStyle(color: AppColor.white, fontSize: 12), 1).width + 12,
                // height: getTextSize("9/9",  TextStyle(color: AppColor.white, fontSize: 12), 1).height + 6,
                child: Offstage(
                    offstage: imageCount == 1,
                    child: StreamBuilder<int>(
                        // 监听Stream，每次值改变的时候，更新Text中的内容
                        stream: paginationTabStreamController.stream, //数据流
                        initialData: zindex, //初始值
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          return Container(
                            // width: getTextSize("${snapshot.data + 1}/${imageCount}",  TextStyle(color: AppColor.white, fontSize: 12), 1).width + 12,
                            // height: getTextSize("${snapshot.data + 1}/${imageCount}",  TextStyle(color: AppColor.white, fontSize: 12), 1).height + 6,
                            // color: AppColor.mainRed,
                            padding: const EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                color: AppColor.textPrimary1.withOpacity(0.5)),
                            child: Text(
                              "${snapshot.data + 1}/${imageCount}",
                              style: AppStyle.whiteRegular12,
                            ),
                          );
                        })),
              )
            ]));
      },
    );
  }

  // 2d轮播
  _2DSlideBanner() {
    return Stack(
      children: [
        Application.slideFeedLike
            ? TikTokGesture(
                onAddFavorite: () {
                  print("双击");
                  // 获取是否点赞
                  int isLaud = context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud;
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                },
                onSingleTap: () {
                  print("单击");
                },
                child: BannerView(
                  cupertinoButtonList,
                  cycleRolling: false,
                  autoRolling: false,
                  onPageChanged: (index) {
                    autoPlay(index);
                    if (index > 1) {
                      if (index < imageCount - 3) {
                        scrollController.animateTo(((index - 2) * (mediumDotsSize + spacingWidth)).toDouble(),
                            duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                      } else if (index >= imageCount - 3) {
                        scrollController.animateTo(scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                      }
                    } else if (beforIndex != null && beforIndex > index) {
                      scrollController.animateTo(scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 150), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                    }
                    beforIndex = index;
                  },
                ),
              )
            : GestureDetector(
                onDoubleTap: () {
                  // 获取是否点赞
                  int isLaud = context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud;
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                  // 动画
                },
                child: BannerView(
                  cupertinoButtonList,
                  cycleRolling: false,
                  autoRolling: false,
                  onPageChanged: (index) async {
                   await autoPlay(index);
                    if (index > 1) {
                      if (index < imageCount - 3) {
                        scrollController.animateTo(((index - 2) * (mediumDotsSize + spacingWidth)).toDouble(),
                            duration: Duration(milliseconds: 350), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                      } else if (index >= imageCount - 3) {
                        scrollController.animateTo(scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 350), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                      }
                    } else if (beforIndex != null && beforIndex > index) {
                      scrollController.animateTo(scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 350), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                    }
                    beforIndex = index;
                  },
                )),
        Positioned(
          top: 13,
          right: 16,
          child: Offstage(
              offstage: imageCount == 1,
              child: StreamBuilder<int>(
                  // 监听Stream，每次值改变的时候，更新Text中的内容
                  stream: paginationTabStreamController.stream, //数据流
                  initialData: zindex, //初始值
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    return Container(
                      padding: const EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: AppColor.textPrimary1.withOpacity(0.5)),
                      child: Text(
                        "${snapshot.data + 1}/${imageCount}",
                        style: AppStyle.whiteRegular12,
                      ),
                    );
                  })),
          // child:
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.instance.screenWidthDp;
    print("轮播图builder：${widget.model.id}");
    // 预加载图片组件
    if (widget.model != null && widget.model.picUrls.isNotEmpty) {
      cupertinoButtonList = buildShowItemContainer(setAspectRatio(widget.height));
    }
    // else if (widget.model != null && widget.model.selectedMediaFiles != null) {
    //   cupertinoButtonList = localPicture(setAspectRatio(widget.height));
    // }
    return Container(
      child: Column(
        children: [
          Container(
            width: width,
            height: setAspectRatio(widget.height),
            // 轮播图
            child: Application.slideBanner2Dor3D ? _3DSlideBanner() : _2DSlideBanner(),
            // child: Swiper.children(
            //   children: cupertinoButtonList,
            //   autoplayDelay: 0,
            //   duration:0,
            //   controller: swiperController,
            //   viewportFraction: 0.99999999,
            //   loop: false,
            //   onIndexChanged: (index) {
            //     autoPlay(index);
            //     if (index > 1) {
            //       if (index < imageCount - 3) {
            //         controller.animateTo(((index - 2) * (mediumDotsSize + spacingWidth)).toDouble(),
            //             duration: Duration(milliseconds: 250), curve: Cubic(1.0, 1.0, 1.0, 1.0));
            //       } else if (index == imageCount - 3) {
            //         controller.animateTo(controller.position.maxScrollExtent,
            //             duration: Duration(milliseconds: 250), curve: Cubic(1.0, 1.0, 1.0, 1.0));
            //       }
            //     }
            //   },
            //   onTap: (index) {},
            // )
          ),
          Offstage(
              offstage: imageCount == 1,
              child: StreamBuilder<int>(
                  // 监听Stream，每次值改变的时候，更新Text中的内容
                  stream: pagingIndicatorStreamController.stream, //数据流
                  initialData: zindex, //初始值
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    return Container(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        width: getDotsWidth(snapshot.data),
                        height: 10,
                        margin: const EdgeInsets.only(top: 5),
                        child: ScrollConfiguration(
                          behavior: OverScrollBehavior(),
                          child: ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                height: getDotsSize(snapshot.data, index).height,
                                width: getDotsSize(snapshot.data, index).width,
                                decoration: BoxDecoration(
                                    color: snapshot.data == index
                                        ? AppColor.bgWhite
                                        : AppColor.layoutBgGrey,
                                    shape: BoxShape.circle),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                              width: 4,
                              color: AppColor.mainBlack,
                            ),
                            itemCount: imageCount,
                          ),
                        ));
                  }))
        ],
      ),
    );
  }

  // didHaveMemoryPressure
  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
    super.didHaveMemoryPressure();
    try {
      print("轮播图清除缓存");
      if (widget.model != null && widget.model.picUrls.length > 0) {
        widget.model.picUrls.forEach((element) {
          if (element.url != null) {
            ImageCachedObserverUtil.clearCacheNetworkImageMemory(element.url);
          }
        });
      }
    } catch (e) {
      print("轮播图清除缓存失败：：：：：：：：：$e");
    }
  }
}
