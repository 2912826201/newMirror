import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class GradeStart extends StatelessWidget {
  final double score;
  final int total;
  final Function(double score) listener;

  GradeStart(this.score, this.total, this.listener);

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
    List<Widget> _list = [];
    for (var i = 0; i < total; i++) {
      double factor = (score - i);
      if (factor >= 1) {
        factor = 1.0;
      } else if (factor < 0) {
        factor = 0;
      }
      Widget _st = Container(
        height: 32,
        width: 32,
        child: Stack(
          children: <Widget>[
            Icon(
              Icons.star,
              size: 32,
              color: Colors.grey,
            ),
            ClipRect(
                child: Align(
              alignment: Alignment.topLeft,
              widthFactor: factor,
              child: Icon(
                Icons.star,
                size: 32,
                color: AppColor.mainRed,
              ),
            )),
            GestureDetector(
              onTap: () {
                _listener(i, true);
              },
              child: Container(
                color: AppColor.transparent,
                height: 32,
                width: 16,
              ),
            ),
            Positioned(
              child: GestureDetector(
                onTap: () {
                  _listener(i, false);
                },
                child: Container(
                  color: AppColor.transparent,
                  height: 32,
                  width: 16,
                ),
              ),
              right: 0,
            ),
          ],
        ),
      );
      _list.add(_st);
      if (i + 1 < total) {
        _list.add(SizedBox(width: 20));
      }
    }
    return _list;
  }

  //一半
  _listener(int index, bool isHalf) {
    if (listener != null) {
      listener(index + (isHalf ? 0.5 : 1.0));
    }
  }
}
