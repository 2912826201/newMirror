import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/shared_image_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/image_cropper.dart';
import 'package:intl/intl.dart';

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
  var _cropperKey = GlobalKey<_TrainingGalleryComparisonState>();

  Axis _orientation = Axis.horizontal;
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
            onTap: () async {
              RenderRepaintBoundary boundary = _cropperKey.currentContext.findRenderObject();
              double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
              ui.Image image = await boundary.toImage(pixelRatio: dpr);
              print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
              ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
              Uint8List picBytes = byteData.buffer.asUint8List();
              print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
              File imageFile =
                  await FileUtil().writeImageDataToFile(picBytes, DateTime.now().millisecondsSinceEpoch.toString());

              SharedImageModel model = SharedImageModel();
              model.width = (_canvasSize * dpr).toInt();
              model.height = (_canvasSize * dpr).toInt();
              model.file = imageFile;
              openShareBottomSheet(
                  context: context,
                  chatTypeModel: ChatTypeModel.MESSAGE_TYPE_IMAGE,
                  map: model.toJson(),
                  sharedType: 2);
            },
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
          RepaintBoundary(
            key: _cropperKey,
            child: Container(
              height: _canvasSize,
              width: _canvasSize,
              child: _buildCanvas(),
            ),
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

  //TODO 需要研究一下 一般的Transform放大会导致child超出parent的尺寸限制 这里暂时用CropperImage来实现效果
  Widget _buildCanvas() {
    if (_orientation == Axis.vertical) {
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                CropperImage(
                  NetworkImage(widget.image1.url),
                  lineWidth: 0,
                  outHeight: 1,
                  outWidth: 2,
                  maskPadding: 0,
                  round: 0,
                ),
                Positioned(
                  left: 10,
                  bottom: 18.5,
                  child: _buildDateLabel(0, widget.image1.dateTime),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                CropperImage(
                  NetworkImage(widget.image2.url),
                  lineWidth: 0,
                  outHeight: 1,
                  outWidth: 2,
                  maskPadding: 0,
                  round: 0,
                ),
                Positioned(
                  left: 10,
                  bottom: 18.5,
                  child: _buildDateLabel(1, widget.image2.dateTime),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                CropperImage(
                  NetworkImage(widget.image1.url),
                  lineWidth: 0,
                  outHeight: 2,
                  outWidth: 1,
                  maskPadding: 0,
                  round: 0,
                ),
                Positioned(
                  left: 16,
                  bottom: 18.5,
                  child: _buildDateLabel(0, widget.image1.dateTime),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                CropperImage(
                  NetworkImage(widget.image2.url),
                  lineWidth: 0,
                  outHeight: 2,
                  outWidth: 1,
                  maskPadding: 0,
                  round: 0,
                ),
                Positioned(
                  left: 16,
                  bottom: 18.5,
                  child: _buildDateLabel(1, widget.image2.dateTime),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}

//0-before 1-after dateTime:yyyy-MM-dd
Widget _buildDateLabel(int beforeOrAfter, String dateTime) {
  DateTime time = DateFormat('yyyy-MM-dd').parse(dateTime);
  String month = DateFormat('yyyy/MM').format(time);
  String day = DateFormat('dd').format(time);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      //TODO 要做空心字体
      Text(day, style: TextStyle(color: AppColor.white, fontSize: 32, fontWeight: FontWeight.w500)),
      SizedBox(
        width: 3,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            beforeOrAfter == 0 ? "Before" : "After",
            style: TextStyle(color: AppColor.white, fontSize: 13),
          ),
          Text(
            month,
            style: TextStyle(color: AppColor.white, fontSize: 11),
          ),
        ],
      )
    ],
  );
}