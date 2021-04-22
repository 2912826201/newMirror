import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/search_history_db_helper.dart';
import 'package:mirror/data/dto/search_history_dto.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/search/sub_page/search_complex.dart';
import 'package:mirror/page/search/sub_page/search_course.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/page/search/sub_page/search_topic.dart';
import 'package:mirror/page/search/sub_page/search_user.dart';
import 'package:mirror/page/training/test_appvar.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/Input_method_rules/input_formatter.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

// 搜索页
class SearchPage extends StatelessWidget {
  final defaultIndex;

  SearchPage({Key key, this.defaultIndex = 0});

  // 输入框焦点控制器
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("搜索页");
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
            color: AppColor.white,
            child: ChangeNotifierProvider(
                create: (_) => SearchEnterNotifier(enterText: ""),
                builder: (context, _) {
                  return Column(
                    children: [
                      // 头部
                      SearchHeader(
                        focusNode: focusNode,
                      ),
                      context.watch<SearchEnterNotifier>().enterText.length > 0
                          ? SearchTabBarView(
                              focusNode: focusNode,
                              defaultIndex: defaultIndex,
                            )
                          : SearchMiddleView(),
                    ],
                  );
                })));
  }
}

// // 搜索头部布局
class SearchHeader extends StatefulWidget {
  final FocusNode focusNode;

  SearchHeader({Key key, this.focusNode}) : super(key: key);

  @override
  _SearchHeaderState createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  TextEditingController controller = TextEditingController();

  ///记录上次结果
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
      color: AppColor.white,
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
            color: AppColor.bgWhite.withOpacity(0.65),
            width: ScreenUtil.instance.screenWidthDp - 32 - 32 - 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 9,
                ),
                AppIcon.getAppIcon(AppIcon.input_search, 24),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        SearchHistoryDBHelper().insertSearchHistory(context.read<ProfileNotifier>().profile.uid, text);
                      }
                    },
                    decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                        hintText: '搜索用户、话题、课程、动态',
                        border: InputBorder.none),
                    inputFormatters: inputFormatters == null ? [_formatter] : (inputFormatters..add(_formatter)),
                    // inputFormatters: [
                    //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
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
                      print("清空数据");
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
          CustomAppBarTextButton("取消", AppColor.textPrimary1, () {
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

// 搜索页中间默认布局
class SearchMiddleView extends StatefulWidget {
  @override
  SearchMiddleViewState createState() => SearchMiddleViewState();
}

class SearchMiddleViewState extends State<SearchMiddleView> {
  List<TopicDtoModel> topicList = [];
  List<SearchHistoryDto> searchHistoryList = [];
  List<LiveVideoModel> liveVideoList = [];

  @override
  void initState() {
    // 合并请求
    Future.wait([
      // 请求推荐话题接口
      getRecommendTopic(size: 20),
      // 请求历史记录
      SearchHistoryDBHelper().querySearchHistory(context.read<ProfileNotifier>().profile.uid),
      recommendCourse(),
      // 请求热门课程
    ]).then((results) {
      print("历史记录（（（（（（（））））））$searchHistoryList");
      if (results[0] != null) {
        DataResponseModel model = results[0];
        if (model != null && model.list.isNotEmpty) {
          model.list.forEach((v) {
            topicList.add(TopicDtoModel.fromJson(v));
          });
        }
      }
      if (context.read<TokenNotifier>().isLoggedIn) {
        searchHistoryList = results[1];
      }
      List<LiveVideoModel> liveList = [];
      if (results[2] != null) {
        liveList = results[2];
        if (liveList.isNotEmpty) {
          liveVideoList.addAll(liveList);
        }
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      print("报错了");
      print(e);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("最近搜索历史 记录");
    return Column(
      children: [
        // 最近搜索标题栏
        searchHistoryList.isNotEmpty ? searchTitleBar(context) : Container(),
        searchHistoryList.isNotEmpty ? historyRecord(context) : Container(),
        liveVideoList.isNotEmpty ? HotCourseTitleBar() : Container(),
        liveVideoList.isNotEmpty ? HotCourseContent() : Container(),
        topicList.isNotEmpty ? HotTopicTitleBar() : Container(),
        topicList.isNotEmpty ? HotTopicContent() : Container(),
      ],
    );
  }

// 最近搜索标题栏
  searchTitleBar(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "最近搜索",
            style: AppStyle.textMedium15,
          ),
          const Spacer(),
          AppIconButton(
            iconSize: 18,
            svgName: AppIcon.trash_bucket,
            onTap: () {
              SearchHistoryDBHelper().clearSearchHistory(context.read<ProfileNotifier>().profile.uid);
              setState(() {
                searchHistoryList.clear();
              });
            },
          ),
        ],
      ),
    );
  }

// 历史记录Item间距
  historyRecordItemSpacing(int count, int index) {
    if (count > 10 && index == 9) {
      return 16.0;
    } else if (count < 10 && index == count - 1) {
      return 16.0;
    } else {
      return 0.0;
    }
  }

// 历史记录
  historyRecord(BuildContext context) {
    return Container(
      height: 23,
      // color: AppColor.mainRed,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: searchHistoryList.length > 10 ? 10 : searchHistoryList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.read<SearchEnterNotifier>().changeCallback(searchHistoryList[index].word);
                context.read<SearchEnterNotifier>().textController.text = searchHistoryList[index].word;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: AppColor.textHint.withOpacity(0.24),
                    borderRadius: const BorderRadius.all(Radius.circular(3))),
                margin: EdgeInsets.only(left: 16, right: historyRecordItemSpacing(searchHistoryList.length, index)),
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 1),
                alignment: const Alignment(0, 0),
                child: Center(child: Text(searchHistoryList[index].word)),
              ),
            );
          }),
    );
  }

