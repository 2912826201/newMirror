import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

// 搜索页
class SearchPage extends StatelessWidget {
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
                      SearchHeader(),
                      context.watch<SearchEnterNotifier>().enterText.length > 0 ?  SearchTabBarView() :
                      SearchMiddleView(),
                    ],
                  );
                })));
  }
}
 // // 搜索头部布局
class  SearchHeader extends StatefulWidget {
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
class SearchMiddleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 最近搜索标题栏
        searchTitleBar(context),
        historyRecord(context),
        HotCourseTitleBar(),
        HotCourseContent(),
        HotTopicTitleBar(),
        HotTopicContent()
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
            "热门推荐",
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
      color: AppColor.mainRed,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container();
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
      color: AppColor.mainRed,
    );
  }

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
      width: ScreenUtil.instance.screenWidthDp,
      height: 114,
      color: AppColor.mainRed,
    );
  }
}

// 搜索页TabBarView
class SearchTabBarView extends StatefulWidget {
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
              Container(
                color: Colors.blue,
                child: Center(
                  child: Text("话题"),
                ),
              ),
              Container(
                color: Colors.lime,
                child: Center(
                  child: Text("动态"),
                ),
              ),
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
  SearchEnterNotifier({this.enterText});

  String enterText;

  changeCallback(String str) {
    this.enterText = str;
    notifyListeners();
  }
}
