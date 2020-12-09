import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final double paddingTop;
  final String coverImgUrl;
  final String title;
  String statusBarMode = 'dark';
  final List<String> valueArray;
  final List<String> titleArray;
  bool isGoneTitle = true;
  double titleSize = 30;

  SliverCustomHeaderDelegate({
    this.collapsedHeight,
    this.expandedHeight,
    this.paddingTop,
    this.coverImgUrl,
    this.title,
    this.valueArray,
    this.titleArray,
  });

  @override
  double get minExtent => this.collapsedHeight + this.paddingTop;

  @override
  double get maxExtent => this.expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void updateStatusBarBrightness(shrinkOffset) {
    if (shrinkOffset > 50 && this.statusBarMode == 'light') {
      this.statusBarMode = 'dark';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    } else if (shrinkOffset <= 50 && this.statusBarMode == 'dark') {
      this.statusBarMode = 'light';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    }
  }

  Color makeStickyHeaderBgColor(shrinkOffset) {
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
        .clamp(0, 255)
        .toInt();
    if (alpha > 210) {
      titleSize = 20;
      isGoneTitle = false;
    } else {
      titleSize = 30 - alpha / 21;
      isGoneTitle = true;
    }
    return Color.fromARGB(alpha, 255, 255, 255);
  }

  Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
    if (shrinkOffset <= 50) {
      return isIcon ? Colors.white : Colors.transparent;
    } else {
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
          .clamp(0, 255)
          .toInt();
      return Color.fromARGB(alpha, 0, 0, 0);
    }
  }

  List<Widget> _getTitleWidgetArray() {
    var widgetArray = <Widget>[];
    if (titleArray != null && valueArray != null) {
      var valueTextStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
      var titleTextStyle = TextStyle(fontSize: 20);
      for (int i = 0; i < titleArray.length; i++) {
        widgetArray.add(Column(
          children: [
            Text(
              valueArray[i],
              style: valueTextStyle,
            ),
            Text(
              titleArray[i],
              style: titleTextStyle,
            ),
          ],
        ));
      }
    }
    return widgetArray;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.updateStatusBarBrightness(shrinkOffset);
    return Container(
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(child: Image.asset(this.coverImgUrl, fit: BoxFit.cover)),
          Positioned(
            left: 0,
            top: this.maxExtent / 5,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x60ffffff),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _getTitleWidgetArray(),
              ),
            ),
            bottom: 0,
            left: 0,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: this.makeStickyHeaderBgColor(shrinkOffset),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: this.collapsedHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          // color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Offstage(
                        offstage: isGoneTitle,
                        child: Text(
                          this.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: this
                                .makeStickyHeaderTextColor(shrinkOffset, false),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          // color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: this.maxExtent,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Offstage(
                    offstage: !isGoneTitle,
                    child: Text(
                      this.title,
                      style: TextStyle(
                          fontSize: titleSize, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
