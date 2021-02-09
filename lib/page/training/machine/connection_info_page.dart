import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:provider/provider.dart';

/// connection_info_page
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
        appBar: CustomAppBar(
          titleString: _title,
        ),
        body: _buildBody(context),
      ),
    );
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
        _buildPanel(context.watch<MachineNotifier>()),
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

  Widget _buildPanel(MachineNotifier notifier) {
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
                  "${notifier.machine.name}",
                  style: AppStyle.textSecondaryRegular16,
                )
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: AppColor.bgWhite,
          ),
          //wifi名称可能很长 所以做个长度处理
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    "Wi-Fi",
                    textAlign: TextAlign.start,
                    style: AppStyle.textRegular16,
                  ),
                ),
                Expanded(
                    child: Text(
                  notifier.machine.wifi == null ? "未连接" : "${notifier.machine.wifi}",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppStyle.textSecondaryRegular16,
                )),
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
                  "${notifier.machine.deviceNumber}",
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
                  "${notifier.machine.sysVersion}",
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
              logoutMachine(Application.machine.machineId).then((value) {
                if(value){
                  context.read<MachineNotifier>().setMachine(null);
                  AppRouter.popToBeforeMachineController(context);
                }
              });
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
