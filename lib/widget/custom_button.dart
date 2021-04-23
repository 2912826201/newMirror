import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
// 自定义按钮

/*
 *只有文字的button
 */
class TextBtn extends StatelessWidget {
  TextBtn({
    Key key,
    this.onTap,
    this.textColor,
    this.title,
    this.width,
    this.height,
    this.backColor = Colors.transparent,
    this.fontsize = 15.0,
    this.borderColor = Colors.transparent,
    this.circular = 0.0,
    this.padding,
    this.borderWidth,
  }) : super(key: key);
  final onTap;
  final width; //整体宽
  final height; //整体高
  final backColor; //背景颜色
  final circular; //弧度
  double borderWidth;
  Color borderColor;
  Color textColor;
  String title;
  double fontsize;
  EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backColor,
          border: Border.all(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(circular),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontsize,
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/*
 *点击带边框按钮
 */
class ClickLineBtn extends StatelessWidget {
  ClickLineBtn(
      {Key key,
      this.color,
      this.title,
      this.onTap,
      this.circular,
      this.width,
      this.backColor,
      this.height,
      this.fontSize = 15.0,
      this.textColor})
      : super(key: key);

  Color color; //颜色
  Color textColor; //字体颜色
  String title; //文字
  final onTap; //点击方法
  final circular; //弧度
  double width; //整体宽
  final backColor; //背景颜色
  double height; //整体高
  double fontSize; //文字大小

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
        decoration: BoxDecoration(
          color: backColor,
          border: Border.all(width: 1, color: color),
          borderRadius: BorderRadius.circular(circular),
        ),
      ),
    );
  }
}

/*
 *图片的点击按钮  iconBtn
 */
class MyIconBtn extends StatelessWidget {
  MyIconBtn({
    Key key,
    this.iconSting,
    this.onPressed,
    this.width,
    this.height,
  }) : super(key: key);

  final iconSting; //图片的地址
  final onPressed; //执行的方法
  double width; //宽
  double height; //高

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(iconSting),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

/*
 *图片 + 文字按钮  icon在左 tiitle在右
 */

class ClickImageAndTitleBtn extends StatelessWidget {
  ClickImageAndTitleBtn(
      {Key key, this.image, this.imageSize, this.title, this.padding, this.fontSize, this.textColor, this.onTap})
      : super(key: key);
  Widget image; //image
  Size imageSize; //image的宽高
  String title; //文字
  double padding; //图片和文字之间的间距
  double fontSize; //文字的大小
  Color textColor; //文字的颜色
  final onTap; //执行的方法
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: ScreenAdapt.widthX2(widget.width),
        // height: ScreenAdapt.widthX2(widget.height),
        alignment: Alignment.center,
        child: Row(
          children: [
            Container(
              width: imageSize.width,
              height: imageSize.height,
              child: image,
            ),
            SizedBox(
              width: padding,
            ),
            Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
 * iconbutton  icon在上  文字在下
 */
class ExamIndexIconButton extends StatelessWidget {
  ExamIndexIconButton({Key key, this.action, this.icon, this.title}) : super(key: key);
  final action;
  String icon;
  String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white.withAlpha(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 30,
              height: 30,
              // color: Colors.green,
              child: Image.asset(
                icon,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 12, bottom: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF3B3B3B),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: action,
    );
  }
}

/*
*图片 + 文字按钮 tiitle在左 icon在右
*/

class ClickTitleAndImageBtn extends StatelessWidget {
  ClickTitleAndImageBtn(
      {Key key, this.image, this.imageSize, this.title, this.padding = 0, this.fontSize, this.textColor, this.onTap})
      : super(key: key);
  Widget image; //image
  Size imageSize; //image的宽高
  String title; //文字
  double padding; //图片和文字之间的间距
  double fontSize; //文字的大小
  Color textColor; //文字的颜色
  final onTap; //执行的方法
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: ScreenAdapt.widthX2(widget.width),
        // height: ScreenAdapt.widthX2(widget.height),
        alignment: Alignment.center,
        child: Row(
          children: [
            Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(
              width: padding,
            ),
            Container(
              width: imageSize.width,
              height: imageSize.height,
              child: image,
            ),
          ],
        ),
      ),
    );
  }
}

