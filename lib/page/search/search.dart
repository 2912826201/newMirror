import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/page/search/sub_page/search_topic.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

// 搜索页
class SearchPage extends StatelessWidget {
  // 输入框焦点控制器
  FocusNode focusNode = new FocusNode();

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
                            )
                          : SearchMiddleView(),
                    ],
                  );
                })));
  }
}

// // 搜索头部布局
class SearchHeader extends StatefulWidget {
  FocusNode focusNode;

  SearchHeader({Key key, this.focusNode}) : super(key: key);

  @override
  SearchHeaderState createState() => SearchHeaderState();
}

class SearchHeaderState extends State<SearchHeader> {
  final controller = TextEditingController();

  // 输入框旧值
  String oldValue;

  // 输入框新值
  String newValue;

  @override
  void initState() {
    controller.addListener(() {
      newValue = controller.text;
      if (newValue == oldValue) {
        print("点击了搜索按钮");
        return;
      }
      context.read<SearchEnterNotifier>().changeCallback(controller.text);
      oldValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      margin: EdgeInsets.only(
        top: ScreenUtil.instance.statusBarHeight,
      ),
      height: 44.0,
      width: ScreenUtil.instance.screenWidthDp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            height: 32,
            color: AppColor.bgWhite.withOpacity(0.65),
            width: ScreenUtil.instance.screenWidthDp - 32 - 32 - 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                Image.asset(
                  "images/resource/2.0x/search_icon_gray@2x.png",
                  width: 21,
                  height: 21,
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controller,
                      focusNode: widget.focusNode,
                      textInputAction: TextInputAction.search,
                      decoration: new InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                          hintText: '搜索结果的样式',
                          border: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: new Icon(Icons.cancel),
                  color: Color.fromRGBO(220, 221, 224, 1),
                  iconSize: 18.0,
                  onPressed: () {
                    print("清空数据");
                    controller.clear();
                    print(controller.text);
                    context.read<SearchEnterNotifier>().changeCallback("");
                  },
                ),
              ],
            ),
          ),
          Spacer(),
          TextBtn(
            title: "取消",
            fontsize: 16,
            textColor: AppColor.textPrimary1,
            width: 32,
            height: 22.5,
            onTap: () {
              Navigator.of(context).pop(true);
            },
          ),
          SizedBox(
            width: 16,
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

  @override
  void initState() {
    requestRecommendTopicIterface();
    super.initState();
  }

  // 请求推荐话题接口
  requestRecommendTopicIterface() async {
    topicList = await getRecommendTopic(size: 20);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 最近搜索标题栏
        searchTitleBar(context),
        historyRecord(context),
        HotCourseTitleBar(),
        HotCourseContent(),
        topicList.isNotEmpty ? HotTopicTitleBar() : Container(),
        topicList.isNotEmpty ? HotTopicContent() : Container(),
      ],
    );
  }

// 最近搜索标题栏
  searchTitleBar(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      margin: EdgeInsets.only(left: 16, right: 16, top: 12),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "最近搜索",
            style: AppStyle.textMedium15,
          ),
          Spacer(),
          MyIconBtn(
            width: 18,
            height: 18,
            iconSting: "images/resource/2.0x/delete_icon_black@2x.png",
            onPressed: () {
              print("清空历史记录");
            },
          )
        ],
      ),
    );
  }

// 历史记录
  historyRecord(BuildContext context) {
    return Container(
      height: 23,
      // color: AppColor.mainRed,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              color: AppColor.textSecondary.withOpacity(0.3),
              margin: EdgeInsets.only(left: 16),
              padding: EdgeInsets.only(left: 8,top: 3,right: 8,bottom: 3),
              child:Text("瑜伽")
            );
          }),
    );
  }

// 热门课程标题栏
  HotCourseTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // 左居中对齐
        alignment: Alignment(-1, 0),
        child: Text(
          "热门课程",
          style: AppStyle.textMedium15,
        ));
  }

