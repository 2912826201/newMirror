import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TabBar, TabBarView;
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/search_history_db_helper.dart';
import 'package:mirror/data/dto/search_history_dto.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/search/search_hot_words.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/search/sub_page/search_complex.dart';
import 'package:mirror/page/search/sub_page/search_course.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/page/search/sub_page/search_topic.dart';
import 'package:mirror/page/search/sub_page/search_user.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/Input_method_rules/input_formatter.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/customize_tab_bar/customize_tab_bar.dart' as Custom;
import 'package:mirror/widget/customize_tab_bar/customiize_tab_bar_view.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

// ?????????
class SearchPage extends StatelessWidget {
  final defaultIndex;

  SearchPage({Key key, this.defaultIndex = 0});

  // ????????????????????????
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("?????????");
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.mainBlack,
        body: Container(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  //???????????????????????????
                  focusNode.unfocus();
                },
                child: ChangeNotifierProvider(
                    create: (_) => SearchEnterNotifier(enterText: ""),
                    builder: (context, _) {
                      return Column(
                        children: [
                          // ??????
                          SearchHeader(
                            focusNode: focusNode,
                          ),
                          context.watch<SearchEnterNotifier>().enterText.length > 0
                              ? SearchTabBarView(
                                  focusNode: focusNode,
                                  defaultIndex: defaultIndex,
                                )
                              : SearchMiddleView(),
                          // )
                        ],
                      );
                    }))));
  }
}

// // ??????????????????
class SearchHeader extends StatefulWidget {
  final FocusNode focusNode;

  SearchHeader({Key key, this.focusNode}) : super(key: key);

  @override
  _SearchHeaderState createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  TextEditingController controller = TextEditingController();

  ///??????????????????
  var lastInput = "";

  InputFormatter _formatter;
  List<TextInputFormatter> inputFormatters;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<SearchEnterNotifier>().EditTextController(controller);
    });
    _formatter = InputFormatter(
      controller: controller,
      inputChangedCallback: (String value) {
        context.read<SearchEnterNotifier>().changeCallback(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil.instance.statusBarHeight,
      ),
      height: CustomAppBar.appBarHeight,
      width: ScreenUtil.instance.screenWidthDp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            height: 32,
            decoration: BoxDecoration(
                color: AppColor.white.withOpacity(0.1), borderRadius: const BorderRadius.all(Radius.circular(2))),
            width: ScreenUtil.instance.screenWidthDp - 32 - 32 - 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 9,
                ),
                AppIcon.getAppIcon(AppIcon.input_search, 24, color: AppColor.textWhite60),
                Expanded(
                  child: TextField(
                    focusNode: widget.focusNode,
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    cursorColor: AppColor.white,
                    onSubmitted: (text) {
                      if (text.isNotEmpty && context.read<TokenNotifier>().isLoggedIn) {
                        SearchHistoryDBHelper().insertSearchHistory(context.read<ProfileNotifier>().profile.uid, text);
                      }
                    },
                    style: AppStyle.whiteRegular16,
                    // onChanged: (text) {
                    //
                    // },
                    decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                        hintText: '????????????????????????${AppConfig.needShowTraining ? "?????????" : ""}??????',
                        // ??????????????????
                        hintStyle: AppStyle.text1Regular14,
                        border: InputBorder.none),
                    inputFormatters: inputFormatters == null ? [_formatter] : (inputFormatters..add(_formatter)),
                    // inputFormatters: [
                    //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //???????????????????????????????????????
                    //   LengthLimitingTextInputFormatter(30),
                    // ],
                  ),
                ),
                Visibility(
                  visible: context.watch<SearchEnterNotifier>().enterText != null &&
                      context.watch<SearchEnterNotifier>().enterText.length > 0,
                  child: AppIconButton(
                    svgName: AppIcon.clear_circle_grey,
                    iconSize: 16,
                    buttonWidth: 40,
                    buttonHeight: 32,
                    onTap: () {
                      print("????????????");
                      controller.clear();
                      print(controller.text);
                      context.read<SearchEnterNotifier>().changeCallback("");
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          CustomAppBarTextButton("??????", AppColor.textWhite60, () {
            Navigator.of(context).pop(true);
          }),
          SizedBox(
            width: CustomAppBar.appBarHorizontalPadding,
          )
        ],
      ),
    );
  }
}

