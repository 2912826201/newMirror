import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:provider/provider.dart';

enum ScanResultType {
  //绑定设备
  BIND_DEVICE,
  //登录完成
  LOGIN_COMPLETE,
  //登录信息过期
  LOGIN_EXPIRED,
  //二维码无效
  CODE_INVALID
}

class ScanResultPage extends StatefulWidget {
  ScanResultType type;
  ScanResultPage({this.type});
  @override
  State<StatefulWidget> createState() {
    return _ScanResultPageState();
  }
}

class _ScanResultPageState extends State<ScanResultPage> {
  String name = "机器名";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: InkWell(
          child: Container(
            margin: EdgeInsets.only(left: 16),
            child: Image.asset("images/resource/2.0x/return2x.png"),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 44,
        title: Text(
          widget.type == ScanResultType.LOGIN_COMPLETE ? "扫一扫" : "扫码结果",
          style: AppStyle.textMedium18,
        ),
        centerTitle: true,
      ),
      body: Container(
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.screenWidthDp,
        child: Stack(
          children: [
            Opacity(
              opacity:widget.type!=ScanResultType.BIND_DEVICE?1:0,
              child:Container(
              height: ScreenUtil.instance.height,
              width: ScreenUtil.instance.screenWidthDp,
              child: _squareFrameWidget(),
            ) ,),
            Opacity(
              opacity: widget.type==ScanResultType.BIND_DEVICE?1:0,
              child: Container(
              height: ScreenUtil.instance.height,
              width: ScreenUtil.instance.screenWidthDp,
              child: _roundFrameWidget(),
            ),)
          ],
        ),
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
          widget.type == ScanResultType.LOGIN_COMPLETE
              ? "登录设备成功"
              : widget.type == ScanResultType.LOGIN_EXPIRED
                  ? "登录信息已过期，请重新尝试登录"
                  : widget.type == ScanResultType.LOGIN_EXPIRED
                      ? "无效的二维码"
                      : "",
          style: AppStyle.textRegular16,
        ),
        SizedBox(height: 6,),
        Opacity(
          opacity: widget.type == ScanResultType.LOGIN_COMPLETE ? 1 : 0,
          child: Text("当前账号登录$name成功"),
        ),
        SizedBox(height: 98,),
        Opacity(
          opacity: widget.type == ScanResultType.CODE_INVALID ? 0 : 1,
          child: _button(widget.type == ScanResultType.LOGIN_EXPIRED
              ? "重新扫描"
              : widget.type == ScanResultType.LOGIN_COMPLETE
                  ? "完成"
                  : ""),
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
        _button("确认登录"),
        SizedBox(height: 12,),
        _button("取消登录",color: AppColor.transparent)
      ],
    );
  }

  Widget _button(String title,{Color color}) {
    return Container(
      padding: EdgeInsets.only(left: 41, right: 41),
      child: ClickLineBtn(
        title: title,
        height: 44.0,
        width: ScreenUtil.instance.screenWidthDp,
        circular: 3.0,
        textColor: color==null?AppColor.white:AppColor.textPrimary1,
        fontSize: 16,
        backColor: color==null?AppColor.bgBlack:color,
        color: color==null?AppColor.transparent:AppColor.bgBlack,
        onTap: () {
          switch(widget.type){
            case ScanResultType.LOGIN_COMPLETE:
            // TODO: Handle this case.
              break;
            case ScanResultType.BIND_DEVICE:
              // TODO: Handle this case.
              break;
            case ScanResultType.LOGIN_EXPIRED:
              // TODO: Handle this case.
              break;
            case ScanResultType.CODE_INVALID:
              // TODO: Handle this case.
              break;
          }
        },
      ),
    );
  }
}