//标准的红色按钮
class CustomRedButton extends StatefulWidget {
  //正常状态
  static const int buttonStateNormal = 0;

  //不可用状态
  static const int buttonStateDisable = 1;

  //忙碌状态
  static const int buttonStateLoading = 2;

  //禁用状态
  static const int buttonStateInvalid = 3;

  CustomRedButton(this.text, this.buttonState, this.onTap, {Key key, this.isDarkBackground = false}) : super(key: key);

  final String text;
  final int buttonState;
  final Function() onTap;
  final bool isDarkBackground;

  @override
  _CustomRedButtonState createState() => _CustomRedButtonState();
}

class _CustomRedButtonState extends State<CustomRedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        height: 28,
        width: widget.buttonState == CustomRedButton.buttonStateLoading ? 82 : 60,
        decoration: BoxDecoration(
            color: widget.buttonState == CustomRedButton.buttonStateNormal
                ? isPressed
                    ? AppColor.mainRed.withOpacity(0.56)
                    : AppColor.mainRed
                : widget.buttonState == CustomRedButton.buttonStateDisable
                    ? widget.isDarkBackground
                        ? AppColor.mainRed.withOpacity(0.24)
                        : AppColor.mainRed.withOpacity(0.16)
                    : widget.buttonState == CustomRedButton.buttonStateLoading
                        ? AppColor.mainRed
                        : AppColor.textHint,
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Spacer(),
            widget.buttonState == CustomRedButton.buttonStateLoading
                ? Container(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColor.white),
                        backgroundColor: AppColor.transparent,
                        strokeWidth: 1.5))
                : Container(),
            widget.buttonState == CustomRedButton.buttonStateLoading
                ? SizedBox(
                    width: 4.5,
                  )
                : Container(),
            Text(
              widget.text,
              style: TextStyle(
                  fontSize: 14,
                  color: widget.buttonState == CustomRedButton.buttonStateNormal
                      ? isPressed
                          ? AppColor.white.withOpacity(0.56)
                          : AppColor.white
                      : widget.buttonState == CustomRedButton.buttonStateDisable
                          ? widget.isDarkBackground
                              ? AppColor.white.withOpacity(0.24)
                              : AppColor.white.withOpacity(0.16)
                          : widget.buttonState == CustomRedButton.buttonStateLoading
                              ? AppColor.white
                              : AppColor.white),
            ),
            Spacer()
          ],
        ),
      ),
      onTapDown: (details) {
        if (widget.buttonState == CustomRedButton.buttonStateNormal) {
          setState(() {
            isPressed = true;
          });
        }
      },
      onTapUp: (details) {
        if (widget.buttonState == CustomRedButton.buttonStateNormal) {
          setState(() {
            isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (widget.buttonState == CustomRedButton.buttonStateNormal) {
          setState(() {
            isPressed = false;
          });
        }
      },
      onTap: () {
        if (widget.buttonState == CustomRedButton.buttonStateNormal) {
          widget.onTap();
        }
      },
    );
  }
}

enum FollowButtonType { FANS, FOLLOW, SERCH, TOPIC }

class FollowButton extends StatefulWidget {
  static double FOLLOW_BUTTON_WIDTH = 56;
  bool isFollow;
  int id;
  FollowButtonType buttonType;
  bool isMysList;
  int type;
  FollowButton({this.isFollow, this.id, this.buttonType, this.isMysList, this.type});

  @override
  State<StatefulWidget> createState() {
    return _FollowButtonState();
  }
}

