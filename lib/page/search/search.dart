import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     print("搜索页");
    return Container(
      margin: EdgeInsets.only(top: 24),
      child:Container(
        child:TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          minLines: 1,
        ),
      )
    );
  }
}