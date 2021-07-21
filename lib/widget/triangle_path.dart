

import 'package:flutter/cupertino.dart';
//配合ClipPath实现三角形
class TrianglePath extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width/2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
class TrianglePainter extends CustomPainter {
  Color color;
  Paint _paint;
  Path _path;
  double angle;

  TrianglePainter(this.color) {
    _paint = Paint()
      ..strokeWidth = 1.0
      ..color = color
      ..isAntiAlias = true;

    _path = Path();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.5;
    //三角形
    _path.moveTo(baseX - 0.86 * baseX, 0.5 * baseY);
    _path.lineTo(baseX, 1.5 * baseY);
    _path.lineTo(baseX + 0.86 * baseX, 0.5 * baseY);
    canvas.drawPath(_path, _paint);
  }
}