import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:provider/provider.dart';

/// machine_setting_page
/// Created by yangjiayi on 2021/1/4.

class MachineSettingPage extends StatefulWidget {
  @override
  _MachineSettingState createState() => _MachineSettingState();
}

class _MachineSettingState extends State<MachineSettingPage> {
  bool _showOrderedLive = true;
  bool _showVipPlan = true;
  bool _showAIRecommend = true;
  bool _enableAlarm = true;
  bool _showFriendsRank = false;
  bool _showBreakfastRecommend = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: CustomAppBar(
          titleString: "终端设置",
        ),
        body: Consumer<MachineNotifier>(
          builder: (context, notifier, child) {
            if (notifier.machine == null) {
              AppRouter.popToBeforeMachineController(context);
              return Container();
            } else {
              return _buildSettingList();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingList() {
    return Column(
      children: [
        _buildDoubleLinesItem("预约直播展示", "关闭后，终端待机页将不展示当日预约直播信息", _showOrderedLive, (isChecked) {
          setState(() {
            _showOrderedLive = isChecked;
          });
        }),
        Container(
          height: 12,
          color: AppColor.bgWhite,
        ),
        _buildDoubleLinesItem("vip定制计划展示", "关闭后，终端待机页将不展示VIP定制计划内容", _showVipPlan, (isChecked) {
          setState(() {
            _showVipPlan = isChecked;
          });
        }),
        Container(
          height: 0.5,
          color: AppColor.bgWhite,
        ),
        _buildDoubleLinesItem("智能定制推荐", "关闭后，终端待机页将不展示每日推荐课程", _showAIRecommend, (isChecked) {
          setState(() {
            _showAIRecommend = isChecked;
          });
        }),
        Container(
          height: 0.5,
          color: AppColor.bgWhite,
        ),
        _buildDoubleLinesItem("闹钟提醒", "关闭后，已预约的课程开播将不会收到提醒", _enableAlarm, (isChecked) {
          setState(() {
            _enableAlarm = isChecked;
          });
        }),
        Container(
          height: 12,
          color: AppColor.bgWhite,
        ),
        _buildSingleLineItem("好友排名", _showFriendsRank, (isChecked) {
          setState(() {
            _showFriendsRank = isChecked;
          });
        }),
        Container(
          height: 0.5,
          color: AppColor.bgWhite,
        ),
        _buildSingleLineItem("每日早餐推荐", _showBreakfastRecommend, (isChecked) {
          setState(() {
            _showBreakfastRecommend = isChecked;
          });
        }),
        Container(
          height: 0.5,
          color: AppColor.bgWhite,
        ),
      ],
    );
  }

  Widget _buildDoubleLinesItem(String title, String hint, bool isChecked, Function(bool isChecked) onCheckChanged) {
    return Container(
      height: 87,
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyle.textRegular16,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                hint,
                style: AppStyle.textSecondaryRegular12,
              ),
            ],
          )),
          Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(
              activeColor: AppColor.mainRed,
              trackColor: AppColor.textHint,
              value: isChecked,
              onChanged: onCheckChanged,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSingleLineItem(String title, bool isChecked, Function(bool isChecked) onCheckChanged) {
    return Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppStyle.textRegular16,
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(
              activeColor: AppColor.mainRed,
              trackColor: AppColor.textHint,
              value: isChecked,
              onChanged: onCheckChanged,
            ),
          )
        ],
      ),
    );
  }
}
