import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//获取文字size
Size getTextSize(String text, TextStyle style,int maxLine) {
  final TextPainter textPainter =
  TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLine, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
TextPainter calculateTextWidth(
    String value,TextStyle style, double maxWidth, int maxLines) {
  TextPainter painter = TextPainter(
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
          text: value,
          style:style));
  painter.layout(maxWidth: maxWidth);
  ///文字的宽度:painter.width
  return painter;
}