import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_evaluate_model.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/activity/detail_item/evaluate_list_dialog.dart';
import 'package:mirror/page/activity/detail_item/evaluate_list_ui.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
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
  TextEditingController controller = TextEditingController();

  List<ActivityEvaluateModel> evaluateList = [];
  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;
  GlobalKey<EvaluateListUiState> childKey = GlobalKey();

  ReleaseFeedInputFormatter _formatter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formatter = ReleaseFeedInputFormatter(
        controller: controller,
        maxNumberOfBytes: 300,
        context: context,
        rules: [],
        // @??????
        triggerAtCallback: (String str) {},
        // #??????
        triggerTopicCallback: (String str) {},
        // ??????@#????????????
        shutDownCallback: () async {},
        valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
            String topicSearchStr, bool isAdd) {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activityModel.status != 3) {
      return Container();
    } else if (!widget.activityModel.isJoin) {
      return Container();
    } else if (widget.activityModel.isSignIn) {
      if (widget.activityModel.isEvaluate) {
        //?????????--??????????????????
        return haveEvaluate();
      } else {
        //????????????--????????????ui
        return noEvaluate();
      }
    } else if (widget.activityModel.isCanSignIn) {
      return Container();
    } else {
      //????????????--??????????????????
      return haveEvaluate();
    }
  }

  //????????????ui
  Widget haveEvaluate() {
    if (evaluateList.length < 1 && loadingStatus == LoadingStatus.STATUS_IDEL) {
      _getEvaluateList();
    }
    if (evaluateList.length < 1) {
      return Container();
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
                  "????????????",
                  style: AppStyle.whiteRegular14,
                  textAlign: TextAlign.start,
                ),
                Spacer(),
                GradeStart(widget.activityModel.evaluateAvgScore, 5, isCanClick: false, size: 22, intervalWidth: 10),
                SizedBox(width: 8),
                Text("${widget.activityModel.evaluateAvgScore}???", style: AppStyle.yellowRegular14),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Container(
          //   child: Column(
          //     children: [
          //       for (int i = 0; i < evaluateList.length; i++) _getCommonUi(evaluateList[i], i, evaluateList.length)
          //     ],
          //   ),
          // ),
          Container(
            child: EvaluateListUi(
              childKey,
              widget.activityModel,
              evaluateList,
              isFold: true,
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
                        Text("??????", style: AppStyle.whiteRegular12),
                        SizedBox(width: 8),
                        AppIcon.getAppIcon(
                          AppIcon.arrow_right_18,
                          16,
                          color: AppColor.textWhite60,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    _openActivityEvaluateBottomSheet();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  //???????????????ui
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
              "????????????",
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
          CustomYellowButton("??????", CustomYellowButton.buttonStateNormal, () {
            _publishEvaluate();
          }, width: 64, height: 28),
        ],
      ),
    );
  }

  Widget _getEdit() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 60,
      ),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.layoutBgGrey),
      child: TextField(
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular12,
        maxLines: null,
        maxLength: 100,
        controller: controller,
        enableInteractiveSelection: true,
        textInputAction: TextInputAction.send,
        focusNode: widget.inputEvaluateFocusNode,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "????????????",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [_formatter],
      ),
    );
  }

  _publishEvaluate() async {
    if (controller.text == null || controller.text.length < 1) {
      ToastShow.show(msg: "?????????????????????", context: context);
      return;
    }
    // ????????????
    Map<String, dynamic> textModel = await feedTextScan(text: controller.text);
    if (!textModel["state"]) {
      ToastShow.show(msg: "????????????????????????????????????????????????", context: context, gravity: Toast.CENTER);
      return;
    }
    if (widget.inputEvaluateFocusNode.hasFocus) {
      widget.inputEvaluateFocusNode.unfocus();
    }
    List list = await publishEvaluate(widget.activityModel.id, this.score, controller.text);
    if (list[0] < 0) {
      ToastShow.show(msg: list[1], context: context);
    } else {
      ToastShow.show(msg: "??????????????????", context: context);
    }

    if (widget.onRestDataListener != null) {
      widget.onRestDataListener();
    }
  }

  //????????????
  _getEvaluateList() async {
    loadingStatus = LoadingStatus.STATUS_LOADING;
    DataResponseModel dataResponseModel = await getEvaluateList(widget.activityModel.id, size: 2);
    if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
      evaluateList.clear();
      dataResponseModel.list.forEach((element) {
        evaluateList.add(ActivityEvaluateModel.fromJson(element));
      });
      evaluateList.forEach((element) {
        element.commentList?.clear();
      });
    }
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    setState(() {});
  }

  _openActivityEvaluateBottomSheet() {
    openActivityEvaluateBottomSheet(
        context: context,
        activityModel: widget.activityModel,
        callback: () {
          print("11111111111111111111111111111111111111111111");
          _getEvaluateList();
        });
  }
}
