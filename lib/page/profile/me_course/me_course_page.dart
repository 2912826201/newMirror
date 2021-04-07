import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///我的课程
class MeCoursePage extends StatefulWidget {
  @override
  _MeCoursePageState createState() => _MeCoursePageState();
}

class _MeCoursePageState extends State<MeCoursePage> {
  bool _isVideoCourseRequesting = false;
  int _isVideoCourseLastTime;
  int _isVideoCoursePage=0;
  int _isVideoCourseTotalCount = 0;
  bool _videoCourseHasNext = false;
  List<LiveVideoModel> _videoCourseList = [];
  RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _isVideoCoursePage=1;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "我的课程",
      ),
      body: getBodyUi(),
    );
  }

  //主体
  Widget getBodyUi() {
    return Container(
      color: AppColor.white,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        footer:  SmartRefresherHeadFooter.init().getFooter(),
        header: SmartRefresherHeadFooter.init().getHeader(),
        onRefresh: _onRefresh,
        onLoading: loadData,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            getTopDownloadCourseBtn(),
            getLineView(12),
            getMeLearnCourseTitleUi(),
            judgeShowUi(),
          ],
        ),
      ),
    );
  }

  //判断显示什么ui
  Widget judgeShowUi() {
    if (_videoCourseList.length < 1) {
      return noDateUi();
    } else {
      return getListView();
    }
  }

  Widget getListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((content, index) {
        return Material(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            color: AppColor.white,
            child: new InkWell(
              child: getItem(_videoCourseList[index]),
              splashColor: AppColor.textHint,
              onTap: () {
                AppRouter.navigateToVideoDetail(context, _videoCourseList[index].id,callback: (result)=>_onRefresh());
              },
            ));
      }, childCount: _videoCourseList.length),
    );
  }

  //每一个item
  Widget getItem(LiveVideoModel videoModel) {
    return Container(
      color: AppColor.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
          ),
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                child: Text(
                  videoModel.title,
                  style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              SizedBox(width: 15),
              Text(
                "总时长${videoModel.times ~/ 1000 ~/ 60}分钟  ${IntegerUtil.formationCalorie(videoModel.calories)}",
                style: TextStyle(fontSize: 12, color: AppColor.textPrimary2),
              ),
            ],
          ),
          SizedBox(
            height: 6,
          ),
          Text(
              getLastLearnTimeString(videoModel.lastPracticeTime),
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          SizedBox(
            height: 18,
          ),
          Container(
            color: AppColor.bgWhite,
            height: 1,
          ),
        ],
      ),
    );
  }

  String getLastLearnTimeString(int lastPracticeTime){
    if(lastPracticeTime==null||lastPracticeTime<1){
      return "尚未学习";
    }
    return "上次学习${DateUtil.getDateDayString(DateUtil.getDateTimeByMs(lastPracticeTime))}";
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
            Text("您还没有收藏过任何课程呢，快去添加吧！", style: TextStyle(fontSize: 14, color: AppColor.textSecondary)),
          ],
        ),
      ),
    );
  }

  //进入我收藏的课程ui
  Widget getMeLearnCourseTitleUi() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColor.transparent,
        height: 75.0,
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
                  Text("我收藏的课程",
                      style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.chevron_right, size: 16, color: AppColor.textHint),
                      SizedBox(width: 6),
                      Text("共$_isVideoCourseTotalCount节课程", style: TextStyle(fontSize: 16, color: AppColor
                          .textSecondary)),
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

  _onRefresh() {
    _isVideoCourseLastTime = null;
    _isVideoCoursePage=1;
    loadData(isRefresh:true);
  }

  void loadData({bool isRefresh=false}) {
    _isVideoCourseRequesting = true;
    if(_isVideoCoursePage>1&&_isVideoCourseLastTime==null){
      _refreshController.loadNoData();
      _refreshController.refreshCompleted();
      return;
    }
    getMyCourse(_isVideoCoursePage,20, lastTime: _isVideoCourseLastTime).then((result) {
      if(isRefresh){
        _videoCourseList.clear();
      }
      _isVideoCourseRequesting = false;
      if (result != null) {
        _isVideoCoursePage++;
        _videoCourseHasNext = result.hasNext == 1;
        _isVideoCourseLastTime = result.lastTime;
        _isVideoCourseTotalCount = result.totalCount;
        _videoCourseList.addAll(result.list);
        _refreshController.loadComplete();
      }else{
        _refreshController.loadNoData();
      }
      if (mounted) {
        _refreshController.refreshCompleted();
        setState(() {});
      }
    }).catchError((error) {
      _refreshController.loadNoData();
      _refreshController.refreshCompleted();
      _isVideoCourseRequesting = false;
    });
  }
}
