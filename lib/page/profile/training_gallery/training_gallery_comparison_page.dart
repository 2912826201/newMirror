import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:photo_view/photo_view.dart';

/// training_gallery_comparison_page
/// Created by yangjiayi on 2021/1/25.

class TrainingGalleryComparisonPage extends StatefulWidget {
  TrainingGalleryComparisonPage(this.image1, this.image2, {Key key}) : super(key: key);

  final TrainingGalleryImageModel image1;
  final TrainingGalleryImageModel image2;

  @override
  _TrainingGalleryComparisonState createState() => _TrainingGalleryComparisonState();
}

class _TrainingGalleryComparisonState extends State<TrainingGalleryComparisonPage> {
  Axis _orientation = Axis.vertical;
  double _canvasSize = 0;

  @override
  Widget build(BuildContext context) {
    _canvasSize = ScreenUtil.instance.screenWidthDp;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        brightness: Brightness.light,
        title: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
          //60+16-56-16
          Container(
            width: 4,
          ),
          Spacer(),
          Text(
            "制作对比图",
            style: AppStyle.textMedium18,
          ),
          Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              height: 28,
              width: 60,
              decoration: BoxDecoration(color: AppColor.mainRed, borderRadius: BorderRadius.circular(14)),
              child: Text("完成", style: TextStyle(color: AppColor.white, fontSize: 14)),
            ),
          ),
        ]),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: AppColor.white,
      child: Column(
        children: [
          SizedBox(
            height: 53,
          ),
          Container(
            height: _canvasSize,
            width: _canvasSize,
            child: _buildCanvas(),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            height: 56,
            child: Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () {
                    if (_orientation != Axis.vertical) {
                      setState(() {
                        _orientation = Axis.vertical;
                      });
                    }
                  },
                  child: Icon(
                    Icons.view_agenda_outlined,
                    size: 24,
                    color: _orientation == Axis.vertical ? AppColor.textPrimary2 : AppColor.textSecondary,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    if (_orientation != Axis.horizontal) {
                      setState(() {
                        _orientation = Axis.horizontal;
                      });
                    }
                  },
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Icon(
                      Icons.view_agenda_outlined,
                      size: 24,
                      color: _orientation == Axis.horizontal ? AppColor.textPrimary2 : AppColor.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    if (_orientation == Axis.vertical) {
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.mainBlue,
              child: PhotoView(
                imageProvider: NetworkImage(widget.image1.url),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.mainRed,
              child: PhotoView(
                imageProvider: NetworkImage(widget.image2.url),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.mainBlue,
              child: PhotoView(
                imageProvider: NetworkImage(widget.image1.url),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.mainRed,
              child: PhotoView(
                imageProvider: NetworkImage(widget.image2.url),
              ),
            ),
          ),
        ],
      );
    }
  }
}
