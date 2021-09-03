import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/equipment_data.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/activity/detail_item/detail_member_user_ui.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'detail_item/detail_activity_feed_ui.dart';
import 'detail_item/detail_start_time_ui.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;

  ActivityDetailPage({@required this.activityId});

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  ActivityModel activityModel;

  _ActivityDetailPageState({this.activityModel});

  LoadingStatus loadingStatus;

  GlobalKey<CommonCommentPageState> childKey = GlobalKey();

  //粘合剂控件滚动控制
  ScrollController scrollController = ScrollController();

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  CommentDtoModel fatherComment;
  bool isInteractive = false;
  CommentDtoModel commentDtoModel;

  @override
  void initState() {
    super.initState();
    if (activityModel != null) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    } else if (widget.activityId != null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
      _initData();
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "活动详情",
      ),
      body: Container(
        color: AppColor.mainBlack,
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.width,
        child: _bodyUi(),
      ),
    );
  }

  Widget _bodyUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (loadingStatus == LoadingStatus.STATUS_IDEL) {
      return Center(
        child: GestureDetector(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 224,
                  height: 224,
                  child: Image.asset(
                    "assets/png/default_no_data.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  "暂无活动数据，去看看其他的吧~",
                  style: AppStyle.text1Regular14,
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
          onTap: () {
            if (widget.activityId != null) {
              loadingStatus = LoadingStatus.STATUS_LOADING;
              _initData();
            } else {
              loadingStatus = LoadingStatus.STATUS_IDEL;
            }
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: _getDetailWidget(),
      );
    }
  }

  Widget _getDetailWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //顶部图片
              _getTopImage(),
              SizedBox(height: 12),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //开始时间
                    DetailStartTimeUi(),
                    SizedBox(height: 21),

                    //活动名称
                    Text("活动名称：${activityModel.title ?? ""}", style: AppStyle.whiteRegular16),
                    SizedBox(height: 10),

                    //活动名称
                    Text("活动器材：${EquipmentData.init().getString(activityModel.equipment)}",
                        style: AppStyle.text1Regular14),
                    SizedBox(height: 12),

                    //活动地址
                    Text("${activityModel.address}", style: AppStyle.text1Regular14),
                    SizedBox(height: 38),

                    //报名队员
                    _getMembersUserUI(),

                    //活动动态
                    DetailActivityFeedUi(),
                    SizedBox(height: 18),

                    //活动说明
                    SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.only(top: 26, bottom: 18, right: 10, left: 10),
                        child: Text(activityModel.description, style: AppStyle.text1Regular14),
                      ),
                    ),
                    SizedBox(height: 30),

                    Text("讨论区", style: AppStyle.whiteRegular16),
                    SizedBox(height: 130),

                    _getCourseCommentUi(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 40,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.mainBlack,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 40,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(width: 12),
              Text("活动还未开始，发点动态吧", style: AppStyle.text1Regular14),
              Spacer(),
              Container(
                height: 40,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColor.mainYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("发布动态", style: AppStyle.textRegular15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //顶部图片
  Widget _getTopImage() {
    return CachedNetworkImage(
      height: ScreenUtil.instance.width / (375 / 197),
      width: ScreenUtil.instance.width,
      imageUrl: activityModel.pic == null ? "" : FileUtil.getImageSlim(activityModel.pic),
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Container(
            color: AppColor.imageBgGrey,
          ),
      errorWidget: (context, url, error) =>
          Container(
            color: AppColor.imageBgGrey,
          ),
    );
  }

  //报名队员的ui
  Widget _getMembersUserUI() {
    if (activityModel.members == null || activityModel.members.length < 1) {
      return Container();
    }
    return DetailMemberUserUi(activityModel.members);
  }


  Widget _getCourseCommentUi() {
    return Visibility(
      visible: loadingStatus == LoadingStatus.STATUS_COMPLETED,
      child: CommonCommentPage(
        key: childKey,
        scrollController: scrollController,
        refreshController: _refreshController,
        fatherComment: fatherComment,
        targetId: activityModel.id,
        targetType: 3,
        pageCommentSize: 20,
        pageSubCommentSize: 3,
        isShowHotOrTime: true,
        isInteractiveIn: isInteractive,
        commentDtoModel: commentDtoModel,
        isShowAt: false,
        globalKeyList: [],
        isVideoCoursePage: true,
      ),
    );
  }


  ///初始化数据
  _initData() async {
    activityModel = await getActivityDetailApi(widget.activityId);
    setState(() {
      if (activityModel == null) {
        loadingStatus = LoadingStatus.STATUS_IDEL;
      } else {
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
  }
}
