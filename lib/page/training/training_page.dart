import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';

import '../test_page.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<TrainingPage> with AutomaticKeepAliveClientMixin {
  double _screenWidth = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: null,
            backgroundColor: AppColor.white,
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
        body: _buildTopView());
  }

  //我的课程列表上方的所有部分
  Widget _buildTopView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [_buildBanner(), _buildConnection(), _buildEquipment(), _buildLive(), _buildCourseTitle()],
      ),
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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TestPage();
              }));
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
          Container(
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
          )
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
          Container(
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
                    Text(
                      "iF智能魔镜-CC10",
                      style: AppStyle.textMedium15,
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
          )
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
            child: Stack(
              children: [
                Container(
                  color: AppColor.textPrimary3,
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
                            "17:00-18:00",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white),
                          )
                        ],
                      ),
                      Spacer(),
                      Text(
                        "帕梅拉15分钟复古有氧舞蹈操·新...",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.white),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            "减脂·90Kcal",
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.white.withOpacity(0.85)),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "减脂·90Kcal",
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.white.withOpacity(0.85)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            "我的课程",
            style: AppStyle.textMedium16,
          )),
          Row(
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
          )
        ],
      ),
    );
  }
}
