import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
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

//FIXME 暂时替换了颜色 可能还需要调整
//标准的黄色按钮
class CustomYellowButton extends StatefulWidget {
  //正常状态
  static const int buttonStateNormal = 0;

  //不可用状态
  static const int buttonStateDisable = 1;

  //忙碌状态
  static const int buttonStateLoading = 2;

  //禁用状态
  static const int buttonStateInvalid = 3;

  CustomYellowButton(this.text, this.buttonState, this.onTap, {Key key, this.isDarkBackground = false}) : super(key: key);

  final String text;
  final int buttonState;
  final Function() onTap;
  final bool isDarkBackground;

  @override
  _CustomYellowButtonState createState() => _CustomYellowButtonState();
}

class _CustomYellowButtonState extends State<CustomYellowButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        height: 28,
        width: widget.buttonState == CustomYellowButton.buttonStateLoading ? 82 : 60,
        decoration: BoxDecoration(
            color: widget.buttonState == CustomYellowButton.buttonStateNormal
                ? isPressed
                    ? AppColor.mainYellow.withOpacity(0.56)
                    : AppColor.mainYellow
                : widget.buttonState == CustomYellowButton.buttonStateDisable
                    ? widget.isDarkBackground
                        ? AppColor.mainYellow.withOpacity(0.24)
                        : AppColor.mainYellow.withOpacity(0.16)
                    : widget.buttonState == CustomYellowButton.buttonStateLoading
                        ? AppColor.mainYellow
                        : AppColor.textHint,
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Spacer(),
            widget.buttonState == CustomYellowButton.buttonStateLoading
                ? Container(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColor.white),
                        backgroundColor: AppColor.transparent,
                        strokeWidth: 1.5))
                : Container(),
            widget.buttonState == CustomYellowButton.buttonStateLoading
                ? SizedBox(
                    width: 4.5,
                  )
                : Container(),
            Text(
              widget.text,
              style: TextStyle(
                  fontSize: 14,
                  color: widget.buttonState == CustomYellowButton.buttonStateNormal
                      ? isPressed
                          ? AppColor.mainBlack.withOpacity(0.56)
                          : AppColor.mainBlack
                      : widget.buttonState == CustomYellowButton.buttonStateDisable
                          ? widget.isDarkBackground
                              ? AppColor.mainBlack.withOpacity(0.24)
                              : AppColor.mainBlack.withOpacity(0.16)
                          : widget.buttonState == CustomYellowButton.buttonStateLoading
                              ? AppColor.mainBlack
                              : AppColor.mainBlack),
            ),
            Spacer()
          ],
        ),
      ),
      onTapDown: (details) {
        if (widget.buttonState == CustomYellowButton.buttonStateNormal) {
          setState(() {
            isPressed = true;
          });
        }
      },
      onTapUp: (details) {
        if (widget.buttonState == CustomYellowButton.buttonStateNormal) {
          setState(() {
            isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (widget.buttonState == CustomYellowButton.buttonStateNormal) {
          setState(() {
            isPressed = false;
          });
        }
      },
      onTap: () {
        if (widget.buttonState == CustomYellowButton.buttonStateNormal) {
          widget.onTap();
        }
      },
    );
  }
}

enum FollowButtonType { FANS, FOLLOW, SERCH, COACH }

class FollowButton extends StatefulWidget {
  static double FOLLOW_BUTTON_WIDTH = 56;
  int relation;
  int id;
  FollowButtonType buttonType;
  bool isMyList;
  Function resetDataListener;
  Function(int attntionResult) onClickAttention;

  FollowButton(
      {this.relation, this.id, this.buttonType, this.isMyList = false, this.resetDataListener, this.onClickAttention});

  @override
  State<StatefulWidget> createState() {
    return _FollowButtonState();
  }
}

