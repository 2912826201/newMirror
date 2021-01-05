
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/user_notice_model.dart';
import 'package:mirror/util/screen_util.dart';


///通知设置
class NoticeSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _noticeSettingState();
  }
}

class _noticeSettingState extends State<NoticeSettingPage> {
  bool getNoticeIsOpen = false;
  //未关注私信人
  bool notFollow = false;
  //我关注及好友私信
  bool FollowBuddy = false;
  //@我
  bool mentionedMe = false;
  //评论
  bool comment = false;

    //设置用户通知设置
  _setUserNotice(int type, int isOpen) async {
    var noticeState = await setUserNotice(type, isOpen);
    if (noticeState != null) {
      if(noticeState){
        switch (type) {
          case 0:
            if (notFollow) {
              setState(() {
                notFollow = false;
              });
            } else {
              setState(() {
                notFollow = true;
              });
            }
            break;
          case 1:
            if (FollowBuddy) {
              setState(() {
                FollowBuddy = false;
              });
            } else {
              setState(() {
                FollowBuddy = true;
              });
            }
            break;
          case 2:
            if (mentionedMe) {
              setState(() {
                mentionedMe = false;
              });
            } else {
              setState(() {
                mentionedMe = true;
              });
            }
            break;
          case 3:
            if (comment) {
              setState(() {
                comment = false;
              });
            } else {
              setState(() {
                comment = true;
              });
            }
            break;
        }
      }

    }
  }
    //获取用户通知设置
  _getUserNotice() async {
    UserNoticeModel model = await getUserNotice();
    if (model != null) {
      model.list.forEach((element) {
        switch (element.type) {
          case 0:
            if (element.isOpen == 0) {
              notFollow = false;
            } else {
              notFollow = true;
            }
            break;
          case 1:
            if (element.isOpen == 0) {
              FollowBuddy = false;
            } else {
              FollowBuddy = true;
            }
            break;
          case 2:
            if (element.isOpen == 0) {
              mentionedMe = false;
            } else {
              mentionedMe = true;
            }
            break;
          case 3:
            if (element.isOpen == 0) {
              comment = false;
            } else {
              comment = true;
            }
        }
      });
      setState(() {
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserNotice();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
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
          "通知设置",
          style: AppStyle.textMedium18,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        width: width,
        height: height,
        child: Column(
          children: [
            _getNotice(),
            Container(
              height: 0.5,
              color: AppColor.bgWhite,
              width: width,
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 32,
              width: width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "私信通知",
                  style: AppStyle.textSecondaryRegular14,
                ),
              ),
            ),
            _switchRow(width, 0, notFollow, "未关注私信人"),
            _switchRow(width, 1, FollowBuddy, "我关注及好友私信"),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 32,
              width: width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "互动通知",
                  style: AppStyle.textSecondaryRegular14,
                ),
              ),
            ),
            _switchRow(width, 2, mentionedMe, "@我"),
            _switchRow(width, 3, comment, "评论"),
          ],
        ),
      ),
    );
  }

  ///接收通知设置
  Widget _getNotice() {
    return Container(
      height: 48,
      child: Center(
        child: Row(
          children: [
            Text(
              "接收推送通知",
              style: AppStyle.textRegular16,
            ),
            Expanded(child: Container()),
            Text(
              getNoticeIsOpen ? "已开启" : "未开启",
              style: AppStyle.textHintRegular16,
            ),
            SizedBox(
              width: 12,
            ),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }

  Widget _switchRow(double width, int type, bool isOpen, String title) {
    return Container(
      height: 48,
      width: width,
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: AppStyle.textRegular16,
            ),
            Expanded(child: SizedBox()),
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
              activeColor: AppColor.mainRed,
              value: isOpen,
              onChanged: (bool value) {
                setState(() {
                  switch (type) {
                    case 0:
                        _setUserNotice(0, notFollow ? 0 : 1);
                      break;
                    case 1:
                        _setUserNotice(1, FollowBuddy ? 0 : 1);
                      break;
                    case 2:
                        _setUserNotice(2, mentionedMe ? 0 : 1);
                      break;
                    case 3:
                        _setUserNotice(3, comment ? 0 : 1);
                      break;
                  }
                });
              },
            ),
            ),
          ],
        ),
      ),
    );
  }
}
