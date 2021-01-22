import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/route/router.dart';

//我的课程
class MeCoursePage extends StatefulWidget {
  @override
  _MeCoursePageState createState() => _MeCoursePageState();
}

class _MeCoursePageState extends State<MeCoursePage> {
  bool _isVideoCourseRequesting = false;
  int _isVideoCourseLastTime;
  bool _videoCourseHasNext = false;
  List<LiveVideoModel> _videoCourseList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的课程"),
        centerTitle: true,
      ),
      body: getBodyUi(),
    );
  }

  //主体
  Widget getBodyUi() {
    return Container(
      height: 500,
      child: CustomScrollView(
        slivers: [
          getTopDownloadCourseBtn(),
          getLineView(12),
          getMeLearnCourseTitleUi(),
          judgeShowUi(),
        ],
      ),
    );
  }

  //判断显示什么ui
  Widget judgeShowUi() {
    return noDateUi();
  }

  //没有数据的ui
  Widget noDateUi() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Image.asset("images/test/bg.png", width: 224, height: 224, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text("您还没有学习过任何课程呢，快去学习吧！", style: TextStyle(fontSize: 14, color: AppColor.textSecondary)),
          ],
        ),
      ),
    );
  }

  //进入我学过的课程ui
  Widget getMeLearnCourseTitleUi() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColor.transparent,
        height: 69.0,
        margin: const EdgeInsets.only(left: 16, top: 12, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(23.0),
              child: Image.asset("images/test/bg.png", width: 46, height: 46, fit: BoxFit.cover),
            ),
            SizedBox(width: 12),
            Expanded(
                child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("我学过的课程",
                      style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.chevron_right, size: 16, color: AppColor.textHint),
                      SizedBox(width: 6),
                      Text("共0节课程", style: TextStyle(fontSize: 16, color: AppColor.textSecondary)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  //进入下载课程界面的--ui
  Widget getTopDownloadCourseBtn() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        child: Container(
          color: AppColor.transparent,
          height: 69.0,
          margin: const EdgeInsets.only(left: 16, top: 12, right: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(23.0),
                child: Image.asset("images/test/bg.png", width: 46, height: 46, fit: BoxFit.cover),
              ),
              getLineView1(width: 12),
              Text("下载课程", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
              Expanded(child: SizedBox()),
              Icon(Icons.chevron_right, size: 18, color: AppColor.textHint),
            ],
          ),
        ),
        onTap: () {
          AppRouter.navigateToMeDownloadVideoCoursePage(context);
        },
      ),
    );
  }

  //lineView
  Widget getLineView(double height) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColor.bgWhite,
        height: height,
      ),
    );
  }

  //lineView
  Widget getLineView1({double height = 0.0, double width = 0.0}) {
    return Container(
      color: AppColor.bgWhite,
      height: height,
      width: width,
    );
  }

  void loadData() {
    _isVideoCourseRequesting = true;
    if (_isVideoCourseLastTime == null) {
      _videoCourseList.clear();
    }
    getLearnedCourse(10, lastTime: _isVideoCourseLastTime).then((result) {
      _isVideoCourseRequesting = false;
      if (result != null) {
        _videoCourseHasNext = result.hasNext == 1;
        _isVideoCourseLastTime = result.lastTime;
        _videoCourseList.addAll(result.list);
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      _isVideoCourseRequesting = false;
    });
  }
}
