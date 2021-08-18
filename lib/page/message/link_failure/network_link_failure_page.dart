import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/widget/custom_appbar.dart';

class NetworkLinkFailure extends StatefulWidget {
  @override
  _NetworkLinkFailureState createState() => _NetworkLinkFailureState();
}

class _NetworkLinkFailureState extends State<NetworkLinkFailure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "网络连接失败",
      ),
      body: getBody(),
      backgroundColor: AppColor.mainBlack,
    );
  }

  Widget getBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              "您的设备未能连接到网络",
              style: AppStyle.whiteRegular16,
            ),
            SizedBox(height: 48),
            Text("如果需要连接到互联网，请参考以下方法：", style: AppStyle.whiteRegular14),
            SizedBox(height: 24),
            Container(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(style: AppStyle.whiteRegular14, children: [
                  TextSpan(text: "进入设备"),
                  TextSpan(
                      text: "“设置”-“${CheckPhoneSystemUtil.init().isIos() ? "无线局域网" : "WLAN"}”",
                      style: AppStyle.whiteMedium14),
                  TextSpan(text: "选择一个可用的WiFi热点接入。"),
                ]),
              ),
            ),
            SizedBox(height: 24),
            Container(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(style: AppStyle.whiteRegular14, children: [
                  TextSpan(text: "进入设备"),
                  TextSpan(
                      text: "“设置”-${CheckPhoneSystemUtil.init().isIos() ? "“蜂窝移动数据”" : "移动网络"}",
                      style: AppStyle.whiteMedium14),
                  TextSpan(text: "点击启用${CheckPhoneSystemUtil.init().isIos() ? "蜂窝数据" : "数据网络"}（启用后运营商可能会收取数据通信费用）"),
                ]),
              ),
            ),
            SizedBox(height: 48),
            Text("如果您已接入无线局域网或${CheckPhoneSystemUtil.init().isIos() ? "蜂窝移动数据" : "WLAN"}：",
                style: AppStyle.whiteRegular14),
            SizedBox(height: 24),
            Text("请检查您所连接的WiFi热点是否接入互联网，或该热点是否允许您的设备访问互联网。", style: AppStyle.whiteRegular14),
            SizedBox(height: 24),
            Visibility(
              visible: CheckPhoneSystemUtil.init().isIos(),
              child: Container(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(style: AppStyle.whiteRegular14, children: [
                    TextSpan(text: "请检查您的设备是否允许“春柠”使用数据，进入设备"),
                    TextSpan(text: "“设置”-“无线局域网”-“使用WLAN与蜂窝移动网的应用”-“春柠”", style: AppStyle.whiteMedium14),
                    TextSpan(text: "允许使用数据"),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
