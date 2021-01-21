import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/widget/scale_view.dart';

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
  List<TrainingGalleryImageModel> _imageList = [];
  int _currentIndex = 0;
  String _title = "";

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
    _title = "index: $_currentIndex";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        brightness: Brightness.light,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: AppStyle.textMedium18,
            ),
          ],
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: AppColor.black,
              ),
              onPressed: () {
                print("更多");
              }),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: AppColor.white,
      child: Swiper(
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
            _title = "index: $_currentIndex";
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
}
