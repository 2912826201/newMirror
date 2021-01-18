import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';

class TrainingRecordPageItem extends StatefulWidget {
  @override
  _TrainingRecordPageItemState createState() => _TrainingRecordPageItemState();
}

class _TrainingRecordPageItemState extends State<TrainingRecordPageItem> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        "这是第四个页面",
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