// 热面课程推荐类容
  HotCourseContent() {
    return Container(
      height: 96,
      width: ScreenUtil.instance.screenWidthDp,
      margin: EdgeInsets.only(
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
  List<Widget> HotCourseContentItem() => List.generate(4, (index) {
        return Container(
          height: 48,
          width: (ScreenUtil.instance.width - 48) / 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: index == 3 ? AppStyle.textSecondaryMedium14 : AppStyle.textMediumRed14,
              ),
              Spacer(),
              Container(
                height: 38,
                width: ((ScreenUtil.instance.width - 48) / 2) - 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("胸背训练教学动作", style: AppStyle.textRegular14, maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "描述信息描述信息描述是男是女你说呢",
                      style: AppStyle.textSecondaryRegular12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 22,
              )
            ],
          ),
        );
      });

// 热门话题标题
  HotTopicTitleBar() {
    return Container(
        width: ScreenUtil.instance.screenWidthDp,
        margin: EdgeInsets.only(left: 16, right: 16, top: 16),
        height: 48,
        // 左居中对齐
        alignment: Alignment(-1, 0),
        child: Text(
          "热门话题",
          style: AppStyle.textMedium15,
        ));
  }

// 热门话题推荐类容
  HotTopicContent() {
    return Container(
      height: (ScreenUtil.instance.screenWidthDp - 38) * 0.43,
      width: ScreenUtil.instance.screenWidthDp,
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Container(
              width: (ScreenUtil.instance.screenWidthDp - 42) * 0.43,
              height: (ScreenUtil.instance.screenWidthDp - 38) * 0.43,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.all(Radius.circular(2)),
              //  阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
              // boxShadow: [
              //   BoxShadow(color: AppColor.textSecondary.withOpacity(0.4), blurRadius: 1.0, spreadRadius: 1.0),
              // ],
              //   border:  Border(  bottom: BorderSide(color: AppColor.textSecondary.withOpacity(0.4), width: 2)), // 边色与边宽度
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColor.bgWhite,
                    Colors.white,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    "images/test/674_288.png",
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 9),
                    height: 39,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.import_contacts_sharp,
                            size: 32,
                          ),
                          // width: 32,
                          // height: 32,
                          // color: Colors.green,
                        ),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "#${topicList[index].name}",
                                style: AppStyle.textRegular15,
                              ),
                              Spacer(),
                              Text(
                                "${topicList[index].feedCount}条动态",
                                style: AppStyle.textSecondaryRegular12,
                              ),
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 28,
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, top: 63, right: 10),
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
                          child: ClipRRect(
                          //圆角图片
                          borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              topicList[index].pics[indexs],
                              fit: BoxFit.cover,
                            )),
                          );
                        }),
                  ),
                ],
              ),
              //
            ),
          );
        },
        itemCount: topicList.length > 5 ? 5 : topicList.length,
        itemWidth: ScreenUtil.instance.screenWidthDp - 38,
        layout: SwiperLayout.STACK,
      ),
    );
  }
}

// 搜索页TabBarView
class SearchTabBarView extends StatefulWidget {
  SearchTabBarView({Key key, this.focusNode}) : super(key: key);
  FocusNode focusNode;

  @override
  SearchTabBarViewState createState() => SearchTabBarViewState();
}

class SearchTabBarViewState extends State<SearchTabBarView> with SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController controller;

  @override
  void initState() {
    controller = TabController(length: 5, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
          height: 48,
          width: ScreenUtil.instance.screenWidthDp,
          child: TabBar(
            controller: controller,
            tabs: [Text("综合"), Text("课程"), Text("话题"), Text("动态"), Text("用户 ")],
            labelStyle: TextStyle(fontSize: 18),
            labelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontSize: 16),
            indicator: RoundUnderlineTabIndicator(
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
          height: ScreenUtil.instance.height - 44 - 48 - ScreenUtil.instance.statusBarHeight,
          child: TabBarView(
            controller: controller,
            children: [
              Container(
                color: Colors.redAccent,
                child: Center(
                  child: Text("综合"),
                ),
              ),
              Container(
                color: Colors.orange,
                child: Center(
                  child: Text("课程"),
                ),
              ),
              SearchTopic(
                keyWord: context.watch<SearchEnterNotifier>().enterText,
                focusNode: widget.focusNode,
              ),
              SearchFeed(
                keyWord: context.watch<SearchEnterNotifier>().enterText,
                focusNode: widget.focusNode,
              ),
              // ),
              Container(
                color: Colors.green,
                child: Center(
                  child: Text("用户"),
                ),
              ),
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
  SearchEnterNotifier({this.enterText, this.currentTimestamp = 0});

  // 输入文字
  String enterText;

  // 当前时间戳
  int currentTimestamp;

  changeCallback(String str) {
    this.enterText = str;
    notifyListeners();
  }

  setCurrentTimestamp(int timestamp) {
    this.currentTimestamp = timestamp;
  }
}
