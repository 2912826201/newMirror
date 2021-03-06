import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui show TextStyle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/weight_records_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'monotonx.dart';

///自定义的折线图
class CustomizeLineChart extends StatefulWidget {
  final WeightRecordsModel weightDataModel;

  CustomizeLineChart({
    this.weightDataModel,
  });

  @override
  _CustomizeLineChartState createState() => _CustomizeLineChartState();
}

class _CustomizeLineChartState extends State<CustomizeLineChart> {
  List<String> xValue = [];
  double yMaxValue = 100;
  double yMinValue = 0;
  List<double> valueList = [];
  int positionSelect = 0;
  bool isPositionSelectShow = false;
  double benchmarkValue = 60;
  String benchmarkValueText = "目标60";
  EdgeInsetsGeometry margin = const EdgeInsets.all(16);
  EdgeInsetsGeometry padding = const EdgeInsets.all(0);
  double height = 244.0;
  double width = 224.0;
  double bottomHeight = 20.0;
  double topHeight = 40.0;
  int pageSize = 5;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    initPageSize();
  }

  void initPageSize() {
    valueList.clear();
    xValue.clear();
    for (int i = 0; i < widget.weightDataModel.recordList.length; i++) {
      valueList.add(widget.weightDataModel.recordList[i].weight);
      xValue.add(widget.weightDataModel.recordList[i].dateTime);
    }

    if (valueList.length >= 5) {
      pageSize = 5;
    } else {
      pageSize = valueList.length;
    }
  }

  void initData() {
    valueList.clear();
    xValue.clear();
    for (int i = 0; i < widget.weightDataModel.recordList.length; i++) {
      valueList.add(widget.weightDataModel.recordList[i].weight);
      xValue.add(widget.weightDataModel.recordList[i].dateTime);
    }
    // if (valueList.length >= 5) {
    //   pageSize = 5;
    // } else {
    //   pageSize = valueList.length;
    // }

    print("pageSize:$pageSize");

    if (widget.weightDataModel.targetWeight == null || widget.weightDataModel.targetWeight < 1) {
      benchmarkValue = -1;
      benchmarkValueText = "目标0";
    } else {
      benchmarkValue = widget.weightDataModel.targetWeight;
      benchmarkValueText = "目标$benchmarkValue";
    }
  }

  TextStyle style = AppStyle.textRegular12;

  @override
  Widget build(BuildContext context) {
    initData();
    bottomHeight = 20.0;
    width = MediaQuery.of(context).size.width;
    double canvasWidth = width - (getTextSize("${yMaxValue}kg", style, 1).width) - 36;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getYListView(),
          Expanded(
              child: SizedBox(
            child: Stack(
              children: [
                getBenchMarkLineUi(canvasWidth),
                ScrollConfiguration(
                  behavior: NoBlueEffectBehavior(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onDragNotification,
                    child: SmartRefresher(
                      enablePullDown: false,
                      enablePullUp: !(pageSize >= valueList.length),
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      footer: SmartRefresherHeadFooter.init().getFooterContainer(),
                      controller: _refreshController,
                      onLoading: () {
                        Future.delayed(Duration(milliseconds: 200), () {
                          _refreshController.loadComplete();
                          if (pageSize + 5 >= valueList.length) {
                            pageSize = valueList.length;
                          } else {
                            pageSize = pageSize + 5;
                          }
                          print("pageSize:$pageSize");
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: canvasWidth / 4 * (pageSize <= 4 ? 4 : pageSize - 1),
                          height: height,
                          child: Stack(
                            children: [
                              getPolylineUi(canvasWidth),
                              getPolylineClickItemUi(canvasWidth),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    // ScrollMetrics metrics = notification.metrics;
    // 注册通知回调
    if (notification is ScrollStartNotification) {
      if (isPositionSelectShow) {
        isPositionSelectShow = false;
        if (mounted) {
          setState(() {});
        }
      }
      // 滚动开始
      // print('滚动开始');
    } else if (notification is ScrollUpdateNotification) {
      // 滚动位置更新
      // print('滚动位置更新');
      // 当前位置
      // print("当前位置${metrics.pixels}");
    } else if (notification is ScrollEndNotification) {
      // 滚动结束
      // print('滚动结束');
    }
    return false;
  }

  //基准线的ui 折线
  Widget getBenchMarkLineUi(double canvasWidth) {
    return Container(
      width: canvasWidth,
      height: double.infinity,
      child: CustomPaint(
        size: Size(canvasWidth, double.infinity),
        painter: MyPainterBenchMarkLine(
          bottomHeight: bottomHeight,
          topHeight: topHeight,
          yMaxValue: yMaxValue,
          benchmarkValue: benchmarkValue,
          benchmarkValueText: benchmarkValueText,
        ),
      ),
    );
  }

  //折线图的ui
  Widget getPolylineUi(double canvasWidth) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: MyPainter(
          bottomHeight: bottomHeight,
          isPositionSelectShow: isPositionSelectShow,
          topHeight: topHeight,
          itemWidth: canvasWidth / 4,
          valueList: getValueList(),
          yMaxValue: yMaxValue,
          xValueText: getXValueList(),
          positionSelect: positionSelect,
          benchmarkValue: benchmarkValue,
        ),
      ),
    );
  }

  //折线图上层的点击层item
  Widget getPolylineClickItemUi(double canvasWidth) {
    double itemWidth = canvasWidth / 4;
    return Container(
      child: Transform.translate(
        offset: Offset(-4, 0),
        child: Container(
            width: pageSize == 1 ? itemWidth : double.infinity,
            height: double.infinity,
            alignment: Alignment.topCenter,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: pageSize,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                double itemWidthContainer = itemWidth;
                if (pageSize != 1 && index == 0) {
                  itemWidthContainer /= 2;
                }
                return UnconstrainedBox(
                  child: GestureDetector(
                    child: Container(
                      height: height,
                      width: itemWidthContainer,
                      color: AppColor.transparent,
                    ),
                    onTap: () {
                      positionSelect = index;
                      isPositionSelectShow = true;
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            )),
      ),
    );
  }

  List<double> getValueList() {
    if (pageSize >= valueList.length) {
      pageSize = valueList.length;
    }
    List<double> valueArray = <double>[];
    for (int i = 0; i < pageSize; i++) {
      valueArray.insert(0, valueList[i]);
    }
    return valueArray;
  }

  List<String> getXValueList() {
    if (pageSize >= xValue.length) {
      pageSize = xValue.length;
    }
    List<String> valueArray = <String>[];
    for (int i = 0; i < pageSize; i++) {
      valueArray.insert(0, xValue[i]);
    }
    return valueArray;
  }

  //获取y轴数据
  Widget getYListView() {
    yMaxValue = getYMaxValue();
    TextStyle style = AppStyle.text1Regular12;
    return Container(
      height: height,
      width: getTextSize("${yMaxValue}kg", style, 1).width,
      padding: const EdgeInsets.only(right: 6),
      child: Column(
        children: [
          Container(height: topHeight, color: Colors.transparent),
          Expanded(
              child: SizedBox(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(child: Text("${yMaxValue.toInt()}kg", style: style)),
              Container(child: Text("${(yMaxValue - (yMaxValue / 4) * 1).toInt()}kg", style: style)),
              Container(child: Text("${(yMaxValue - (yMaxValue / 4) * 2).toInt()}kg", style: style)),
              Container(child: Text("${(yMaxValue - (yMaxValue / 4) * 3).toInt()}kg", style: style)),
              Container(child: Text("0", style: style)),
            ],
          ))),
          Container(height: bottomHeight, color: Colors.transparent),
        ],
      ),
    );
  }

  //获取y轴的最大值
  double getYMaxValue() {
    double maxValue = 0;
    if (pageSize >= valueList.length) {
      pageSize = valueList.length;
    }

    for (int i = 0; i < pageSize; i++) {
      double n = valueList[i];
      if (n > maxValue) {
        maxValue = n;
      }
    }

    if (benchmarkValue > maxValue) {
      maxValue = benchmarkValue;
    }

    if (maxValue <= 100) {
      return 100.0;
    } else if (maxValue < 1000) {
      return (maxValue ~/ 100 + 1) * 100.0;
    } else {
      int len = maxValue.toInt().toString().length;
      return (maxValue ~/ (pow(10, (len - 2))) + 1) * (pow(10, (len - 2))) * 1.0;
    }
  }
}

class MyPainter extends CustomPainter {
  double bottomHeight;
  double topHeight;
  List<double> valueList;
  double itemWidth;
  double benchmarkValue;
  double yMaxValue;
  List<String> xValueText;
  int positionSelect;
  bool isPositionSelectShow;

  MyPainter({
    this.bottomHeight,
    this.isPositionSelectShow = false,
    this.topHeight,
    this.itemWidth,
    this.valueList,
    this.yMaxValue,
    this.xValueText,
    this.benchmarkValue,
    this.positionSelect = -1,
  });

  Paint bgLinePaint;
  Paint pointPaint;
  Paint cirLinePaint;
  Paint alertBgPaint;
  Paint alertBgBorderPaint;
  Paint cirPlanPaint;
  double pointRadius = 5.0;
  double yTextSize = 12.0;
  int itemCountPage = 4;
  List<Point> points = [];

  double minValue;
  double maxValue;

  void initPaint(Size size) {
    bgLinePaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 1 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.dividerWhite8 // 画笔颜色
      ..style = PaintingStyle.fill;

    pointPaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 2 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.mainRed // 画笔颜色
      ..style = PaintingStyle.fill; //是否填充

    alertBgPaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 10 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.white // 画笔颜色
      ..style = PaintingStyle.fill; //是否填充

    alertBgBorderPaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 1 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.mainRed.withOpacity(0.60) // 画笔颜色
      ..style = PaintingStyle.stroke; //是否填充

    cirLinePaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 2 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.mainRed // 画笔颜色
      ..style = PaintingStyle.stroke; //是否填充

    final Color startColor = AppColor.mainRed.withOpacity(0.24);
    final Color endColor = AppColor.mainRed.withOpacity(0);
    final gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.mirror,
      colors: [startColor, endColor],
    );

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height - bottomHeight);
    cirPlanPaint = Paint() // 创建一个画笔并配置其属性
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 1 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.mainRed // 画笔颜色
      ..style = PaintingStyle.fill; //是否填充
  }

  //获取每一个点的位置
  void initPoints(Size size) {
    if (points != null && points.length > 0) {
      return;
    }
    if (valueList.length == 1) {
      double yValue = getPointHeight(valueList[0], size);
      points.add(new Point(size.width / 2, yValue));
    } else {
      for (int i = 0; i < valueList.length; i++) {
        double xValue = i * itemWidth;
        double yValue = getPointHeight(valueList[i], size);
        if (xValue == 0) {
          xValue = pointRadius + minValue;
        }
        if (xValue == size.width) {
          xValue = size.width - pointRadius - minValue;
        }
        points.add(new Point(xValue, yValue));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("开始绘制");
    minValue = pointRadius / 2;
    maxValue = size.width - pointRadius / 2;

    //初始化画笔
    initPaint(size);
    //初始化点
    initPoints(size);
    //绘制渐变色
    canvasCirclePlan(canvas, size);
    //这是背景
    // canvasBgLine(canvas, size);
    //绘制三次贝塞尔曲线
    canvasCircleLine(canvas, size);
    //绘制线上的点
    canvasPoint(canvas, size);
    //绘制x轴
    canvasBottomText(canvas, size);
    //绘制提示文字
    canvasAlertText(canvas, size);
  }

  //绘制提示冒泡
  void canvasAlertText(Canvas canvas, Size size) {
    if (!isPositionSelectShow) {
      return;
    }
    if (positionSelect < 0 || positionSelect >= points.length) {
      return;
    }
    drawAlertBg(canvas, size);
  }

  //绘制提示背景
  void drawAlertBg(Canvas canvas, Size size) {
    if (xValueText == null || positionSelect >= xValueText.length) {
      return;
    }
    double x = points[positionSelect].x - 63 / 2;
    double lineX = points[positionSelect].x;
    if (points.length != 1) {
      if (positionSelect == 0) {
        x = 3;
        lineX -= pointRadius / 2;
      } else if (points.length < 5) {
        x -= pointRadius / 2;
        lineX += pointRadius / 2;
      } else if (positionSelect == points.length - 1) {
        x = size.width - 64;
        lineX += pointRadius / 2;
      }
    } else {
      x -= pointRadius / 2;
      lineX -= pointRadius / 2;
    }

    if (points.length < 5 && positionSelect != 0 && positionSelect != points.length - 1) {
      lineX -= 2;
    }

    double y = points[positionSelect].y - 28 - pointRadius / 2 - 8;

    //先绘制提示的竖线条
    drawAlertLine(canvas, lineX, size);

    //绘制提示文字的背景
    canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + 63, y)
          ..lineTo(x + 63, y + 28)
          ..lineTo(x, y + 28)
          ..lineTo(x, y)
          ..close(),
        alertBgPaint);
    //绘制提示文字的背景边框
    canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + 63, y)
          ..lineTo(x + 63, y + 28)
          ..lineTo(x, y + 28)
          ..lineTo(x, y)
          ..close(),
        alertBgBorderPaint);

    //绘制提示文字--体重
    drawAlertText(canvas, x, y, 63, 28);
  }

  //绘制提示的线条
  void drawAlertLine(Canvas canvas, double x, Size size) {
    var dashWidth = 5;
    var dashSpace = 2;
    final space = (dashSpace + dashWidth);
    double startY = getPointHeight(yMaxValue, size);
    double maxValue = getPointHeight(0.0, size);
    while (startY < maxValue) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashWidth), alertBgBorderPaint);
      startY += space;
    }
  }

  //绘制提示文字
  void drawAlertText(Canvas canvas, double x, double y, double width, double height) {
    ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 12.0,
    ));
    pb.pushStyle(ui.TextStyle(color: AppColor.mainBlack, fontWeight: FontWeight.w500));
    if (valueList == null || positionSelect >= valueList.length) {
      return;
    } else {
      pb.addText("${valueList[positionSelect]}kg");
    }
    double textWidth = getTextSize("${valueList[positionSelect]}kg", AppStyle.textMedium14, 1).width;
    ParagraphConstraints pc = ParagraphConstraints(width: textWidth);
    Paragraph paragraph = pb.build()
      ..layout(pc);
    double xValue = x + width / 2 - textWidth / 2;
    double yValue = y + height / 2 - 6;
    Offset offset = Offset(xValue, yValue);
    canvas.drawParagraph(paragraph, offset); /**/
  }

  //绘制底部文字---x轴
  void canvasBottomText(Canvas canvas, Size size) {
    //画文字
    for (int i = 0; i < points.length; i++) {
      ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.left,
        fontStyle: FontStyle.italic,
        fontSize: 12.0,
      ));
      pb.pushStyle(ui.TextStyle(color: AppColor.textWhite60));

      String text;
      if (xValueText == null || i >= xValueText.length) {
        pb.addText("");
        text = "";
      } else {
        String newValue = xValueText[i];
        String lastValue = xValueText[(i - 1) < 0 ? 0 : (i - 1)];
        text = getBottomTexT(newValue, lastValue);
        pb.addText(text);
      }
      TextStyle textStyle = TextStyle(color: AppColor.textWhite60);
      double textWidth = getTextSize(text, textStyle, 1).width;
      ParagraphConstraints pc = ParagraphConstraints(width: textWidth);
      Paragraph paragraph = pb.build()
        ..layout(pc);
      double xValue = points[i].x - textWidth / 2 + 4;
      if (i == points.length - 1) {
        xValue -= 8;
      }
      Offset offset = Offset(xValue, getPointHeight(0.0, size) + 14);
      canvas.drawParagraph(paragraph, offset); /**/
    }
  }

  String getBottomTexT(String newValue, String lastValue) {
    if (newValue == null) {
      return "";
    }
    try {
      DateTime newTime = DateUtil.stringToDateTime(newValue);
      if (lastValue != null) {
        DateTime lastTime = DateUtil.stringToDateTime(lastValue);
        if (newTime.year == lastTime.year) {
          return "${newTime.month}.${newTime.day}";
        } else {
          return "${newTime.year}./${newTime.month}.${newTime.day}";
        }
      } else {
        return "${newTime.month}.${newTime.day}";
      }
    } catch (e) {
      return "";
    }
  }

  //绘制三次贝塞尔曲线填充
  void canvasCirclePlan(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }
    List<Point> pointArray = [];

    pointArray.add(new Point(minValue, points[0].y));
    pointArray.addAll(points);
    if (points.length >= 5) {
      pointArray.add(new Point(maxValue, points[points.length - 1].y));
      pointArray.add(new Point(maxValue, getPointHeight(0.0, size)));
    } else {
      pointArray.add(new Point(points[points.length - 1].x + pointRadius / 2, points[points.length - 1].y));
      pointArray.add(new Point(points[points.length - 1].x + pointRadius / 2, getPointHeight(0.0, size)));
    }
    pointArray.add(new Point(minValue, getPointHeight(0.0, size)));

    _drawSmoothLine(canvas, cirPlanPaint, pointArray);
  }

  //绘制三次贝塞尔曲线
  void canvasCircleLine(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }
    List<Point> pointArray = [];
    pointArray.add(new Point(minValue, points[0].y));
    pointArray.addAll(points);
    if (points.length >= 5) {
      pointArray.add(new Point(maxValue, points[points.length - 1].y));
    } else {
      pointArray.add(new Point(points[points.length - 1].x + pointRadius / 2, points[points.length - 1].y));
    }
    _drawSmoothLine(canvas, cirLinePaint, pointArray);
  }

  //画每一个点
  void canvasPoint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      double xValue = points[i].x;
      double yValue = points[i].y;

      if (i == 0) {
        xValue -= pointRadius / 2;
      } else if (i == points.length - 1) {
        xValue += pointRadius / 2;
      }

      if (positionSelect != i || !isPositionSelectShow) {
        pointPaint.color = AppColor.mainRed;
        canvas.drawCircle(Offset(xValue, yValue), pointRadius, pointPaint);
        pointPaint.color = AppColor.white;
        canvas.drawCircle(Offset(xValue, yValue), pointRadius - 2, pointPaint);
      } else {
        pointPaint.color = AppColor.white;
        canvas.drawCircle(Offset(xValue, yValue), pointRadius + 2, pointPaint);
        pointPaint.color = AppColor.mainRed;
        canvas.drawCircle(Offset(xValue, yValue), pointRadius, pointPaint);
      }
    }
  }

  //获取每一个点的高度
  double getPointHeight(double value, Size size) {
    double len = size.height - bottomHeight - topHeight - yTextSize;
    return len * ((yMaxValue - value) / yMaxValue) + 6 + topHeight;
  }

  //画背景虚线
  void canvasBgLine(Canvas canvas, Size size) {
    for (int i = 0; i < itemCountPage; i++) {
      double lineHeight = (i * ((size.height - bottomHeight - topHeight - yTextSize) / itemCountPage) + 6 + topHeight);
      canvasDottedLine(0.0, size.width, lineHeight, canvas, bgLinePaint);
    }
    canvasDottedLine(0.0, size.width, size.height - bottomHeight - 6, canvas, bgLinePaint);
  }

  //画虚线
  void canvasDottedLine(double startX, double endX, double yValue, Canvas canvas, Paint paint) {
    var dashWidth = 5;
    var dashSpace = 2;
    final space = (dashSpace + dashWidth);
    while (startX < endX) {
      canvas.drawLine(Offset(startX, yValue), Offset(startX + dashWidth, yValue), paint);
      startX += space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  //绘制三次贝塞尔曲线
  void _drawSmoothLine(Canvas canvas, Paint paint, List<Point> points) {
    final path = new Path()..moveTo(points.first.x.toDouble(), points.first.y.toDouble());
    MonotoneX.addCurve(path, points);
    canvas.drawPath(path, paint);
  }
}

///基准线
class MyPainterBenchMarkLine extends CustomPainter {
  double bottomHeight;
  double topHeight;
  double benchmarkValue;
  double yMaxValue;
  String benchmarkValueText;

  MyPainterBenchMarkLine({
    this.bottomHeight,
    this.topHeight,
    this.yMaxValue,
    this.benchmarkValue,
    this.benchmarkValueText,
  });

  Paint benchmarkLinePaint;
  double yTextSize = 12.0;
  int itemCountPage = 4;
  Paint bgLinePaint;

  void initPaint(Size size) {
    benchmarkLinePaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 1 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.dividerWhite8 // 画笔颜色
      ..style = PaintingStyle.fill;

    bgLinePaint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 1 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color = AppColor.dividerWhite8 // 画笔颜色
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    initPaint(size);
    canvasBgLine(canvas, size);
    canvasBenchmarkLine(canvas, size);
    canvasText(canvas, size);
  }

  //画背景虚线
  void canvasBgLine(Canvas canvas, Size size) {
    for (int i = 0; i < itemCountPage; i++) {
      double lineHeight = (i * ((size.height - bottomHeight - topHeight - yTextSize) / itemCountPage) + 6 + topHeight);
      canvasDottedLine(0.0, size.width, lineHeight, canvas, bgLinePaint);
    }
    canvasDottedLine(0.0, size.width, size.height - bottomHeight - 6, canvas, bgLinePaint);
  }

  void canvasText(Canvas canvas, Size size) {
    if (benchmarkValue > yMaxValue || benchmarkValue < 0) {
      return;
    }
    ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 12.0,
    ));
    pb.pushStyle(ui.TextStyle(color: AppColor.textWhite60, fontWeight: FontWeight.w500));
    pb.addText(benchmarkValueText);
    ParagraphConstraints pc = ParagraphConstraints(width: 60);
    Paragraph paragraph = pb.build()
      ..layout(pc);
    double xValue = size.width - 60;
    Offset offset = Offset(xValue, getPointHeight(benchmarkValue, size) - 23);
    canvas.drawParagraph(paragraph, offset); /**/
  }

  //绘制基准线
  void canvasBenchmarkLine(Canvas canvas, Size size) {
    if (benchmarkValue > yMaxValue || benchmarkValue < 0) {
      return;
    }
    canvasDottedLine(0, size.width, getPointHeight(benchmarkValue, size), canvas, benchmarkLinePaint);
  }

  //获取每一个点的高度
  double getPointHeight(double value, Size size) {
    double len = size.height - bottomHeight - topHeight - yTextSize;
    return len * ((yMaxValue - value) / yMaxValue) + 6 + topHeight;
  }

  //画虚线
  void canvasDottedLine(double startX, double endX, double yValue, Canvas canvas, Paint paint) {
    var dashWidth = 5;
    var dashSpace = 2;
    final space = (dashSpace + dashWidth);
    while (startX < endX) {
      canvas.drawLine(Offset(startX, yValue), Offset(startX + dashWidth, yValue), paint);
      startX += space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