// ???????????????????????????
class SearchMiddleView extends StatefulWidget {
  @override
  SearchMiddleViewState createState() => SearchMiddleViewState();
}

class SearchMiddleViewState extends State<SearchMiddleView> with TickerProviderStateMixin {
  List<TopicDtoModel> topicList = [];
  List<SearchHistoryDto> searchHistoryList = [];
  List<CourseModel> liveVideoList = [];
  List<SearchHotWords> hotWordList = [];
  AnimationController animation;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void dispose() {
    // TODO: implement dispose
    // ??????????????????
    cancelRequests(token: token);
    super.dispose();
  }

  @override
  void initState() {
    animation = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    List<Future> requestList = [];
    // ????????????????????????
    requestList.add(getRecommendTopic(size: 20, token: token));
    // ??????????????????
    requestList.add(
      SearchHistoryDBHelper().querySearchHistory(
          context.read<ProfileNotifier>().profile != null ? context.read<ProfileNotifier>().profile.uid : -1),
    );
    // ??????????????????
    requestList.add(getHotWords(token));
    // ??????????????????
    if (AppConfig.needShowTraining) requestList.add(recommendCourse(token));
    // ????????????
    Future.wait(requestList).then((results) {
      print("???????????????????????????????????????????????????$searchHistoryList");
      if (results[0] != null) {
        DataResponseModel model = results[0];
        if (model != null && model.list.isNotEmpty) {
          model.list.forEach((v) {
            topicList.add(TopicDtoModel.fromJson(v));
          });
        }
      }
      if (mounted && context.read<TokenNotifier>().isLoggedIn) {
        searchHistoryList = results[1];
      }
      if (results[2] != null) {
        hotWordList = results[2];
      }
      if (AppConfig.needShowTraining) {
        List<CourseModel> liveList = [];
        if (results[3] != null) {
          liveList = results[3];
          if (liveList.isNotEmpty) {
            liveVideoList.addAll(liveList);
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      print("?????????");
      print(e);
    }).catchError((e) {
      if (CancelToken.isCancel(e)) {
        print("?????????");
        print(e);
      }
    });
    /*.catchError((e) {
      print("?????????");
      print(e);
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("?????????????????? ??????");
    return Container(
        width: ScreenUtil.instance.width,
        height: ScreenUtil.instance.height - CustomAppBar.appBarHeight - ScreenUtil.instance.statusBarHeight,
        child: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // ?????????????????????
              searchHistoryList.isNotEmpty ? historyRecordSizeTransition() : Container(),
              hotWordList.isNotEmpty ? HotCourseRecommend() : Container(),
              hotWordList.isNotEmpty
                  ? liveVideoList.isNotEmpty
                      ? HotCourseRecommendStyleOne()
                      : HotCourseRecommendStyleTwo()
                  : Container(),
              // hotWordList.isNotEmpty ? HotCourseRecommend() : Container(),
              // hotWordList.isNotEmpty
              //     ? liveVideoList.isNotEmpty
              //         ? HotCourseRecommendStyleTwo()
              //         : HotCourseRecommendStyleOne()
              //     : Container(),
              liveVideoList.isNotEmpty ? HotCourseTitleBar() : Container(),
              liveVideoList.isNotEmpty ? HotCourseContent() : Container(),
              topicList.isNotEmpty ? HotTopicTitleBar() : Container(),
              topicList.isNotEmpty ? HotTopicContent() : Container(),
            ],
          ),
        ));
  }

// ?????????????????????
  searchTitleBar(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "????????????",
            style: AppStyle.whiteMedium15,
          ),
          const Spacer(),
          AppIconButton(
            iconSize: 18,
            svgName: AppIcon.trash_bucket,
            iconColor: AppColor.white,
            onTap: () {
              animation.forward().then((value) {
                SearchHistoryDBHelper().clearSearchHistory(context.read<ProfileNotifier>().profile.uid);
                setState(() {
                  searchHistoryList.clear();
                });
              });
              // SearchHistoryDBHelper().clearSearchHistory(context.read<ProfileNotifier>().profile.uid);
              // setState(() {
              //   searchHistoryList.clear();
              // });
            },
          ),
        ],
      ),
    );
  }

// ????????????Item??????
  historyRecordItemSpacing(int count, int index) {
    if (count > 10 && index == 9) {
      return 16.0;
    } else if (count < 10 && index == count - 1) {
      return 16.0;
    } else {
      return 0.0;
    }
  }

// ????????????????????????
  historyRecordSizeTransition() {
    return SizeTransition(
        sizeFactor: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )),
        axis: Axis.vertical,
        axisAlignment: 1.0,
        child: Container(
            width: ScreenUtil.instance.screenWidthDp,
            child: Column(children: [
              searchTitleBar(context),
              historyRecord(context),
            ])));
  }

// ????????????
  historyRecord(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment(-1, 0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: searchHistoryList.length > 10 ? 10 : searchHistoryList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.read<SearchEnterNotifier>().changeCallback(searchHistoryList[index].word);
                context.read<SearchEnterNotifier>().textController.text = searchHistoryList[index].word;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: AppColor.layoutBgGrey, borderRadius: const BorderRadius.all(Radius.circular(2))),
                margin: EdgeInsets.only(left: 16, right: historyRecordItemSpacing(searchHistoryList.length, index)),
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4),
                alignment: const Alignment(0, 0),
                child: Center(
                    child: Text(
                  searchHistoryList[index].word,
                  style: AppStyle.whiteRegular12,
                )),
              ),
            );
          }),
    );
  }

  // ?????????????????????
  HotCourseRecommend() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // ???????????????
        alignment: const Alignment(-1, 0),
        child: const Text(
          "????????????",
          style: AppStyle.whiteMedium15,
        ));
  }

  // ???????????????????????????
  HotCourseRecommendStyleOne() {
    //listHotCourseRecommend1
    List<Widget> _container = List.generate(hotWordList.length, (index) {
      return GestureDetector(
          onTap: () {
            context.read<SearchEnterNotifier>().changeCallback(hotWordList[index].name);
            context.read<SearchEnterNotifier>().textController.text = hotWordList[index].name;
          },
          child: Container(
            height: 24,
            width: getTextSize(
                        hotWordList[index].name,
                        TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        1)
                    .width +
                16,
            decoration:
                BoxDecoration(color: AppColor.layoutBgGrey, borderRadius: const BorderRadius.all(Radius.circular(2))),
            child: Center(
                child: Text(hotWordList[index].name,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.white,
                      fontWeight: FontWeight.w400,
                    ))),
          ));
    });
    return Container(
      width: ScreenUtil.instance.width,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.end,
        spacing: 16,
        runSpacing: 16,
        children: _container,
      ),
    );
  }

// ???????????????????????????
  HotCourseRecommendStyleTwo() {
    List<Widget> _container = List.generate(hotWordList.length, (index) {
      return Container(
        // color: AppColor.color707070,
        width: (ScreenUtil.instance.width - 48) / 2,
        child: Row(
          children: [
            GestureDetector(
                onTap: () {
                  context.read<SearchEnterNotifier>().changeCallback(hotWordList[index].name);
                  context.read<SearchEnterNotifier>().textController.text = hotWordList[index].name;
                },
                child: Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: AppColor.mainRed, borderRadius: const BorderRadius.all(Radius.circular(3))),
                  margin: EdgeInsets.only(right: 6),
                )),
            GestureDetector(
                onTap: () {
                  context.read<SearchEnterNotifier>().changeCallback(hotWordList[index].name);
                  context.read<SearchEnterNotifier>().textController.text = hotWordList[index].name;
                },
                child: Text(hotWordList[index].name,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.white,
                      fontWeight: FontWeight.w400,
                    )))
          ],
        ),
      );
    });
    return Container(
        width: ScreenUtil.instance.width,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.end,
          spacing: 16,
          runSpacing: 16,
          children: _container,
        ));
  }

// ?????????????????????
  HotCourseTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // ???????????????
        alignment: const Alignment(-1, 0),
        child: const Text(
          "????????????",
          style: AppStyle.whiteMedium15,
        ));
  }

// ????????????????????????
  HotCourseContent() {
    return Container(
      height: liveVideoList.length > 2 ? 96 : 48,
      width: ScreenUtil.instance.screenWidthDp,
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 16.0,
        //???direction: Axis.horizontal????????????????????????Widget?????????,???direction: Axis.vertical????????????????????????widget?????????
        // runSpacing: 16.0,//???direction: Axis.horizontal????????????????????????Widget?????????,???direction: Axis.vertical????????????????????????widget?????????
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        textDirection: TextDirection.ltr,
        children: HotCourseContentItem(),
      ),
    );
  }

  // ????????????????????????Item
  List<Widget> HotCourseContentItem() => List.generate(liveVideoList.length > 4 ? 4 : liveVideoList.length, (index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            AppRouter.navigateToVideoDetail(context, liveVideoList[index].id, videoModel: liveVideoList[index]);
            // TopicDtoModel topicModel = await getTopicInfo(topicId: topicList.first.id);
            // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => StickyDemo(model: topicModel,)));
          },
          child: Container(
            height: 48,
            width: (ScreenUtil.instance.width - 48) / 2,
            padding: const EdgeInsets.only(top: 5, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${index + 1}",
                  style: index == 3
                      ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColor.textWhite60)
                      : AppStyle.redMedium14,
                ),
                const Spacer(),
                Container(
                  // height: 38,
                  width: ((ScreenUtil.instance.width - 48) / 2) - 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(liveVideoList[index].title,
                          style: AppStyle.whiteRegular14, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(
                        liveVideoList[index].description,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 22,
                )
              ],
            ),
          ),
        );
      });

// ??????????????????
  HotTopicTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // ???????????????
        alignment: const Alignment(-1, 0),
        child: const Text(
          "????????????",
          style: AppStyle.whiteMedium15,
        ));
  }

// ????????????????????????
  HotTopicContent() {
    return Container(
      height: (ScreenUtil.instance.screenWidthDp - 38) * 0.46,
      width: ScreenUtil.instance.screenWidthDp,
      child: Swiper(
        itemCount: topicList.length > 5 ? 5 : topicList.length,
        itemWidth: ScreenUtil.instance.screenWidthDp - 38,
        itemHeight: (ScreenUtil.instance.screenWidthDp - 38) * 0.43,
        layout: SwiperLayout.STACK,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              AppRouter.navigateToTopicDetailPage(context, topicList[index].id);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColor.layoutBgGrey, borderRadius: const BorderRadius.all(Radius.circular(2))),
                  // decoration: BoxDecoration(
                  //     // ?????????
                  //     gradient: const LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomLeft,
                  //       colors: [
                  //         AppColor.bgWhite,
                  //         Colors.white,
                  //       ],
                  //     ),
                  //     // ????????????
                  //     boxShadow: [
                  //       BoxShadow(
                  //           color: AppColor.textHint.withOpacity(0.3),
                  //           offset: Offset(0.0, 1.0), //??????xy????????????
                  //           blurRadius: 1.0, //??????????????????
                  //           spreadRadius: 2.6 //??????????????????
                  //           )
                  //     ]),
                ),
                Image.asset(
                  "assets/png/bg_topic.png",
                ),
                Container(
                  margin: const EdgeInsets.only(top: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, top: 3.5),
                        child: AppIcon.getAppIcon(AppIcon.topic, 24,
                            containerHeight: 32, containerWidth: 32, color: AppColor.white),
                      ),
                      // Expanded(
                      //     child:
                      Container(
                        width: ScreenUtil.instance.screenWidthDp * 0.68,
                        margin: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "#${topicList[index].name}",
                              maxLines: 3,
                              style: AppStyle.whiteRegular15,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              "${topicList[index].feedCount}?????????",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
                            ),
                          ],
                        ),
                        // )
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 63, right: 10),
                  height: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: topicList[index].pics.length,
                      itemBuilder: (context, indexs) {
                        return Container(
                            height: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                            width: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                            margin: EdgeInsets.only(right: indexs != 3 ? 7 : 0),
                            //??????????????????
                            decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                            ),
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              height: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                              width: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                              // ?????????????????????????????????
                              // maxHeightDiskCache: 250,
                              // maxWidthDiskCache: 250,
                              // ??????????????????
                              memCacheWidth: 250,
                              memCacheHeight: 250,
                              imageUrl: topicList[index].pics[indexs] != null
                                  ? FileUtil.getMediumImage(topicList[index].pics[indexs].coverUrl)
                                  : "",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColor.bgWhite,
                              ),
                              errorWidget: (context, url, e) {
                                return Container(
                                  color: AppColor.bgWhite,
                                );
                              },
                            ));
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ?????????TabBarView
class SearchTabBarView extends StatefulWidget {
  SearchTabBarView({Key key, this.focusNode, this.defaultIndex}) : super(key: key);
  FocusNode focusNode;
  final defaultIndex;

  @override
  SearchTabBarViewState createState() => SearchTabBarViewState();
}

class SearchTabBarViewState extends State<SearchTabBarView> with SingleTickerProviderStateMixin {
  // taBar???TabBarView?????????
  TabController controller;
  List<Widget> tabList = [];

  @override
  void dispose() {
    controller.dispose();
    print("???????????????");
    // ????????????????????????SearchTabBarView???????????????????????????????????????setstate?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????tarBar????????????????????????????????????????????????
    Application.tabBarIndexList.clear();
    super.dispose();
  }

  @override
  void initState() {
    controller =
        TabController(length: AppConfig.needShowTraining ? 5 : 4, vsync: this, initialIndex: widget.defaultIndex);
    super.initState();
    tabList = [Text("??????"), Text("??????"), Text("??????"), Text("?????? ")];
    if (AppConfig.needShowTraining) {
      tabList.insert(1, Text("??????"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
          height: 48,
          width: ScreenUtil.instance.width,
          color: AppColor.mainBlack,
          child: Custom.TabBar(
            controller: controller,
            tabs: tabList,
            labelStyle: TextStyle(fontSize: 17.5),
            labelColor: AppColor.white,
            unselectedLabelStyle: TextStyle(fontSize: 15.5),
            indicator: const RoundUnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: AppColor.mainYellow,
              ),
              // insets: EdgeInsets.only(bottom: 0),
              wantWidth: 16,
            ),
          ),
        ),
        Container(
          height: ScreenUtil.instance.height - CustomAppBar.appBarHeight - 48 - ScreenUtil.instance.statusBarHeight,
          child: TabBarView(
            controller: controller,
            physics: ClampingScrollPhysics(),
            allowImplicitScrolling: false,
            children: [
              SearchComplex(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  controller: controller,
                  textController: context.watch<SearchEnterNotifier>().textController),
              if (AppConfig.needShowTraining)
                SearchCourse(
                    keyWord: context.watch<SearchEnterNotifier>().enterText,
                    focusNode: widget.focusNode,
                    controller: controller,
                    textController: context.watch<SearchEnterNotifier>().textController),
              SearchTopic(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  controller: controller,
                  textController: context.watch<SearchEnterNotifier>().textController),
              SearchFeed(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  controller: controller,
                  textController: context.watch<SearchEnterNotifier>().textController),
              // ),
              SearchUser(
                text: context.watch<SearchEnterNotifier>().enterText,
                width: ScreenUtil.instance.screenWidthDp,
                controller: controller,
                textController: context.watch<SearchEnterNotifier>().textController,
                focusNode: widget.focusNode,
              ),
              // RecommendPage()
            ],
          ),
        )
      ],
    ));
  }
}

// ??????????????????????????????
class SearchEnterNotifier extends ChangeNotifier {
  SearchEnterNotifier({this.enterText, this.currentTimestamp = 0, this.textController});

  // ????????????
  String enterText;

  // ???????????????
  int currentTimestamp;

  //?????????
  TextEditingController textController;

  // tabBar??????

  changeCallback(String str) {
    this.enterText = str;
    notifyListeners();
  }

  setCurrentTimestamp(int timestamp) {
    this.currentTimestamp = timestamp;
  }

  EditTextController(TextEditingController controller) {
    this.textController = controller;
    notifyListeners();
  }
}
