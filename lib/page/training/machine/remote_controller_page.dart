import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/seekbar.dart';

/// remote_controller_page
/// Created by yangjiayi on 2020/12/31.

//机器遥控器页

class RemoteControllerPage extends StatefulWidget {
  @override
  _RemoteControllerState createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteControllerPage> {
  String _title = "终端遥控";
  int _volumeValue = 50;
  int _lightnessValue = 50;
  bool _machineConnected = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.white,
            brightness: Brightness.light,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _title,
                  style: AppStyle.textMedium18,
                ),
              ],
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColor.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppColor.black,
                  ),
                  onPressed: () {
                    AppRouter.navigateToMachineSetting(context);
                  }),
            ],
          ),
          body: _buildBody(context),
        ));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 260,
          child: _buildScreen(context),
        ),
        Container(
          height: 12,
          color: AppColor.bgWhite,
        ),
        _buildPanel(),
      ],
    );
  }

  Widget _buildScreen(BuildContext context) {
    return _buildMachinePic();
  }

  Widget _buildMachinePic() {
    return Center(
      child: Container(
        height: 210,
        width: 114.5,
        color: AppColor.mainBlue,
      ),
    );
  }

  Widget _buildVideoCourse() {
    return Container();
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.5, 16, 40.5, 0),
      child: Column(
        children: [
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: 28,
                      width: 28,
                      child: Icon(
                        Icons.volume_up,
                        color: _machineConnected ? AppColor.textPrimary2 : AppColor.textHint,
                        size: 24,
                      )),
                  Expanded(
                      child: Container(
                    //slider会将handler的大小算在组件宽度 所以间距要减去handler的宽度的一半 才是进度条本体的间距
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: AppSeekBar(100, 0, _volumeValue.toDouble(), !_machineConnected,
                        (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        _volumeValue = lowerValue.toInt();
                      });
                    }, (handlerIndex, lowerValue, upperValue) {
                      //调接口保存值
                      print("调接口保存音量：$lowerValue");
                    }),
                  )),
                  SizedBox(
                    width: 42,
                    child: Text(
                      "$_volumeValue%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: _machineConnected ? AppColor.textPrimary2 : AppColor.textHint,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 12,
          ),
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: 28,
                      width: 28,
                      child: Icon(
                        Icons.wb_sunny,
                        color: _machineConnected ? AppColor.textPrimary2 : AppColor.textHint,
                        size: 24,
                      )),
                  Expanded(
                      child: Container(
                    //slider会将handler的大小算在组件宽度 所以间距要减去handler的宽度的一半 才是进度条本体的间距
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: AppSeekBar(100, 0, _lightnessValue.toDouble(), !_machineConnected,
                        (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        _lightnessValue = lowerValue.toInt();
                      });
                    }, (handlerIndex, lowerValue, upperValue) {
                      //调接口保存值
                      print("调接口保存亮度：$lowerValue");
                    }),
                  )),
                  SizedBox(
                    width: 42,
                    child: Text(
                      "$_lightnessValue%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: _machineConnected ? AppColor.textPrimary2 : AppColor.textHint,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 12,
          ),
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 28,
                    width: 28,
                    child: Icon(
                      Icons.book,
                      color: AppColor.textPrimary2,
                      size: 24,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "IF智能魔镜连接状态",
                    style: AppStyle.textRegular15,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (_machineConnected) {
                        AppRouter.navigateToMachineConnectionInfo(context);
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _machineConnected ? "已连接" : "未连接",
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary2),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 12,
                          width: 12,
                          child: Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _machineConnected ? AppColor.lightGreen : AppColor.mainRed,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColor.textHint,
                          size: 16,
                        ),
                      ],
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 46,
          ),
          Container(
            alignment: Alignment.center,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: _machineConnected ? AppColor.textPrimary2 : AppColor.textHint,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.skip_previous,
                  color: AppColor.white,
                  size: 32,
                ),
                Icon(
                  Icons.pause,
                  color: AppColor.white,
                  size: 32,
                ),
                Icon(
                  Icons.skip_next,
                  color: AppColor.white,
                  size: 32,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
