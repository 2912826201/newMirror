import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_evaluate_model.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/user_avatar_image.dart';

import 'grade_start_ui.dart';

class DetailEvaluateUi extends StatefulWidget {
  final ActivityModel activityModel;
  final FocusNode inputEvaluateFocusNode;
  final Function() onRestDataListener;

  DetailEvaluateUi(this.activityModel, this.inputEvaluateFocusNode, this.onRestDataListener);

  @override
  _DetailEvaluateUiState createState() => _DetailEvaluateUiState();
}

class _DetailEvaluateUiState extends State<DetailEvaluateUi> {
  double score = 0.0;
  double avgScore = 4.5;
  TextEditingController controller = TextEditingController();

  List<ActivityEvaluateModel> evaluateList = [];
  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;

  @override
  Widget build(BuildContext context) {
    if (widget.activityModel.isEvaluate == null) {
      widget.activityModel.isEvaluate = false;
    }
    if (widget.activityModel.isSignIn == null) {
      widget.activityModel.isSignIn = false;
    }
    if (widget.activityModel.isCanSignIn == null) {
      widget.activityModel.isCanSignIn = false;
    }
    if (widget.activityModel.status != 3) {
      return Container();
    } else if (widget.activityModel.isSignIn) {
      if (widget.activityModel.isEvaluate) {
        //评价了--展示评价结果
        return haveEvaluate();
      } else {
        //没有评价--展示评价ui
        return noEvaluate();
      }
    } else if (widget.activityModel.isCanSignIn) {
      return Container();
    } else {
      //不能签到--展示评价结果
      return haveEvaluate();
    }
  }

  //有评价的ui
  Widget haveEvaluate() {
    if (evaluateList.length < 1 && loadingStatus == LoadingStatus.STATUS_IDEL) {
      _getEvaluateList();
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(top: 18, left: 16, right: 16),
      child: Column(
        children: [
          Container(
            height: 40,
            width: ScreenUtil.instance.width,
            child: Row(
              children: [
                Text(
                  "总体评价",
                  style: AppStyle.whiteRegular14,
                  textAlign: TextAlign.start,
                ),
                Spacer(),
                GradeStart(avgScore, 5, isCanClick: false, size: 22, intervalWidth: 10),
                SizedBox(width: 8),
                Text("$avgScore分", style: AppStyle.yellowRegular14),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: Column(
              children: [
                for (int i = 0; i < evaluateList.length; i++) _getCommonUi(evaluateList[i], i, evaluateList.length)
              ],
            ),
          ),
          Container(
            height: 26.0,
            child: Row(
              children: [
                Spacer(),
                GestureDetector(
                  child: Container(
                    color: AppColor.transparent,
                    child: Row(
                      children: [
                        Text("更多", style: AppStyle.whiteRegular12),
                        SizedBox(width: 8),
                        AppIcon.getAppIcon(
                          AppIcon.arrow_right_18,
                          16,
                          color: AppColor.textWhite60,
                        )
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  //没有评价的ui
  Widget noEvaluate() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 18, left: 16, right: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text(
              "活动评价",
              style: AppStyle.whiteRegular14,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 40,
            child: GradeStart(score, 5, listener: (score) {
              setState(() {
                this.score = score;
              });
            }),
          ),
          SizedBox(height: 18),
          _getEdit(),
          SizedBox(height: 10),
          CustomYellowButton("确定", CustomYellowButton.buttonStateNormal, () {
            _publishEvaluate();
          }, width: 64, height: 28),
        ],
      ),
    );
  }

  Widget _getEdit() {
    return Container(
      height: 60,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.layoutBgGrey),
      child: TextField(
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular12,
        maxLines: null,
        maxLength: 50,
        controller: controller,
        focusNode: widget.inputEvaluateFocusNode,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "活动说明...",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 50)],
      ),
    );
  }

  //活动评价的item
  Widget _getCommonUi(ActivityEvaluateModel model, int index, int length) {
    return Container(
      height: 82.0,
      margin: EdgeInsets.only(bottom: index + 1 == length ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatarImageUtil.init().getUserImageWidget(model.userInfo.avatarUri, model.userInfo.uid.toString(), 42),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 6),
                Container(
                  height: 28,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(model.userInfo.nickName ?? "", style: AppStyle.whiteMedium15),
                      SizedBox(width: 17),
                      GradeStart(model.score, 5, isCanClick: false, size: 18, intervalWidth: 4),
                    ],
                  ),
                ),
                Text(model.content ?? "", style: AppStyle.text1Regular14, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(width: 6),
                Text(DateUtil.getCommentShowData(DateUtil.getDateTimeByMs(model.createTime)),
                    style: AppStyle.text2Regular12),
                SizedBox(width: 6),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }

  _publishEvaluate() async {
    if (controller.text == null || controller.text.length < 1) {
      ToastShow.show(msg: "发布的内容为空", context: context);
      return;
    }
    if (widget.inputEvaluateFocusNode.hasFocus) {
      widget.inputEvaluateFocusNode.unfocus();
    }
    List list = await publishEvaluate(widget.activityModel.id, this.score, controller.text);
    if (list[0] < 0) {
      ToastShow.show(msg: list[1], context: context);
    } else {
      ToastShow.show(msg: "发布评价成功", context: context);
    }

    if (widget.onRestDataListener != null) {
      widget.onRestDataListener();
    }
  }

  //获取评价
  _getEvaluateList() async {
    loadingStatus = LoadingStatus.STATUS_LOADING;
    evaluateList.addAll(await getEvaluateList(widget.activityModel.id, size: 2));
    print("evaluateList.length:${evaluateList.length}");
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
  }
}
