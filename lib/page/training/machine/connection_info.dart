import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/widget/seekbar.dart';

/// connection_info
/// Created by yangjiayi on 2021/1/4.

//机器连接信息页

class ConnectionInfoPage extends StatefulWidget {
  @override
  _ConnectionInfoState createState() => _ConnectionInfoState();
}

class _ConnectionInfoState extends State<ConnectionInfoPage> {
  String _title = "IF终端";

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.white,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _title,
                  style: AppStyle.textMedium18,
                ),
                //因只有左侧有按钮 所以在右侧增加同样大小区域 避免居中后偏右
                SizedBox(
                  width: 48,
                )
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "设备名称",
                  style: AppStyle.textRegular16,
                ),
                Spacer(),
                Text(
                  "IF终端",
                  style: AppStyle.textSecondaryRegular16,
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.bgWhite,
          ),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Wi-Fi",
                  style: AppStyle.textRegular16,
                ),
                SizedBox(
                  width: 12,
                ),
                Spacer(),
                Text(
                  "aimymusic_guest",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.textSecondaryRegular16,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  "未连接",
                  style: AppStyle.textSecondaryRegular16,
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.bgWhite,
          ),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "设备号",
                  style: AppStyle.textRegular16,
                ),
                Spacer(),
                Text(
                  "iFChengdu7CC10",
                  style: AppStyle.textSecondaryRegular16,
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.bgWhite,
          ),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "系统版本号",
                  style: AppStyle.textRegular16,
                ),
                Spacer(),
                Text(
                  "1.1.12",
                  style: AppStyle.textSecondaryRegular16,
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.bgWhite,
          ),
          SizedBox(
            height: 28,
          ),
          GestureDetector(
            onTap: () {
              print("断开连接");
            },
            child: Container(
              alignment: Alignment.center,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: AppColor.textPrimary2,
              ),
              child: Text(
                "断开连接",
                style: TextStyle(color: AppColor.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
