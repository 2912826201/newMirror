import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/training_record_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/training/weight_records_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/precision_limit_formatter.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';
import 'package:provider/provider.dart';
import 'customize_line_chart.dart';

///体重记录页--我的体重
class WeightRecordPage extends StatefulWidget {
  @override
  _WeightRecordPageState createState() => _WeightRecordPageState();
}

class _WeightRecordPageState extends State<WeightRecordPage> {
  LoadingStatus loadingStatus;
  TextEditingController _numberController = TextEditingController();
  double userWeight = 0.0;
  WeightRecordsModel weightDataModel;

  @override
  void initState() {
    super.initState();
    loadingStatus = LoadingStatus.STATUS_LOADING;
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        titleString: "我的体重",
      ),
      body: getBodyUi(),
    );
  }

  //判断该显示什么ui
  Widget getBodyUi() {
    return Container(
      color: AppColor.mainBlack,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Container(
              width: ScreenUtil.instance.width,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  getTopUi(),
                  getTargetWeightUi(),
                  getViewLine(12),
                  getWeightTextUi(),
                  getViewLine(1),
                  listViewUi(),
                  getSizeBox(83),
                ],
              ),
            ),
          ),
          Positioned(
            child: GestureDetector(
              child: Container(
                color: AppColor.layoutBgGrey,
                height: 48,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(
                  "记录体重",
                  style: AppStyle.whiteRegular16,
                ),
              ),
              onTap: showAppDialogSaveWeight,
            ),
            bottom: ScreenUtil.instance.bottomBarHeight,
          ),
          Positioned(
            child: GestureDetector(
              child: Container(
                color: AppColor.layoutBgGrey,
                height: ScreenUtil.instance.bottomBarHeight,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                alignment: Alignment.center,
              ),
              onTap: showAppDialogSaveWeight,
            ),
            bottom: 0,
          ),
        ],
      ),
    );
  }

  //底部list
  Widget listViewUi() {
    if (weightDataModel == null || weightDataModel.recordList == null || weightDataModel.recordList.length < 1) {
      return SliverToBoxAdapter();
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((content, index) {
        return getLeftDeleteUi(index);
      }, childCount: weightDataModel.recordList.length),
    );
  }

  //获取左滑删除
  Widget getLeftDeleteUi(int index) {
    return LeftScrollListView(
      itemKey: weightDataModel.recordList[index].dateTime,
      itemTag: "tag",
      itemIndex: index,
      itemChild: getItem(index),
      onClickRightBtn: (ind) {
        delWeight(weightDataModel.recordList[index].id);
        weightDataModel.recordList.removeAt(index);
        if (mounted) {
          setState(() {});
        }

        context.read<ProfileNotifier>().setWeight(weightDataModel.recordList.isNotEmpty?weightDataModel.recordList.first
            .weight:0);
      },
    );
  }

