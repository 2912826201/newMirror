import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:provider/provider.dart';

//黑名单
class BlackListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlackListState();
  }
}

class _BlackListState extends State<BlackListPage> {
  List<blackUserModel> blackList = [];

  _getBlackList() async {
    BlackListModel modelList = await SettingBlackList();
    if (modelList != null) {
      modelList.list.forEach((element) {
        blackList.add(element);
        print('黑名單名字--------------------------${element.nickName}');
        print('黑名單頭像--------------------------${element.avatarUri}');
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<UserInteractiveNotifier>().removeId = [];
    _getBlackList();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        titleString: "黑名单",
      ),
      body: blackList.isNotEmpty
          ? Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: height,
              width: width,
              child: ListView.builder(
                  itemCount: blackList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        _item(width, index)
                      ],
                    );
                  }),
            )
          : Container(
              height: height,
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    height: 224,
                    width: 224,
                    child: Image.asset(DefaultImage.nodata),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "暂无内容",
                    style: AppStyle.textHintRegular12,
                  ),
                  Spacer(),
                ],
              ),
            ),
    );
  }

  Widget _item(double width, int index) {
    print('item==========================${blackList[index].nickName}');
    return Container(
      width: width,
      height: 48,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              AppRouter.navigateToMineDetail(context, blackList[index].uid,
                  avatarUrl: blackList[index].avatarUri, userName: blackList[index].nickName, callback: (result) {
                if (context.read<UserInteractiveNotifier>().removeId != null) {
                  List<blackUserModel> list = [];
                  blackList.forEach((element) {
                    if (!context.read<UserInteractiveNotifier>().removeId.contains(element.uid)) {
                      list.add(element);
                    }
                  });
                  blackList.clear();
                  blackList.addAll(list);
                  setState(() {});
                }
              });
            },
            child: ClipOval(
              child: CachedNetworkImage(
                height: 38,
                width: 38,
                imageUrl: blackList[index].avatarUri != null ? FileUtil.getSmallImage(blackList[index].avatarUri) : " ",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Center(
            child: Text(
              blackList[index].nickName,
              style: AppStyle.textRegular16,
            ),
          ),
          Spacer(),
          Center(
              child: InkWell(
            onTap: () {
              _cancelBlack(index);
            },
            child: Container(
              width: 56,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                border: Border.all(width: 0.5, color: AppColor.mainRed),
              ),
              child: Center(
                child: Text(
                  "移除",
                  style: TextStyle(fontSize: 12, color: AppColor.mainRed),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  ///取消拉黑
  _cancelBlack(int index) async {
    bool blackStatus = await ProfileCancelBlack(blackList[index].uid);
    print('取消拉黑是否成功====================================$blackStatus');
    if (blackStatus == true) {
      Application.rongCloud.removeFromBlackList(blackList[index].uid.toString(), (code) {});
      blackList.removeAt(index);
    }
    setState(() {});
  }
}
