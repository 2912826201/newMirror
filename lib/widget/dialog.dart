import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/string_util.dart';
import 'package:provider/provider.dart';

/// dialog
/// Created by yangjiayi on 2020/12/31.

const double _dialogWidth = 260;
const double _outerPadding = 20;
const double _innerPadding = 16;
const double _innerPaddingTitleInfo = 8;
const double _topImageHeight = 100;
const double _circleImageSize = 90;
const double _dividerWidth = 0.5;
const double _buttonHeight = 50;

class _AppDialog extends StatelessWidget {
  final AppDialogButton confirm;
  final AppDialogButton cancel;
  final List<AppDialogButton> buttonList;
  final String title;
  final String info;
  final String circleImageUrl;
  final String topImageUrl;
  final Widget customizeWidget;
  final Color confirmColor;

  //是不是透明
  final bool isTransparentBack;

  final TextStyle infoStyle;

  final List<Widget> _viewList = [];
  PeripheralInformationPoi poi;

  _AppDialog(
      {Key key,
      this.confirm,
      this.cancel,
      this.buttonList,
      this.title,
      this.info,
      this.circleImageUrl,
      this.customizeWidget,
      this.isTransparentBack = false,
      this.topImageUrl,
      this.infoStyle,
      this.poi,
      this.confirmColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _dialogWidth,
      decoration: BoxDecoration(
        color: isTransparentBack ? AppColor.transparent : AppColor.layoutBgGrey,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, 2),
            child: Container(
              child: _buildTopImageView(),
            ),
          ),
          Container(
            decoration: isTransparentBack
                ? BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildDialogView(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDialogView(BuildContext context) {
    _viewList.clear();
    //上下的外边距交给按钮上方布局中的最上方(topImage)和最下方组件(info)控制
    //而每添加一个组件 组件需自动添加一个上方的内边距
    // _buildTopImageView();
    _buildCircleImageView();
    _buildTitle();
    _buildInfo();
    _buildCustomizeWidget();
    _buildButton(context);
    _buildButtonList(context);
    return _viewList;
  }

  _buildTopImageView() {
    //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值

    return Container(
      width: double.infinity,
      child: _getImageWidget(topImageUrl),
    );
    //
    // if (topImageUrl != null) {
    //   _viewList.add();
    // }
    // _viewList.add(SizedBox(
    //   height: _outerPadding - _innerPadding,
    // ));
  }

  _buildCircleImageView() {
    if (circleImageUrl != null) {
      _viewList.add(Padding(
        padding: const EdgeInsets.only(top: _innerPadding),
        child: Container(
          width: _dialogWidth,
          alignment: Alignment.center,
          child: Container(
            height: _circleImageSize,
            width: _circleImageSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.mainBlue),
          ),
        ),
      ));
    }
  }

  _buildTitle() {
    if (title != null) {
      _viewList.add(Padding(
        padding: const EdgeInsets.fromLTRB(_outerPadding, _innerPadding, _outerPadding, 0),
        child: Text(
          title,
          style: AppStyle.whiteRegular18,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }
  }

  _buildInfo() {
    //有标题和没标题的间距是不一样的
    if (info != null) {
      _viewList.add(Padding(
        padding: title == null
            ? const EdgeInsets.fromLTRB(_outerPadding, _innerPadding, _outerPadding, 0)
            : const EdgeInsets.fromLTRB(_outerPadding, _innerPaddingTitleInfo, _outerPadding, 0),
        child: Text(
          info,
          style: infoStyle ?? AppStyle.text1Regular16,
        ),
      ));
      //加下外边距
      _viewList.add(SizedBox(
        height: _outerPadding,
      ));
    }
  }

  _buildCustomizeWidget() {
    //判断有没有自定义的widget
    if (customizeWidget != null) {
      _viewList.add(Padding(
        padding: title == null
            ? const EdgeInsets.fromLTRB(_outerPadding, _innerPadding, _outerPadding, 0)
            : const EdgeInsets.fromLTRB(_outerPadding, _innerPaddingTitleInfo, _outerPadding, 0),
        child: customizeWidget,
      ));
    }
    //加下外边距
    _viewList.add(SizedBox(
      height: _outerPadding,
    ));
  }

  //横排的按钮
  _buildButton(BuildContext context) {
    Flexible cancelButton;
    Flexible confirmButton;
    if (cancel != null) {
      cancelButton = Flexible(
        flex: 1,
        child: GestureDetector(
            onTap: () {
              if (cancel.onClick()) {
                Navigator.pop(context);
              }
            },
            child: Container(
              //不加颜色则点击事件不会应用在整个container
              color: AppColor.transparent,
              height: _buttonHeight,
              alignment: Alignment.center,
              child: Text(
                cancel.text,
                style: AppStyle.whiteRegular18,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      );
    }

    if (confirm != null) {
      confirmButton = Flexible(
        flex: 1,
        child: GestureDetector(
            onTap: () {
              if (confirm.onClick()) {
                if (poi != null) {
                  Navigator.pop(context, poi);
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              //不加颜色则点击事件不会应用在整个container
              color: AppColor.transparent,
              height: _buttonHeight,
              alignment: Alignment.center,
              child: Text(
                confirm.text,
                style: confirmColor != null
                    ? TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: confirmColor)
                    : AppStyle.yellowRegular18,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      );
    }

    if (cancelButton != null || confirmButton != null) {
      _viewList.add(Container(
        height: _dividerWidth,
        color: AppColor.dividerWhite8,
      ));

      List<Widget> rowList = [];
      if (cancelButton != null) {
        rowList.add(cancelButton);
        if (confirmButton != null) {
          rowList.add(Container(
            width: _dividerWidth,
            height: _buttonHeight,
            color: AppColor.dividerWhite8,
          ));
        }
      }
      if (confirmButton != null) {
        rowList.add(confirmButton);
      }
      _viewList.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowList,
      ));
    }
  }

  //竖排的按钮
  _buildButtonList(BuildContext context) {
    if (buttonList != null) {
      buttonList.forEach((element) {
        _viewList.add(Container(
          height: _dividerWidth,
          color: AppColor.dividerWhite8,
        ));

        _viewList.add(GestureDetector(
            onTap: () {
              if (element.onClick()) {
                if (poi != null) {
                  Navigator.pop(context, poi);
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: Container(
              //不加颜色则点击事件不会应用在整个container
              color: AppColor.transparent,
              height: _buttonHeight,
              width: _dialogWidth,
              alignment: Alignment.center,
              child: Text(
                element.text,
                style: AppStyle.blueRegular18,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )));
      });
    }
  }

  Widget _getImageWidget(String imageUrl) {
    if (imageUrl == null) return Container();
    if (StringUtil.isURL(imageUrl))
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    if (imageUrl.startsWith("assets/png/"))
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      );
    return Container();
  }
}

// 弹窗按钮的封装类
class AppDialogButton {
  AppDialogButton(this.text, this.onClick);

  //按钮文字
  String text;

  //点击方法 返回值bool来决定是否执行完成后关闭弹窗
  bool Function() onClick;
}

showAppDialog(BuildContext context,
    {AppDialogButton confirm,
    AppDialogButton cancel,
    List<AppDialogButton> buttonList,
    String title,
    String info,
    double progress,
    TextStyle infoStyle,
    Widget customizeWidget,
    String circleImageUrl,
    String topImageUrl,
    bool isTransparentBack = false,
    bool barrierDismissible = true,
    PeripheralInformationPoi poi,
    Color confirmColor}) {
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  WillPopScope(
                      onWillPop: () async => barrierDismissible, //用来屏蔽安卓返回键关弹窗
                      child: Dialog(
                        backgroundColor: isTransparentBack ? AppColor.transparent : AppColor.layoutBgGrey,
                        elevation: isTransparentBack ? 0 : null,
                        child: _AppDialog(
                            confirm: confirm,
                            confirmColor: confirmColor,
                            cancel: cancel,
                            buttonList: buttonList,
                            title: title,
                            info: info,
                            infoStyle: infoStyle,
                            customizeWidget: customizeWidget,
                            circleImageUrl: circleImageUrl,
                            isTransparentBack: isTransparentBack,
                            poi: poi,
                            topImageUrl: topImageUrl),
                      ))
                ],
              ),
            ),
          ),
        );
      });
}