// 热门课程标题栏
  HotCourseTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // 左居中对齐
        alignment: const Alignment(-1, 0),
        child: const Text(
          "热门课程",
          style: AppStyle.textMedium15,
        ));
  }

// 热面课程推荐类容
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
        //在direction: Axis.horizontal的时候指左右两个Widget的间距,在direction: Axis.vertical的时候指上下两个widget的间距
        // runSpacing: 16.0,//在direction: Axis.horizontal的时候指上下两个Widget的间距,在direction: Axis.vertical的时候指左右两个widget的间距
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        textDirection: TextDirection.ltr,
        children: HotCourseContentItem(),
      ),
    );
  }

  // 热门课程推荐类容Item
  List<Widget> HotCourseContentItem() => List.generate(liveVideoList.length > 4 ? 4 : liveVideoList.length, (index) {
        return GestureDetector(
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
                  style: index == 3 ? AppStyle.textSecondaryMedium14 : AppStyle.redMedium14,
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
                          style: AppStyle.textRegular14, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(
                        liveVideoList[index].description,
                        style: AppStyle.textSecondaryRegular12,
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

// 热门话题标题
  HotTopicTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // 左居中对齐
        alignment: const Alignment(-1, 0),
        child: const Text(
          "热门话题",
          style: AppStyle.textMedium15,
        ));
  }

// 热门话题推荐类容
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
              TopicDtoModel topicModel = await getTopicInfo(topicId: topicList[index].id);
              FocusScope.of(context).requestFocus(FocusNode());
              AppRouter.navigateToTopicDetailPage(context, topicModel);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      // 渐变色
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColor.bgWhite,
                          Colors.white,
                        ],
                      ),
                      // 设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: AppColor.textHint.withOpacity(0.3),
                            offset: Offset(0.0, 1.0), //阴影xy轴偏移量
                            blurRadius: 1.0, //阴影模糊程度
                            spreadRadius: 2.6 //阴影扩散程度
                            )
                      ]),
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
                        child: AppIcon.getAppIcon(AppIcon.topic, 24, containerHeight: 32, containerWidth: 32),
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
                              style: AppStyle.textRegular15,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              "${topicList[index].feedCount}条动态",
                              style: AppStyle.textSecondaryRegular12,
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
                            //设置背景图片
                            decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                            ),
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              height: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                              width: (ScreenUtil.instance.screenWidthDp - 38) * 0.42 * 0.53,
                              // 调整磁盘缓存中图像大小
                              maxHeightDiskCache: 250,
                              maxWidthDiskCache: 250,
                              imageUrl: topicList[index].pics[indexs] != null ? FileUtil.getMediumImage(topicList[index].pics[indexs]) : "",
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

// 搜索页TabBarView
class SearchTabBarView extends StatefulWidget {
  SearchTabBarView({Key key, this.focusNode, this.defaultIndex}) : super(key: key);
  FocusNode focusNode;
  final defaultIndex;

  @override
  SearchTabBarViewState createState() => SearchTabBarViewState();
}

class SearchTabBarViewState extends State<SearchTabBarView> with SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = TabController(length: 5, vsync: this, initialIndex: widget.defaultIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
          height: 48,
          width: ScreenUtil.instance.width,
          child: TabBar(
            controller: controller,
            tabs: const [Text("综合"), Text("课程"), Text("话题"), Text("动态"), Text("用户 ")],
            labelStyle: TextStyle(fontSize: 18),
            labelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontSize: 16),
            indicator: const RoundUnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: Color.fromRGBO(253, 137, 140, 1),
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
            children: [
              SearchComplex(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  controller: controller,
                  textController: context.watch<SearchEnterNotifier>().textController),
              SearchCourse(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  textController: context.watch<SearchEnterNotifier>().textController),
              SearchTopic(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  textController: context.watch<SearchEnterNotifier>().textController),
              SearchFeed(
                  keyWord: context.watch<SearchEnterNotifier>().enterText,
                  focusNode: widget.focusNode,
                  textController: context.watch<SearchEnterNotifier>().textController),
              // ),
              SearchUser(
                  text: context.watch<SearchEnterNotifier>().enterText,
                  width: ScreenUtil.instance.screenWidthDp,
                  textController: context.watch<SearchEnterNotifier>().textController),
              // RecommendPage()
            ],
          ),
        )
      ],
    ));
  }
}

// 输入框输入文字的监听
class SearchEnterNotifier extends ChangeNotifier {
  SearchEnterNotifier({this.enterText, this.currentTimestamp = 0, this.textController});

  // 输入文字
  String enterText;

  // 当前时间戳
  int currentTimestamp;

  //控制器
  TextEditingController textController;

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
