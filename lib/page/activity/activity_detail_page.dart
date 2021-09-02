import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/equipment_data.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/user_avatar_image.dart';

import 'detail_item/detail_start_time_ui.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;

  ActivityDetailPage({@required this.activityId});

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  ActivityModel activityModel;
  LoadingStatus loadingStatus;

  _ActivityDetailPageState({this.activityModel});

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
      return _getDetailWidget();
    }
  }

  Widget _getDetailWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          //顶部图片
          _getTopImage(),
          SizedBox(height: 12),

          //开始时间
          DetailStartTimeUi(),
          SizedBox(height: 21),

          //活动名称
          Text("活动名称：${activityModel.title ?? ""}", style: AppStyle.whiteRegular16),
          SizedBox(height: 10),

          //活动名称
          Text("活动器材：${EquipmentData.init().getString(activityModel.equipment)}", style: AppStyle.text1Regular14),
          SizedBox(height: 12),

          //活动地址
          Text("${activityModel.address}", style: AppStyle.text1Regular14),
          SizedBox(height: 38),
        ],
      ),
    );
  }

  //顶部图片
  Widget _getTopImage() {
    return CachedNetworkImage(
      height: ScreenUtil.instance.width / (375 / 197),
      width: ScreenUtil.instance.width,
      imageUrl: activityModel.pic == null ? "" : FileUtil.getImageSlim(activityModel.pic),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.imageBgGrey,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColor.imageBgGrey,
      ),
    );
  }

  Widget _getUserUI() {
    if (activityModel.members == null || activityModel.members.length < 1) {
      return Container();
    }
    return Container(
      width: ScreenUtil.instance.width,
      child: Column(
        children: [
          Container(
            width: ScreenUtil.instance.width,
            height: 45,
            child: Row(
              children: [
                Text("报名队员", style: AppStyle.whiteRegular16),
                Text("共${activityModel.members.length ?? 0}人", style: AppStyle.whiteRegular14),
                Spacer(),
                GestureDetector(
                  child: Container(
                    color: AppColor.mainYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    child: Text("群聊", style: AppStyle.textRegular12),
                  ),
                  onTap: () {
                    print("进入群聊");
                  },
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: ListView.separated(
                itemCount: activityModel.members.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                      width: 6.0,
                      color: AppColor.mainBlack,
                    ),
                itemBuilder: (context, index) {
                  return Container(
                    width: 47,
                    height: 100.0 - 12.0 - 16.0,
                    child: Column(
                      children: [
                        UserAvatarImageUtil.init().getUserImageWidget(
                            activityModel.members[index].avatarUri, activityModel.members[index].uid.toString(), 45),
                        SizedBox(height: 6),
                        Text(activityModel.members[index].nickName, style: AppStyle.text1Regular12),
                      ],
                    ),
                  );
                }),
          ),
        ],
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
