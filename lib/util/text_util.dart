import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/util/screen_util.dart';

//获取文字size
Size getTextSize(String text, TextStyle style,int maxLine,[double width]) {
  final TextPainter textPainter =
  TextPainter(text: TextSpan(text: text, style: style), maxLines: maxLine, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth:  width != null ? width : double.infinity);
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

List<String> cutTextToList(String allText,String cutchar,startIndex,[List<String> backList]){
  List<String> list = [];
  if(backList!=null){
    list.addAll(backList);
  }
  int wrapIndex;
  wrapIndex = allText.length-1;
  if(allText.indexOf(cutchar,startIndex)!=-1){
    int wrapIndex = allText.indexOf(cutchar,startIndex);
  }
  String cutText = allText.substring(startIndex,wrapIndex);
  list.add(cutText);
  if(wrapIndex==allText.length-1){
    return list;
  }
  cutTextToList(allText, cutchar, wrapIndex, list);
}