class _FollowButtonState extends State<FollowButton> {
  bool isMySelf = false;
  StreamController<double> streamTextController = StreamController<double>();
  bool isFollow;
  bool requestOver = true;
  bool isOfflineBool = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isFollow = widget.relation == 1 || widget.relation == 3 ? false : true;
  }

  ///请求黑名单关系
  _checkBlackStatus() async {
    if (!requestOver) {
      return;
    }
    requestOver = false;
    BlackModel model = await ProfileCheckBlack(widget.id);
    if (model != null) {
      if (model.inYouBlack == 1) {
        requestOver = true;
        ToastShow.show(msg: "关注失败，你已将对方加入黑名单", context: context);
      } else if (model.inThisBlack == 1) {
        requestOver = true;
        ToastShow.show(msg: "关注失败，你已被对方加入黑名单", context: context);
      } else {
        _getAttention(widget.id);
      }
    } else {
      requestOver = true;
      ToastShow.show(msg: "关注失败", context: context);
    }
  }

  ///这是关注
  _getAttention(int id) async {
    int attntionResult = await ProfileAddFollow(id);
    if (attntionResult == null) {
      requestOver = true;
      ToastShow.show(msg: "关注失败!", context: context);
      return;
    }
    print('关注监听=========================================$attntionResult');
    if (widget.onClickAttention != null) {
      widget.onClickAttention(attntionResult);
    }
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      context.read<UserInteractiveNotifier>().changeIsFollow(true, false, id);
      Future.delayed(Duration(milliseconds: 200), () {
        streamTextController.sink.add(1);
      });
      context.read<UserInteractiveNotifier>().changeFollowCount(id, true);
      context.read<UserInteractiveNotifier>().removeUserFollowId(id, isAdd: false);
    }
    requestOver = true;
  }

  //网络状态判断
  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (isOfflineBool) {
        isOfflineBool = false;
        if (widget.resetDataListener != null) {
          widget.resetDataListener();
        }
      }
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (isOfflineBool) {
        isOfflineBool = false;
        if (widget.resetDataListener != null) {
          widget.resetDataListener();
        }
      }
      return false;
    } else {
      isOfflineBool = true;
      return true;
    }
  }

  //按钮中动画文字
  Widget getTextAnimation() {
    if (!context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.id].isFollow) {
      streamTextController = StreamController<double>();
      return StreamBuilder<double>(
          initialData: 0,
          stream: streamTextController.stream,
          builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
            print("22222");
            return AnimatedOpacity(
              opacity: snapshot.data,
              duration: Duration(milliseconds: 300),
              child: Text(
                "已关注",
                textAlign: TextAlign.center,
                style: AppStyle.whiteRegular12,
              ),
            );
          });
    } else {
      print("1111111");
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.buttonType == FollowButtonType.COACH
              ? Text("+", style: TextStyle(color: AppColor.white, fontSize: 15))
              : Container(),
          widget.buttonType == FollowButtonType.COACH ? SizedBox(width: 5) : Container(),
          Text(
              widget.buttonType == FollowButtonType.FOLLOW ||
                      widget.buttonType == FollowButtonType.SERCH ||
                      widget.buttonType == FollowButtonType.COACH
                  ? "关注"
                  : widget.isMyList
                      ? "回粉"
                      : "关注",
              style: AppStyle.textRegular12),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<ProfileNotifier>().profile.uid == widget.id) {
      isMySelf = true;
    }
    //自己不显示
    if (isMySelf || (widget.buttonType == FollowButtonType.FOLLOW && widget.isMyList)) {
      return Container();
    }

    context.watch<UserInteractiveNotifier>().setFirstModel(widget.id, isFollow: isFollow);
    return AnimatedOpacity(
        opacity: context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.id].isFollow ? 1 : 0,
        duration: Duration(
            milliseconds:
                context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.id].isFollow ? 1 : 1000),
        child: GestureDetector(
          child: Container(
            width: 56,
            height: 24,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: AppColor.mainYellow,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Center(
              child: getTextAnimation(),
            ),
          ),
          onTap: () async {
            if (await isOffline()) {
              ToastShow.show(msg: "请检查网络!", context: context);
              return false;
            }
            if (!context.read<TokenNotifier>().isLoggedIn) {
              ToastShow.show(msg: "请先登录app!", context: context);
              AppRouter.navigateToLoginPage(context);
              return false;
            }
            if (context.read<UserInteractiveNotifier>().value.profileUiChangeModel[widget.id].isFollow) {
              _checkBlackStatus();
            }
          },
        ));
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
          activeColor: AppColor.mainYellow,
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
                            ToastShow.show(msg: "网络异常，请重试", context: context);
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