class _FollowButtonState extends State<FollowButton> {
  bool isMySelf = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ///请求黑名单关系
  _checkBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(widget.id);
    if (model != null) {
      if (model.inYouBlack == 1) {
        ToastShow.show(msg: "关注失败，你已将对方加入黑名单", context: context);
      } else if (model.inThisBlack == 1) {
        ToastShow.show(msg: "关注失败，你已被对方加入黑名单", context: context);
      } else {
        _getAttention(widget.id);
      }
    }else{
      ToastShow.show(msg: "关注失败", context: context);
    }
  }

  ///这是关注
  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      context.read<UserInteractiveNotifier>().changeIsFollow(true, false, id);
      context.read<UserInteractiveNotifier>().changeFollowCount(id, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<ProfileNotifier>().profile.uid == widget.id) {
      isMySelf = true;
    }
    if (isMySelf ||
        (widget.buttonType == FollowButtonType.FOLLOW && widget.isMysList) ||
        widget.buttonType == FollowButtonType.TOPIC) {
      return Container();
    }
    context.watch<UserInteractiveNotifier>().setFirstModel(widget.id, isFollow: !widget.isFollow);
    return GestureDetector(
      child: Container(
        width: 56,
        height: 24,
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].isFollow
              ? AppColor.textPrimary1
              : AppColor.transparent,
          borderRadius: BorderRadius.all(Radius.circular(14)),
          border: Border.all(
              width: context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].isFollow ? 0.5 : 0.0),
        ),
        child: Center(
          child: Text(
              context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].isFollow
                  ? widget.buttonType == FollowButtonType.FOLLOW || widget.buttonType == FollowButtonType.SERCH
                      ? "关注"
                      : widget.isMysList
                          ? "回粉"
                          : "关注"
                  : "已关注",
              style: context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.id].isFollow
                  ? AppStyle.whiteRegular12
                  : AppStyle.textSecondaryRegular12),
        ),
      ),
      onTap: () {
        if (!context.read<TokenNotifier>().isLoggedIn) {
          ToastShow.show(msg: "请先登录", context: context);
          AppRouter.navigateToLoginPage(context);
          return false;
        }
        if (context.read<UserInteractiveNotifier>().profileUiChangeModel[widget.id].isFollow) {
          _checkBlackStatus();
        }
      },
    );
  }
}

enum SelectOverType { OK, ERROE, COMPLET }

class SelectButton extends StatefulWidget {
  //选中未选中·
  bool selectOrNot;

  //有返回值的回调方法，返回true表示网络请求成功,反之则是失败按钮切换回移动之前的状态
  Future<bool> Function(bool) changeCallBack;

  //间隔时间
  int intervalsMilliseconds;
  bool canOnClick;
  SelectOverType selectOverType;

  SelectButton(this.selectOrNot,
      {this.changeCallBack, this.intervalsMilliseconds = 1000, this.canOnClick = true, this.selectOverType});

  @override
  State<StatefulWidget> createState() {
    return _SelectButtonState();
  }
}

class _SelectButtonState extends State<SelectButton> {
  bool beforSelect;
  int beforTimer = DateTime.now().millisecondsSinceEpoch;
  bool isFrist = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          activeColor: AppColor.mainRed,
          value: widget.selectOrNot,
          onChanged: widget.canOnClick
              ? (value) {
                  setState(() {
                    widget.selectOrNot = value;
                  });
                  if (isFrist) {
                    widget.changeCallBack(widget.selectOrNot).then((callBack) {
                      if (callBack != null && callBack) {
                        beforSelect = value;
                      } else {
                        beforSelect = !widget.selectOrNot;
                        widget.selectOrNot = !widget.selectOrNot;
                        setState(() {});
                      }
                    });
                    beforTimer = DateTime.now().millisecondsSinceEpoch;
                    isFrist = false;
                    return;
                  }
                  if (DateTime.now().millisecondsSinceEpoch - beforTimer >= widget.intervalsMilliseconds) {
                    beforTimer = DateTime.now().millisecondsSinceEpoch;
                    Future.delayed(Duration(milliseconds: widget.intervalsMilliseconds), () {
                      if (beforSelect != widget.selectOrNot) {
                        widget.changeCallBack(widget.selectOrNot).then((callBack) {
                          if (callBack != null && callBack) {
                            beforSelect = widget.selectOrNot;
                          } else {
                            widget.selectOrNot = !widget.selectOrNot;
                            setState(() {});
                          }
                        });
                      }
                    });
                  }
                }
              : null,
        ));
  }
}
