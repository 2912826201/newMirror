
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
//三角形
class TrianglePath extends CustomPainter {
  bool isDown;
  Color color;

  TrianglePath(this.isDown, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    if (isDown) {
      canvas.drawPath(Path()
          ..moveTo(size.width / 2, size.height)
          ..lineTo(0, 0)
          ..lineTo(size.width, 0)
          ..close()
          , _paint);
    } else {
      canvas.drawPath(
          Path()
            ..moveTo(size.width / 2, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..close(),
          _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//扫码矩形边角
class ScanWeaponPainter extends CustomPainter {
  int type;

  ScanWeaponPainter(this.type);

  Paint _paint = Paint()
    ..color = AppColor.textWhite60
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 1:
        canvas.drawPath(
            Path()
              ..moveTo(0, size.height)
              ..lineTo(0, 0)
              ..lineTo(size.height, 0),
            _paint);
        break;
      case 2:
        canvas.drawPath(
            Path()
              ..moveTo(0,0)
              ..lineTo(size.height, 0)
              ..lineTo(size.height, size.height),
            _paint);
        break;
      case 3:
        canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..lineTo(0, size.height)
              ..lineTo(size.height, size.height),
            _paint);
        break;
      case 4:
        canvas.drawPath(
            Path()
              ..moveTo(size.height, 0)
              ..lineTo(size.height, size.height)
              ..lineTo(0, size.height),
            _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}