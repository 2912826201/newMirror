import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<TrainingPage> with AutomaticKeepAliveClientMixin {
  bool _machineConnected = true;
  List<int> _courseList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  double _screenWidth = 0.0;

  List<LiveModel> _liveList;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
    getLatestLive().then((result) {
      _liveList = result;
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          leading: null,
          backgroundColor: AppColor.white,
          brightness: Brightness.light,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "训练",
                style: AppStyle.textMedium18,
              ),
            ],
          )),
      body: Stack(
        children: [
          ScrollConfiguration(
              behavior: NoBlueEffectBehavior(),
              child: ListView.builder(
                  //有个头部 有个尾部
                  itemCount: _courseList.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTopView();
                    } else if (index == _courseList.length + 1) {
                      return SizedBox(
                        height: 40,
                      );
                    } else {
                      return _buildCourseItem(index);
                    }
                  })),
          Positioned(
            left: 0,
            bottom: 0,
            child: _buildInfoBar(),
          ),
        ],
      ),
    );
  }

  //我的课程列表上方的所有部分
  Widget _buildTopView() {
    return Column(
      children: [_buildBanner(), _buildConnection(), _buildEquipment(), _buildLive(), _buildCourseTitle()],
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        height: _screenWidth * 140 / 375,
        color: AppColor.bgBlack,
        child: Center(
          child: RaisedButton(
            onPressed: () {
              AppRouter.navigateToTestPage(context);
            },
            child: Text("去测试页"),
          ),
        ),
      ),
    );
  }

  Widget _buildConnection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                "连接设备",
                style: AppStyle.textMedium16,
              ))
            ],
          ),
          GestureDetector(
              onTap: () {
                AppRouter.navigateToScanCodePage(context);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: 36,
                decoration: BoxDecoration(
                    border: Border.all(
                  color: AppColor.textPrimary1,
                  width: 1,
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //TODO 之后替换图标
                    Icon(
                      Icons.link,
                      size: 16,
                      color: AppColor.black,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "连接设备",
                      style: AppStyle.textRegular14,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildEquipment() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                "设备",
                style: AppStyle.textMedium16,
              ))
            ],
          ),
          //TODO 暂时先做个样式 实际可能有多个设备
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AppRouter.navigateToMachineRemoteController(context);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              height: 64,
              child: Row(
                children: [
                  Container(
                    color: AppColor.mainBlue,
                    width: 100,
                    height: 64,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "iF智能魔镜-CC10",
                            style: AppStyle.textMedium15,
                          ),
                          SizedBox(
                            width: 4.5,
                          ),
                          Icon(
                            Icons.book,
                            color: AppColor.textPrimary2,
                            size: 18,
                          ),
                          SizedBox(
                            width: 2.5,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 12,
                            width: 12,
                            child: Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _machineConnected ? AppColor.lightGreen : AppColor.mainRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "点击可操控终端设备",
                              style: AppStyle.textSecondaryRegular12,
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLive() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                "近期直播",
                style: AppStyle.textMedium16,
              )),
              GestureDetector(
                onTap: () {
                  AppRouter.navigateToLiveBroadcast(context);
                },
                child: Row(
                  children: [
                    Text(
                      "全部",
                      style: AppStyle.textPrimary3Regular14,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    //TODO 之后替换图标
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColor.textPrimary3,
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: _screenWidth * 151 / 343,
            child: _liveList != null && _liveList.length > 0
                ? Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _liveList.first.picUrl,
                        width: _screenWidth,
                        height: _screenWidth * 151 / 343,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 16,
                                  width: 44,
                                  color: AppColor.mainRed,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "${_liveList.first.startTime}-${_liveList.first.endTime}",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white),
                                )
                              ],
                            ),
                            Spacer(),
                            Text(
                              "${_liveList.first.coursewareDto.name}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.white),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${_liveList.first.coursewareDto.targetDto.name}·${_liveList.first.coursewareDto.calories}Kcal",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.white.withOpacity(0.85)),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "${_liveList.first.coachDto.nickName}",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.white.withOpacity(0.85)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            "我的课程",
            style: AppStyle.textMedium16,
          )),
          GestureDetector(
            onTap: () {
              AppRouter.navigateToVideoCourseList(context);
            },
            child: Row(
              children: [
                Text(
                  "添加课程",
                  style: AppStyle.textPrimary3Regular14,
                ),
                SizedBox(
                  width: 4,
                ),
                //TODO 之后替换图标
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: AppColor.textPrimary1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCourseItem(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 90,
        color: Colors.tealAccent,
      ),
    );
  }

  Widget _buildInfoBar() {
    return GestureDetector(
      onTap: () {
        print("进入遥控页");
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 40,
        width: ScreenUtil.instance.screenWidthDp - 32,
        color: AppColor.textPrimary1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                print("关闭信息条");
              },
              child: Container(
                alignment: Alignment.center,
                height: 36,
                width: 36,
                child: Icon(
                  Icons.highlight_off,
                  color: AppColor.white,
                  size: 16,
                ),
              ),
            ),
            Expanded(
                child: Text(
              "继续播放：普拉提产后恢复系列高速燃脂普拉提产后恢复系列高速燃脂",
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColor.white, fontSize: 14),
            )),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }
}
