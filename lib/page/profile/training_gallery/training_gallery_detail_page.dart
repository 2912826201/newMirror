import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/training/training_gallery_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/download_dto.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/scale_view.dart';

import 'training_gallery_page.dart';

/// training_gallery_detail_page
/// Created by yangjiayi on 2021/1/21.

class TrainingGalleryDetailPage extends StatefulWidget {
  TrainingGalleryDetailPage(this.dataList, {Key key, this.dayIndex = 0, this.imageIndex = 0}) : super(key: key);

  final List<TrainingGalleryDayModel> dataList;
  final int dayIndex;
  final int imageIndex;

  @override
  _TrainingGalleryDetailState createState() => _TrainingGalleryDetailState();
}

class _TrainingGalleryDetailState extends State<TrainingGalleryDetailPage> {
  TrainingGalleryResult _galleryResult;

  List<TrainingGalleryImageModel> _imageList = [];
  int _currentIndex = 0;
  String _title = "";

  SwiperController _controller = SwiperController();

  bool _isRequesting = false;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    for (int i = 0; i < widget.dataList.length; i++) {
      TrainingGalleryDayModel model = widget.dataList[i];
      for (int j = 0; j < model.list.length; j++) {
        if (i == widget.dayIndex && j == widget.imageIndex) {
          _currentIndex = _imageList.length;
        }
        _imageList.add(model.list[j]);
      }
    }
    _title = _getTitleTime();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _galleryResult);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          titleString: _title,
          leadingOnTap: () {
            Navigator.pop(context, _galleryResult);
          },
          actions: [
            CustomAppBarIconButton(
                icon: Icons.more_horiz,
                iconColor: AppColor.black,
                onTap: () {
                  _showMorePopup(context, _imageList[_currentIndex]);
                }),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: AppColor.white,
      child: Swiper(
        controller: _controller,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
            _title = _getTitleTime();
          });
        },
        loop: false,
        index: _currentIndex,
        itemCount: _imageList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: _buildItem,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return ScaleView(
      child: Center(
        child: CachedNetworkImage(
          imageUrl: _imageList[index].url,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _getTitleTime() {
    return DateFormat('MM月dd日 HH:mm').format(DateTime.fromMillisecondsSinceEpoch(_imageList[_currentIndex].createTime));
  }

  _showMorePopup(BuildContext context, TrainingGalleryImageModel image) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: AppColor.transparent,
        builder: (context) {
          return _buildMorePopup(image);
        });
  }

  _buildMorePopup(TrainingGalleryImageModel image) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      height: 158 + ScreenUtil.instance.bottomBarHeight,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
              _saveImage(image.url);
            },
            child: Container(
              width: ScreenUtil.instance.screenWidthDp,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                "保存本地",
                style: TextStyle(color: AppColor.black, fontSize: 17),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              //避免请求过程中继续点击
              if (_isRequesting) {
                return;
              }
              _isRequesting = true;
              bool result = await deleteAlbum([image.id]);
              _isRequesting = false;
              if (result != null && result) {
                Navigator.pop(context);
                _afterDelete(image.id);
              }
            },
            child: Container(
              width: ScreenUtil.instance.screenWidthDp,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                "删除",
                style: TextStyle(color: AppColor.black, fontSize: 17),
              ),
            ),
          ),
          Container(
            color: AppColor.bgWhite,
            width: ScreenUtil.instance.screenWidthDp,
            height: 8,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: ScreenUtil.instance.screenWidthDp,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                "取消",
                style: TextStyle(color: AppColor.black, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _afterDelete(int id) {
    for (TrainingGalleryImageModel image in _imageList) {
      if (image.id == id) {
        _imageList.remove(image);
        if (_galleryResult == null) {
          _galleryResult = TrainingGalleryResult();
          _galleryResult.operation = -1;
          _galleryResult.list = [];
        }
        _galleryResult.list.add(image);
        break;
      }
    }

    if (_imageList.isEmpty) {
      Navigator.pop(context, _galleryResult);
    } else if (_currentIndex >= _imageList.length) {
      setState(() {
        _controller.move(_imageList.length - 1);
      });
    } else {
      setState(() {});
    }
  }

  _saveImage(String url) async {
    DownloadDto download = await FileUtil().download(url, (taskId, received, total) {});
    var result = await ImageGallerySaver.saveFile(download.filePath);
    if (result["isSuccess"] == true) {
      ToastShow.show(msg: "保存成功", context: context);
    }
  }
}
