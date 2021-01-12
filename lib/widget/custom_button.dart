import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Color textColor;//字体颜色
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
