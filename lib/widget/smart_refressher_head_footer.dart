import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SmartRefresherHeadFooter {
  static SmartRefresherHeadFooter _headFooter;

  static SmartRefresherHeadFooter init() {
    if (_headFooter == null) {
      _headFooter = SmartRefresherHeadFooter();
    }
    return _headFooter;
  }
  TextStyle textStyle =  AppStyle.text1Regular16;
  getHeader() {
    return WaterDropHeader(
        refresh: Container(
          child: Column(
            children: [
              SizedBox(height: 20),
              // CupertinoActivityIndicator(),
              Lottie.asset(
                'assets/lottie/loading_refresh_yellow.json',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        complete: Text(""),
        failed: Text(""),
        idleIcon: Container(
          child: Column(
            children: [
              // CupertinoActivityIndicator(),
              Lottie.asset(
                'assets/lottie/loading_refresh_yellow.json',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 6),
              Text("释放刷新",style: AppStyle.text1Regular12,),
            ],
          ),
        ),
        waterDropColor: AppColor.transparent);
  }

  // 推荐用户底部
  getAttentionUserFooter() {
    return WaterDropHeader(
        refresh: Container(),
        complete: Text(""),
        failed: Text(""),
        idleIcon: Container(
          margin: EdgeInsets.only(right: 20),
          width: 40,
          height: 190,
          child: Column(
            children: [
              // RotatedBox(
              //     quarterTurns: 1,
              //   child: Text("继续滑动查看更多",style: TextStyle(color: AppColor.textHint, fontSize: 13, letterSpacing: 4, wordSpacing: 4),),
              // ),
              CustomPaint(
                painter: VerticalText(
                  text: "继续滑动查看更多",
                  textStyle: TextStyle(color: AppColor.textWhite60, fontSize: 13, letterSpacing: 4, wordSpacing: 4),
                  width: 20,
                  height: 190,
                ),
              ),
              SizedBox(height: 11.5 * 13.0),
              Container(
                // margin: EdgeInsets.only(left: 15),
                padding: EdgeInsets.only(left: 20),
                width: 40,
                height: 20,
                // color: AppColor.mainRed,
                child: Lottie.asset(
                  'assets/lottie/loading_refresh_black.json',
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                ),
              )
            ],
          ),
        ),
        waterDropColor: AppColor.transparent);
  }

  getFooter({bool isShowNoMore = true, bool isShowAddMore = true}) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = isShowAddMore ? Text("上拉加载更多",style: textStyle,) : Text("");
        } else if (mode == LoadStatus.loading) {
          body = Lottie.asset(
            'assets/lottie/loading_refresh_yellow.json',
            width: 20,
            height: 20,
            fit: BoxFit.fill,
          );
          // Container(
          //   width: 20,
          //   height: 20,
          //   child: CircularProgressIndicator(),
          // );
        } else if (mode == LoadStatus.failed) {
          body = isShowAddMore ? Text("上拉加载更多",style: textStyle,) : Text("");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("上拉加载更多",style: textStyle,);
        } else if (mode == LoadStatus.noMore) {
          body = isShowNoMore ? Text("没有更多数据了",style: textStyle,) : Text("");
        } else {
          body = Text("");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  getFooterContainer() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        return Container();
      },
    );
  }
}

// 垂直布局的文字. 从右上开始排序到左下角.
class VerticalText extends CustomPainter {
  String text;
  double width;
  double height;
  TextStyle textStyle;

  VerticalText({@required this.text, @required this.textStyle, @required this.width, @required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = new Paint();
    paint.color = textStyle.color;
    double offsetX = width;
    double offsetY = 0;
    bool newLine = true;
    double maxWidth = 0;

    maxWidth = findMaxWidth(text, textStyle);

    text.runes.forEach((rune) {
      String str = new String.fromCharCode(rune);
      TextSpan span = new TextSpan(style: textStyle, text: str);
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();

      if (offsetY + tp.height > height) {
        newLine = true;
        offsetY = 0;
      }

      if (newLine) {
        offsetX -= maxWidth;
        newLine = false;
      }

      if (offsetX < -maxWidth) {
        return;
      }

      tp.paint(canvas, new Offset(offsetX, offsetY));
      offsetY += tp.height;
    });
  }

  double findMaxWidth(String text, TextStyle style) {
    double maxWidth = 0;

    text.runes.forEach((rune) {
      String str = new String.fromCharCode(rune);
      TextSpan span = new TextSpan(style: style, text: str);
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();
      maxWidth = max(maxWidth, tp.width);
    });

    return maxWidth;
  }

  @override
  bool shouldRepaint(VerticalText oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    } else {
      return b;
    }
  }
}
