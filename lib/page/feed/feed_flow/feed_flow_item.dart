import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

class FeedFlowItem extends StatefulWidget {
  final bool isHero;
  final int itemIndex;
  final HomeFeedModel model;

  FeedFlowItem({
    this.isHero = false,
    this.itemIndex = -1,
    this.model,
  });

  @override
  _FeedFlowItemState createState() => _FeedFlowItemState();
}

class _FeedFlowItemState extends State<FeedFlowItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isHero
        ? Hero(
            tag: "TwoColumnFeedPage" + "${widget.model.id}${widget.itemIndex}",
            child: getItem(),
          )
        : getItem();
  }

  // 宽高比
  double setAspectRatio(double height) {
    if (height == 0) {
      return ScreenUtil.instance.width;
    } else {
      return (ScreenUtil.instance.width / widget.model.picUrls[0].width) * height;
    }
  }

  Widget getItem() {
    return Container(
        width: ScreenUtil.instance.width,
        height: setAspectRatio(widget.model.picUrls[0].height.toDouble()),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
              child: Center(
            child: CircularProgressIndicator(),
          )),
          imageUrl: widget.model.picUrls[0].url != null ? widget.model.picUrls[0].url : "",
          errorWidget: (context, url, error) => Container(
            color: AppColor.bgWhite,
          ),
        ));
    //   Container(
    //   color: getColor(widget.itemIndex),
    //   height: 300,
    //   child: Text("${widget.itemIndex}"),
    //   alignment: Alignment.center,
    //   width: MediaQuery.of(context).size.width,
    // );
  }

  Color getColor(int index) {
    if (index % 5 == 1) {
      return Colors.red;
    } else if (index % 5 == 2) {
      return Colors.lightGreen;
    } else if (index % 5 == 3) {
      return Colors.amberAccent;
    } else if (index % 5 == 4) {
      return Colors.tealAccent;
    } else {
      return Colors.deepPurpleAccent;
    }
  }
}
