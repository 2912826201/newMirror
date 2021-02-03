import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/training_record_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/left_scroll/left_scroll_list_view.dart';
import 'package:mirror/widget/precision_limit_Formatter.dart';
import 'package:provider/provider.dart';
import '../profile_detail_page.dart';
import '../profile_detail_page.dart';
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
  Map<String, dynamic> weightDataMap = Map();

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
      appBar: AppBar(
        title: Text("我的体重"),
        centerTitle: true,
      ),
      body: getBodyUi(),
    );
  }

  //判断该显示什么ui
  Widget getBodyUi() {
    return Container(
      child: Stack(
        children: [
          Container(
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
          Positioned(
            child: GestureDetector(
              child: Container(
                color: AppColor.textPrimary2,
                height: 83,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 13.5),
                child: Text(
                  "记录体重",
                  style: TextStyle(fontSize: 16, color: AppColor.white),
                ),
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
    if (weightDataMap == null || weightDataMap["recordList"] == null || weightDataMap["recordList"].length < 1) {
      return SliverToBoxAdapter();
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((content, index) {
        return getLeftDeleteUi(index);
      }, childCount: weightDataMap["recordList"].length),
    );
  }

  //获取左滑删除
  Widget getLeftDeleteUi(int index) {
    return LeftScrollListView(
      itemKey: weightDataMap["recordList"][index]["dateTime"],
      itemTag: "tag",
      itemIndex: index,
      itemChild: getItem(index),
      onClickRightBtn: () {
        delWeight(weightDataMap["recordList"][index]["id"]);
        weightDataMap["recordList"].removeAt(index);
        if(mounted){
          setState(() {});
        }
        context.read<ProfilePageNotifier>().setweight(0);
      },
    );
  }
//每一个listview的item
  Widget getItem(int index) {
    DateTime dateTime = DateUtil.stringToDateTime(weightDataMap["recordList"][index]["dateTime"]);
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
                  style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                ),
                Text(
                  "${weightDataMap["recordList"][index]["weight"]} kg",
                  style: TextStyle(fontSize: 18, color: AppColor.textPrimary1, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width,
            color: AppColor.bgWhite,
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
              Text("体重记录", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget getViewLine(double height) {
    return SliverToBoxAdapter(
      child: Container(
        height: height,
        color: AppColor.bgWhite,
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
                Text("目标体重", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                Expanded(child: SizedBox()),
                Text(
                  getTargetWeight() < 1 ? "未设置" : getTargetWeight().toString() + "kg",
                  style: TextStyle(fontSize: 16, color: AppColor.textSecondary),
                ),
                SizedBox(
                  width: 17,
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(top: 3),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: AppColor.textHint,
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

    if (weightDataMap == null || weightDataMap["recordList"] == null || weightDataMap["recordList"].length < 1) {
      return SliverToBoxAdapter(
        child: Container(
          height: 224,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          child: UnconstrainedBox(
            child: Image.asset(
              "images/test/bg.png",
              fit: BoxFit.cover,
              width: 224,
              height: 224,
            ),
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: CustomizeLineChart(weightDataMap: weightDataMap),
      );
    }
  }

  //获取目标体重
  double getTargetWeight() {
    if (userWeight < 1) {
      if (weightDataMap == null || weightDataMap["targetWeight"] == null || weightDataMap["targetWeight"] < 1) {
        return userWeight;
      } else {
        userWeight = weightDataMap["targetWeight"];
        return weightDataMap["targetWeight"];
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
                    inputFormatters: [PrecisionLimitFormatter(2)],
                    decoration: InputDecoration(
                      hintText: userWeight > 0.0 ? userWeight.toString() : "",
                      labelStyle: TextStyle(color: Color(0x99000000)),
                      hintMaxLines: 1,
                      // 主要添加以下代码
                      enabledBorder: new UnderlineInputBorder(
                        // 不是焦点的时候颜色
                        borderSide: BorderSide(color: Color(0x19000000)),
                      ),
                    ),
                  ),
                ),
              )),
              SizedBox(width: 4),
              Text(
                "KG",
                style: TextStyle(fontSize: 16, color: AppColor.textSecondary),
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
            weightDataMap["targetWeight"] = userWeight;
            if(mounted){
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
                        inputFormatters: [PrecisionLimitFormatter(2)],
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Color(0x99000000)),
                          hintMaxLines: 1,
                          // 主要添加以下代码
                          enabledBorder: new UnderlineInputBorder(
                            // 不是焦点的时候颜色
                            borderSide: BorderSide(color: Color(0x19000000)),
                          ),
                        ),
                      ),
                    ),
                  )),
              SizedBox(width: 4),
              Text(
                "KG",
                style: TextStyle(fontSize: 16, color: AppColor.textSecondary),
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
            context.read<ProfilePageNotifier>().setweight(formatData(userWeight));
            _numberController.text = "";
          } catch (e) {
            ToastShow.show(msg: "输入有错，请重新输入！", context: context);
          }

          return true;
        }));
  }

  //将添加的体重添加到 weightDataMap 中显示
  addWeightData(double userWeight) {
    if (weightDataMap == null) {
      weightDataMap = Map();
    }
    Map<String, dynamic> recordMap = Map();
    recordMap["dateTime"] = DateUtil.formatDateString(new DateTime.now());
    recordMap["weight"] = userWeight;

    if (weightDataMap["recordList"] == null || weightDataMap["recordList"].length < 1) {
      List<Map<String, dynamic>> recordListMap = [];
      recordListMap.add(recordMap);
      weightDataMap["recordList"] = recordListMap;
    } else {
      if (DateUtil.isToday(DateUtil.stringToDateTime(weightDataMap["recordList"][0]["dateTime"]))) {
        weightDataMap["recordList"][0]["dateTime"] = DateUtil.formatDateString(new DateTime.now());
        weightDataMap["recordList"][0]["weight"] = userWeight;
      } else {
        weightDataMap["recordList"].insert(0, recordMap);
      }
    }
    if(mounted){
      setState(() {});
    }
  }

  //获取数据
  loadData() async {
    weightDataMap = await getWeightRecords(1, 1000);
    loadingStatus = LoadingStatus.STATUS_COMPLETED;
    if(mounted){
      setState(() {});
    }
  }

  double formatData(double value) {
    return ((value * 100) ~/ 1) / 100;
  }
}
