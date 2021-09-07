import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';

import 'grade_start_ui.dart';

class DetailEvaluateUi extends StatefulWidget {
  final ActivityModel activityModel;
  final FocusNode inputEvaluateFocusNode;

  DetailEvaluateUi(this.activityModel, this.inputEvaluateFocusNode);

  @override
  _DetailEvaluateUiState createState() => _DetailEvaluateUiState();
}

class _DetailEvaluateUiState extends State<DetailEvaluateUi> {
  double score = 0.0;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.activityModel.isEvaluate == null) {
      widget.activityModel.isEvaluate = false;
    }
    if (widget.activityModel.status != 3) {
      return noEvaluate();
    } else if (!widget.activityModel.isEvaluate) {
      return noEvaluate();
    } else {
      return noEvaluate();
    }
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
            child: GradeStart(score, 5, (score) {
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

  _publishEvaluate() async {
    if (controller.text == null || controller.text.length < 1) {
      ToastShow.show(msg: "发布的内容为空", context: context);
      return;
    }
    if (widget.inputEvaluateFocusNode.hasFocus) {
      widget.inputEvaluateFocusNode.unfocus();
    }
    double score = await publishEvaluate(widget.activityModel.id, this.score, controller.text);
    if (score < 0) {
      ToastShow.show(msg: "发布评价失败", context: context);
    } else {
      ToastShow.show(msg: "发布评价成功", context: context);
    }
  }
}
