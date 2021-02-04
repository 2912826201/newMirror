import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:provider/provider.dart';

class ScanCodeResultType {
  //登录设备
  static const int LOGIN_MACHINE = 0;

  //二维码已过期
  static const int CODE_EXPIRED = -1;

  //二维码无效
  static const int CODE_INVALID = -2;
}

class ScanCodeResultPage extends StatefulWidget {
  final ScanCodeResultModel resultModel;

  ScanCodeResultPage(this.resultModel);

  @override
  State<StatefulWidget> createState() {
    return _ScanCodeResultState();
  }
}

class _ScanCodeResultState extends State<ScanCodeResultPage> {
  String name = "机器名";

  bool isLoginSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "扫码结果",
      ),
      body: Container(
        child: widget.resultModel.type == ScanCodeResultType.LOGIN_MACHINE && !isLoginSuccess
            ? _roundFrameWidget()
            : _squareFrameWidget(),
      ),
    );
  }

  Widget _squareFrameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: ScreenUtil.instance.height * 0.07,
        ),
        Container(
          height: 156,
          width: 156,
          color: AppColor.bgWhite,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          widget.resultModel.type == ScanCodeResultType.LOGIN_MACHINE && isLoginSuccess
              ? "登录设备成功"
              : widget.resultModel.type == ScanCodeResultType.CODE_EXPIRED
                  ? "二维码已过期"
                  : widget.resultModel.type == ScanCodeResultType.CODE_INVALID
                      ? "无效的二维码"
                      : "",
          style: AppStyle.textRegular16,
        ),
        SizedBox(
          height: 6,
        ),
        Opacity(
          opacity: widget.resultModel.type == ScanCodeResultType.LOGIN_MACHINE && isLoginSuccess ? 1 : 0,
          child: Text("当前账号登录$name成功"),
        ),
        SizedBox(
          height: 98,
        ),
        Opacity(
          opacity: widget.resultModel.type == ScanCodeResultType.CODE_INVALID ? 0 : 1,
          child: widget.resultModel.type == ScanCodeResultType.CODE_EXPIRED
              ? _button("重新扫描", () {
                  Navigator.pop(context);
                  AppRouter.navigateToScanCodePage(context);
                })
              : widget.resultModel.type == ScanCodeResultType.LOGIN_MACHINE && isLoginSuccess
                  ? _button("完成", () {
                      Navigator.pop(context);
                    })
                  : Container(),
        )
      ],
    );
  }

  Widget _roundFrameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: ScreenUtil.instance.height * 0.11,
        ),
        ClipOval(
          child: CachedNetworkImage(
            width: 86,
            height: 86,
            imageUrl: context.watch<ProfileNotifier>().profile.avatarUri,
            placeholder: (context, url) => Image.asset(
              "images/test.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: 18,
        ),
        Text(
          context.watch<ProfileNotifier>().profile.nickName,
          style: AppStyle.textMedium18,
        ),
        SizedBox(
          height: 18,
        ),
        Text(
          "将登陆IF终端,请确认是否本人操作",
          style: AppStyle.textMedium16,
        ),
        SizedBox(
          height: 63,
        ),
        _button("确认登录", () async {
          bool loginResult = await loginMachine(int.parse(widget.resultModel.data["mid"]));
          if (loginResult) {
            setState(() {
              isLoginSuccess = true;
            });
          }
        }),
        SizedBox(
          height: 12,
        ),
        _button("取消登录", () {
          Navigator.pop(context);
        }, color: AppColor.transparent)
      ],
    );
  }

  Widget _button(String title, Function() onTap, {Color color}) {
    return Container(
      padding: EdgeInsets.only(left: 41, right: 41),
      child: ClickLineBtn(
        title: title,
        height: 44.0,
        width: ScreenUtil.instance.screenWidthDp,
        circular: 3.0,
        textColor: color == null ? AppColor.white : AppColor.textPrimary1,
        fontSize: 16,
        backColor: color == null ? AppColor.bgBlack : color,
        color: color == null ? AppColor.transparent : AppColor.bgBlack,
        onTap: onTap,
      ),
    );
  }
}

class ScanCodeResultModel {
  int type;
  Map<String, dynamic> data;

  ScanCodeResultModel({this.type, this.data});

  ScanCodeResultModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    data = json["data"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["data"] = data;
    return map;
  }
}
