

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:provider/provider.dart';

class FeedFlowItem extends StatefulWidget {
  final bool isHero;
  final int itemIndex;

  FeedFlowItem({
    this.isHero=false,
    this.itemIndex=-1,
  });

  @override
  _FeedFlowItemState createState() => _FeedFlowItemState();
}

class _FeedFlowItemState extends State<FeedFlowItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isHero?
    Hero(
      tag: context.watch<FeedFlowDataNotifier>().heroTagString,
      child: getItem(),
    ):getItem();
  }



  Widget getItem(){
    return Container(
      color: getColor(widget.itemIndex),
      height: 300,
      child: Text("${widget.itemIndex}"),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
    );
  }


  Color getColor(int index) {
    if (index % 5 ==1) {
      return Colors.red;
    } else if (index % 5 ==2) {
      return Colors.lightGreen;
    } else if (index % 5 ==3) {
      return Colors.amberAccent;
    } else if (index % 5 ==4) {
      return Colors.tealAccent;
    } else {
      return Colors.deepPurpleAccent;
    }
  }
}
