import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mirror/constant/color.dart';

class GradeStart extends StatelessWidget {
  final double score;
  final int total;
  final Function(double score) listener;
  final bool isCanClick;
  final double size;
  final double intervalWidth;

  GradeStart(this.score, this.total, {this.listener, this.isCanClick = true, this.size = 32, this.intervalWidth = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: UnconstrainedBox(
        alignment: Alignment.center,
        child: Container(
          // child: Row(children: _getGradeStar(score, total)),
          child: RatingBar.builder(
            /// 定义要设置到评级栏的初始评级
            initialRating: score,

            /// 设置最低评级默认为 0。
            minRating: 0,
            direction: Axis.horizontal,

            /// 默认为 false。 设置 true 启用半评级支持。
            allowHalfRating: true,
            // 如果设置为 true，将禁用评分栏上的任何手势。默认为false。
            ignoreGestures: !isCanClick,

            /// 如果设置为 true，则评级栏项目在被触摸时会发光。默认为true。
            glow: isCanClick,
            // 设置大小
            itemSize: size,
            itemCount: total,
            itemPadding: EdgeInsets.symmetric(horizontal: intervalWidth / 2),
            unratedColor: AppColor.textWhite60,
            itemBuilder: (context, index) {
              return Icon(
                Icons.star,
                color: AppColor.mainYellow,
              );
            },
            // 每当评级更新时返回当前评级。
            onRatingUpdate: (rating) {
              if (isCanClick && listener != null) {
                listener(rating);
              }
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _getGradeStar(double score, int total) {
    if (score < 0 || score > total) {
      score = total.toDouble();
    }
    List<Widget> _list = [];
    for (var i = 0; i < total; i++) {
      double factor = (score - i);
      if (factor >= 1) {
        factor = 1.0;
      } else if (factor < 0) {
        factor = 0;
      }
      Widget _st = Container(
        height: size,
        width: size,
        child: Stack(
          children: <Widget>[
            Icon(
              Icons.star,
              size: size,
              color: Colors.grey,
            ),
            ClipRect(
                child: Align(
              alignment: Alignment.topLeft,
              widthFactor: factor,
                  child: Icon(
                    Icons.star,
                size: size,
                color: AppColor.mainRed,
              ),
                )),
            GestureDetector(
              onTap: () {
                _listener(i, true);
              },
              child: Container(
                color: AppColor.transparent,
                height: size,
                width: size / 2,
              ),
            ),
            Positioned(
              child: GestureDetector(
                onTap: () {
                  _listener(i, false);
                },
                child: Container(
                  color: AppColor.transparent,
                  height: size,
                  width: size / 2,
                ),
              ),
              right: 0,
            ),
          ],
        ),
      );
      _list.add(_st);
      if (i + 1 < total) {
        _list.add(SizedBox(width: intervalWidth));
      }
    }
    return _list;
  }

  //一半
  _listener(int index, bool isHalf) {
    if (isCanClick && listener != null) {
      listener(index + (isHalf ? 0.5 : 1.0));
    }
  }
}
