import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeftScrollItem extends StatefulWidget {
  final Function(String title) onTap;
  final String text;
  final TextStyle textStyle;
  final Color color;

  const LeftScrollItem({
    Key key,
    this.onTap,
    this.text,
    this.color,
    this.textStyle,
  }) : super(key: key);

  @override
  _LeftScrollItemState createState() => _LeftScrollItemState();
}

class _LeftScrollItemState extends State<LeftScrollItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        // width: 80,
        color: widget.color,
        child: Text(
          widget.text,
          style: widget.textStyle,
        ),
      ),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap(widget.text);
        }
      },
    );
  }
}

// class LeftScrollItem extends StatelessWidget {
//   final Function(String title) onTap;
//   final String text;
//   final Color textColor;
//   final Color color;
//   const LeftScrollItem({
//     Key key,
//     this.onTap,
//     this.text,
//     this.color,
//     this.textColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap(text),
//       child: Container(
//         alignment: Alignment.center,
//         // width: 80,
//         color: color,
//         child: Text(
//           text,
//           style: TextStyle(
//             color: textColor ?? Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
