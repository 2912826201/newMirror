import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';

class WeightRecordPage extends StatefulWidget {
  @override
  _WeightRecordPageState createState() => _WeightRecordPageState();
}

class _WeightRecordPageState extends State<WeightRecordPage> {
  LoadingStatus loadingStatus;
  TextEditingController _numberController = TextEditingController();
  double userWeight = 0.0;

  @override
  void initState() {
    super.initState();
    loadingStatus = LoadingStatus.STATUS_IDEL;
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
    loadingStatus = LoadingStatus.STATUS_IDEL;
    if (loadingStatus == LoadingStatus.STATUS_IDEL) {
      return noDataUi();
    }
  }

  //没有数据时
  Widget noDataUi() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Image.asset(
            "images/test/bg.png",
            fit: BoxFit.cover,
            width: 224,
            height: 224,
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Text("目标体重",
                        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                    Expanded(child: SizedBox()),
                    Text(
                      userWeight < 1 ? "未设置" : userWeight.toString(),
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
          Container(
            height: 12,
            color: AppColor.bgWhite,
          ),
          SizedBox(
            height: 48,
            child: GestureDetector(
              child: Container(
                color: AppColor.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text("体重记录",
                    style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
              ),
              onTap: () {
                ToastShow.show(msg: "体重记录", context: context);
              },
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColor.bgWhite,
          ),
          Expanded(child: SizedBox()),
          GestureDetector(
            child: Container(
              color: AppColor.textPrimary2,
              height: 83,
              width: double.infinity,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 13.5),
              child: Text(
                "记录体重",
                style: TextStyle(fontSize: 16, color: AppColor.white),
              ),
            ),
            onTap: () {
              ToastShow.show(msg: "记录体重", context: context);
            },
          ),
        ],
      ),
    );
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
            setState(() {});
          } catch (e) {
            ToastShow.show(msg: "输入有错，请重新输入！", context: context);
          }
          _numberController.text = "";
          return true;
        }));
  }
}
