
import 'package:flutter/material.dart';


class SelectText extends StatelessWidget {
  const SelectText({
    Key key,
    this.isSelect: true,
    this.title,
  }) : super(key: key);

  final bool isSelect;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      color: Colors.black.withOpacity(0),
      child: Text(
        title ?? '??',
        textAlign: TextAlign.center,
        style:
        isSelect ? TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          inherit: true,
        ) : TextStyle(
          color: const Color.fromRGBO(0xff, 0xff, 0xff, .66),
          fontWeight: FontWeight.w600,
          fontSize: 16,
          inherit: true,
        ),
      ),
    );
  }
}