//每一个listview的item
  Widget getItem(int index) {
    DateTime dateTime = DateUtil.stringToDateTime(weightDataModel.recordList[index].dateTime);
    String date;
    try {
      date = DateUtil.formatDateString(dateTime);
    } catch (e) {
      date = "";
    }
    return Container(
      height: 50,
      color: AppColor.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 48,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: AppStyle.text1Regular14,
                ),
                Text(
                  "${weightDataModel.recordList[index].weight} kg",
                  style: AppStyle.whiteMedium18,
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            width: MediaQuery
                .of(context)
                .size
                .width,
            color: AppColor.transparent,
          ),
        ],
      ),
    );
  }

  Widget getWeightTextUi() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: Container(
          color: AppColor.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child:
          Text("体重记录", style: AppStyle.whiteRegular16),
        ),
      ),
    );
  }

  Widget getViewLine(double height) {
    return SliverToBoxAdapter(
      child: Container(
        height: height,
        color: AppColor.transparent,
      ),
    );
  }

  Widget getTargetWeightUi() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                ),
                Text("目标体重", style: AppStyle.whiteRegular16),
                Expanded(child: SizedBox()),
                Text(
                  getTargetWeight() < 1 ? "未设置" : getTargetWeight().toString() + "kg",
                  style: AppStyle.text1Regular16,
                ),
                SizedBox(
                  width: 17,
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(top: 3),
                  alignment: Alignment.center,
                  child: AppIcon.getAppIcon(
                    AppIcon.arrow_right_16,
                    16,
                    color: AppColor.textWhite40,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
            Positioned(
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  width: 100,
                  height: 48,
                ),
                onTap: showAppDialogPr,
              ),
              right: 0,
            )
          ],
        ),
      ),
    );
  }

  Widget getSizeBox(double height) {
    return SliverToBoxAdapter(
      child: SizedBox(height: height),
    );
  }

  //获取头部ui
  Widget getTopUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return SliverToBoxAdapter(
        child: Container(
          height: 224,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          child: UnconstrainedBox(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (weightDataModel == null || weightDataModel.recordList == null || weightDataModel.recordList.length < 1) {
      return SliverToBoxAdapter(
        child: Container(
          height: 224,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          child: UnconstrainedBox(
            child: Image.asset(
              "assets/png/default_no_data.png",
              fit: BoxFit.cover,
              width: 224,
              height: 224,
            ),
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: CustomizeLineChart(weightDataModel: weightDataModel),
      );
    }
  }

  //获取目标体重
  double getTargetWeight() {
    if (userWeight < 1) {
      if (weightDataModel == null || weightDataModel.targetWeight == null || weightDataModel.targetWeight < 1) {
        return userWeight;
      } else {
        userWeight = weightDataModel.targetWeight;
        return weightDataModel.targetWeight;
      }
    } else {
      return userWeight;
    }
  }

  //显示输入体重
  void showAppDialogPr() {
    showAppDialog(context,
        title: "请输入目标体重",
        customizeWidget: Container(
          margin: const EdgeInsets.symmetric(horizontal: 46.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: SizedBox(
                child: Container(
                  height: 28,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: _numberController,
                    style: AppStyle.whiteRegular18,
                    inputFormatters: [PrecisionLimitFormatter(2)],
                    decoration: InputDecoration(
                      // hintText: userWeight > 0.0 ? userWeight.toString() : "",
                      hintText: "",
                      labelStyle: TextStyle(color: AppColor.dividerWhite8),
                      hintMaxLines: 1,
                      // 主要添加以下代码
                      enabledBorder: new UnderlineInputBorder(
                        // 不是焦点的时候颜色
                        borderSide: BorderSide(color: AppColor.dividerWhite8),
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(width: 4),
              Text(
                "KG",
                style: AppStyle.text1Regular16,
              ),
            ],
          ),
        ),
        cancel: AppDialogButton("取消", () {
          _numberController.text = "";
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          try {
            userWeight = double.parse(_numberController.text);
            userWeight = formatData(userWeight);
            saveTargetWeight(userWeight.toString());
            weightDataModel.targetWeight = userWeight;
            if (mounted) {
              setState(() {});
            }
          } catch (e) {
            ToastShow.show(msg: "输入有错，请重新输入！", context: context);
          }
          _numberController.text = "";
          return true;
        }));
  }

  //显示输入体重
  void showAppDialogSaveWeight() {
    showAppDialog(context,
        title: "请输入当前体重",
        customizeWidget: Container(
          margin: const EdgeInsets.symmetric(horizontal: 46.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: SizedBox(
                child: Container(
                  height: 28,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: _numberController,
                    style: AppStyle.whiteRegular18,
                    inputFormatters: [PrecisionLimitFormatter(2)],
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: AppColor.dividerWhite8),
                      hintMaxLines: 1,
                      // 主要添加以下代码
                      enabledBorder: new UnderlineInputBorder(
                        // 不是焦点的时候颜色
                        borderSide: BorderSide(color: AppColor.dividerWhite8),
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(width: 4),
              Text(
                "KG",
                style: AppStyle.text1Regular16,
              ),
            ],
          ),
        ),
        cancel: AppDialogButton("取消", () {
          _numberController.text = "";
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          try {
            double userWeight = double.parse(_numberController.text);
            userWeight = formatData(userWeight);
            saveWeight(userWeight.toString());
            addWeightData(userWeight);
            context.read<ProfileNotifier>().setWeight(formatData(userWeight));
            _numberController.text = "";
          } catch (e) {
            ToastShow.show(msg: "输入有错，请重新输入！", context: context);
          }

          return true;
        }));
  }

  //将添加的体重添加到 weightDataMap 中显示
  addWeightData(double userWeight) {
    if (weightDataModel == null) {
      weightDataModel = new WeightRecordsModel();
    }

    RecordData recordData = new RecordData();
    recordData.dateTime = DateUtil.formatDateString(new DateTime.now());
    recordData.weight = userWeight;

    if (weightDataModel.recordList == null || weightDataModel.recordList.length < 1) {
      List<RecordData> recordList = [];
      recordList.add(recordData);
      weightDataModel.recordList = recordList;
    } else {
      if (DateUtil.isToday(DateUtil.stringToDateTime(weightDataModel.recordList[0].dateTime))) {
        weightDataModel.recordList[0].dateTime = DateUtil.formatDateString(new DateTime.now());
        weightDataModel.recordList[0].weight = userWeight;
      } else {
        weightDataModel.recordList.insert(0, recordData);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }


  //获取数据
  loadData() async {
    weightDataModel = await getWeightRecords(1, 1000);
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    if (mounted) {
      setState(() {});
    }
  }

  double formatData(double value) {
    return ((value * 100) ~/ 1) / 100;
  }
}
