import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/version_update_dialog.dart';

//关于
class AboutPage extends StatefulWidget {
  String url;
  bool haveNewVersion;
  String content;

  AboutPage({this.url, this.haveNewVersion, this.content});

  @override
  State<StatefulWidget> createState() {
    return _AboutPageState(url: url, haveNewVersion: haveNewVersion, content: content);
  }
}

class _AboutPageState extends State<AboutPage> {
  String url;
  bool haveNewVersion;
  String content;

  _AboutPageState({this.url, this.haveNewVersion, this.content});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        titleString: "关于iFitness",
      ),
      body: Container(
        width: width,
        height: height - ScreenUtil.instance.statusBarHeight,
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              height: 148,
              width: width,
              color: AppColor.bgWhite,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("images/test/ic_launcher.png"), fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${AppConfig.version}-${AppConfig.buildNumber}",
                      style: AppStyle.textHintRegular12,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            _itemRow("用户协议"),
            _itemRow("隐私权政策"),
            haveNewVersion
                ? InkWell(
                    onTap: () {
                      showVersionDialog(context: context, content: content, url: url, strong: false);
                    },
                    child: _itemRow("版本更新"),
                  )
                : Container(),
            Spacer(),
            Center(
              child: Text(
                "Copyright@2019 iFitness.All rights Reserved",
                style: AppStyle.textSecondaryRegular13,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemRow(String text) {
    return Container(
      height: 48,
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppStyle.textRegular16,
            ),
            Spacer(),
            text == "版本更新" && haveNewVersion
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 18,
                      color: AppColor.mainRed,
                      child: Center(
                        child: Text(
                          "NEW",
                          style: AppStyle.whiteRegular12,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              width: 12,
            ),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
