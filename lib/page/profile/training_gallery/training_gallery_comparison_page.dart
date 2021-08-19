import 'dart:async';
import 'dart:io';
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
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:intl/intl.dart';
import 'package:mirror/widget/image_cropper/image_cropper.dart';
import 'package:mirror/widget/loading.dart';

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

  bool _isBusy = false;

// 图片加载完成监听
  StreamController<ImageDownloadFinished> streamController = StreamController<ImageDownloadFinished>();
  ImageDownloadFinished imageDownloadFinished = ImageDownloadFinished();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Loading.showLoading(context,infoText: "正在制作对比图,请稍候");
    });
  }

  @override
  Widget build(BuildContext context) {
    _canvasSize = ScreenUtil.instance.screenWidthDp;
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "制作对比图",
        actions: [
          Container(
            padding:
                const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
            child: StreamBuilder<ImageDownloadFinished>(
                initialData: imageDownloadFinished,
                stream: streamController.stream,
                builder: (BuildContext streamContext, AsyncSnapshot<ImageDownloadFinished> snapshot) {
                  if (snapshot.data.afterImage && snapshot.data.beforeImage) {
                    Loading.hideLoading(context);
                  }
                  return CustomRedButton(
                    "完成",
                    snapshot.data.afterImage && snapshot.data.beforeImage
                        ? CustomRedButton.buttonStateNormal
                        : CustomRedButton.buttonStateInvalid,
                    () async {
                      //因为获取图像数据需要时间，所以可能在快速点击时执行多次此方法，获取多次图像弹出多个分享弹窗。根据_isBusy变量状态控制
                      if (_isBusy) {
                        return;
                      }
                      _isBusy = true;
                      RenderRepaintBoundary boundary = _cropperKey.currentContext.findRenderObject();
                      double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
                      ui.Image image = await boundary.toImage(pixelRatio: dpr);
                      print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                      print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                      Uint8List picBytes = byteData.buffer.asUint8List();
                      print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                      File imageFile = await FileUtil()
                          .writeImageDataToFile(picBytes, DateTime.now().millisecondsSinceEpoch.toString());
                      SharedImageModel model = SharedImageModel();
                      model.width = (_canvasSize * dpr).toInt();
                      model.height = (_canvasSize * dpr).toInt();
                      model.file = imageFile;
                      openShareBottomSheet(
                          context: context,
                          chatTypeModel: ChatTypeModel.MESSAGE_TYPE_IMAGE,
                          map: model.toJson(),
                          sharedType: 2,
                          fromTraingGallery: true);
                      _isBusy = false;
                    },
                  );
                }),
          ),
        ],
      ),
      backgroundColor: AppColor.mainBlack,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
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
                      imageDownloadFinished.beforeImage = false;
                      imageDownloadFinished.afterImage = false;
                      streamController.sink.add(imageDownloadFinished);
                    }
                  },
                  child: AppIcon.getAppIcon(
                    AppIcon.layout_vertical,
                    24,
                    color: _orientation == Axis.vertical ? AppColor.white : AppColor.textWhite60,
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
                      imageDownloadFinished.beforeImage = false;
                      imageDownloadFinished.afterImage = false;
                      streamController.sink.add(imageDownloadFinished);
                    }
                  },
                  child: AppIcon.getAppIcon(
                    AppIcon.layout_horizontal,
                    24,
                    color: _orientation == Axis.horizontal ? AppColor.white : AppColor.textWhite60,
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
                  NetworkImage(
                    widget.image1.url,
                  ),
                  lineWidth: 0,
                  outHeight: 1,
                  outWidth: 2,
                  maskPadding: 0,
                  round: 0,
                  backBoxColor0: AppColor.transparent,
                  backBoxColor1: AppColor.transparent,
                  imageLoadCompleteCallBack: () {
                    print("图片加载完成1");
                    imageDownloadFinished.beforeImage = true;
                    streamController.sink.add(imageDownloadFinished);
                  },
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
                  backBoxColor0: AppColor.transparent,
                  backBoxColor1: AppColor.transparent,
                  imageLoadCompleteCallBack: () {
                    print("图片加载完成2");
                    imageDownloadFinished.afterImage = true;
                    streamController.sink.add(imageDownloadFinished);
                  },
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
                  backBoxColor0: AppColor.transparent,
                  backBoxColor1: AppColor.transparent,
                  imageLoadCompleteCallBack: () {
                    print("图片加载完成3");
                    imageDownloadFinished.beforeImage = true;
                    streamController.sink.add(imageDownloadFinished);
                  },
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
                  backBoxColor0: AppColor.transparent,
                  backBoxColor1: AppColor.transparent,
                  imageLoadCompleteCallBack: () {
                    print("图片加载完成4");
                    imageDownloadFinished.afterImage = true;
                    streamController.sink.add(imageDownloadFinished);
                  },
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
      Text(day, style: AppStyle.whiteMedium32),
      SizedBox(
        width: 3,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            beforeOrAfter == 0 ? "Before" : "After",
            style: AppStyle.whiteRegular13,
          ),
          Text(
            month,
            style: AppStyle.whiteRegular11,
          ),
        ],
      )
    ],
  );
}

class ImageDownloadFinished {
  bool beforeImage = false;
  bool afterImage = false;

  ImageDownloadFinished({this.beforeImage = false, this.afterImage = false});
}
