import 'package:flutter/material.dart';
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
          child: Row(children: _getGradeStar(score, total)),
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
