import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';

/// training_gallery_page
/// Created by yangjiayi on 2021/1/20.

class TrainingGalleryPage extends StatefulWidget {
  @override
  _TrainingGalleryState createState() => _TrainingGalleryState();
}

class _TrainingGalleryState extends State<TrainingGalleryPage> {
  List<_TrainingGalleryMonthModel> _rawData = [];
  List<_TrainingGalleryItemModel> _galleryData = [];

  @override
  void initState() {
    super.initState();
    _initData();
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
              "健身相册",
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
                Icons.camera_alt_outlined,
                color: AppColor.black,
              ),
              onPressed: () {
                AppRouter.navigateToMediaPickerPage(
                    context, 1, typeImage, false, startPageGallery, false, false, (result) {});
              }),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_galleryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 224,
              width: 224,
              color: AppColor.bgWhite,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "还没有照片",
              style: AppStyle.textSecondaryRegular14,
            )
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _galleryData.length,
          itemBuilder: _buildItem);
    }
  }

  _initData() {
    _TrainingGalleryMonthModel monthModel1 = _TrainingGalleryMonthModel()
      ..month = "1月 2021"
      ..days = [];
    monthModel1.days.add(_TrainingGalleryDayModel()
      ..day = "18"
      ..images = [
        "https://i2.hdslb.com/bfs/archive/4431155151f0b9b3da5f150b7b4273bcc525afe1.jpg",
        "https://i2.hdslb.com/bfs/archive/2c7f0d9854199fa61ffeb06af05f3c81fd30e19d.jpg",
        "https://i0.hdslb.com/bfs/archive/a4cd4bf40a10d6d1a841ab4246db86d8df713c64.jpg",
        "https://i1.hdslb.com/bfs/archive/08a1ac97644b93563cd17a601a81803528133f71.jpg",
        "https://i2.hdslb.com/bfs/archive/857d28d02e35ef9eefcdfea0b8b00d608a08e682.jpg",
        "https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg",
        "https://i1.hdslb.com/bfs/archive/7bd977dacfe35cecb5ea13df2673bb453ea53195.jpg"
      ]);
    monthModel1.days.add(_TrainingGalleryDayModel()
      ..day = "10"
      ..images = ["https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg"]);
    monthModel1.days.add(_TrainingGalleryDayModel()
      ..day = "1"
      ..images = [
        "https://i2.hdslb.com/bfs/archive/6dad8b9612336e1c9fd88dd54a7eac08909e410e.jpg",
        "https://i0.hdslb.com/bfs/archive/8e58184f1dca7e82cc801d3dc170b98ec7333a42.jpg",
        "https://i2.hdslb.com/bfs/archive/53b58742ebb860bd0ada1e9fd048c48bb8383c51.jpg",
        "https://i2.hdslb.com/bfs/archive/76f307eab11e961ad92ced6de85f85d8d600c9f3.jpg"
      ]);
    _TrainingGalleryMonthModel monthModel2 = _TrainingGalleryMonthModel()
      ..month = "11月 2020"
      ..days = [];
    monthModel2.days.add(_TrainingGalleryDayModel()
      ..day = "11"
      ..images = [
        "https://i2.hdslb.com/bfs/archive/4431155151f0b9b3da5f150b7b4273bcc525afe1.jpg",
        "https://i2.hdslb.com/bfs/archive/2c7f0d9854199fa61ffeb06af05f3c81fd30e19d.jpg",
        "https://i0.hdslb.com/bfs/archive/a4cd4bf40a10d6d1a841ab4246db86d8df713c64.jpg",
        "https://i1.hdslb.com/bfs/archive/08a1ac97644b93563cd17a601a81803528133f71.jpg",
        "https://i2.hdslb.com/bfs/archive/857d28d02e35ef9eefcdfea0b8b00d608a08e682.jpg",
        "https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg",
        "https://i1.hdslb.com/bfs/archive/7bd977dacfe35cecb5ea13df2673bb453ea53195.jpg"
      ]);
    monthModel2.days.add(_TrainingGalleryDayModel()
      ..day = "5"
      ..images = ["https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg"]);
    _TrainingGalleryMonthModel monthModel3 = _TrainingGalleryMonthModel()
      ..month = "10月 2020"
      ..days = [];
    monthModel3.days.add(_TrainingGalleryDayModel()
      ..day = "20"
      ..images = [
        "https://i2.hdslb.com/bfs/archive/6dad8b9612336e1c9fd88dd54a7eac08909e410e.jpg",
        "https://i0.hdslb.com/bfs/archive/8e58184f1dca7e82cc801d3dc170b98ec7333a42.jpg",
        "https://i2.hdslb.com/bfs/archive/53b58742ebb860bd0ada1e9fd048c48bb8383c51.jpg",
        "https://i2.hdslb.com/bfs/archive/76f307eab11e961ad92ced6de85f85d8d600c9f3.jpg"
      ]);
    _rawData.add(monthModel1);
    _rawData.add(monthModel2);
    _rawData.add(monthModel3);

    _rawData.forEach((monthModel) {
      _galleryData.add(_TrainingGalleryItemModel()
        ..type = 0
        ..month = monthModel.month);
      monthModel.days.forEach((dayModel) {
        _galleryData.add(_TrainingGalleryItemModel()
          ..type = 1
          ..day = dayModel.day
          ..images = dayModel.images);
      });
    });

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    _TrainingGalleryItemModel model = _galleryData[index];
    if(model.type == 1){
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 30, 0),
        child: Row(
          children: [
            Container(
              width: 44,
              child: Text(model.day, ),
            )
          ],
        ),
      );
    }else{
      return Container(
        height: 48,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Text(model.month, style: AppStyle.textMedium18,),
      );
    }
  }
}

class _TrainingGalleryItemModel {
  //0-month, 1-day
  int type;
  String month;
  String day;
  List<String> images;
}

class _TrainingGalleryMonthModel {
  String month;
  List<_TrainingGalleryDayModel> days;
}

class _TrainingGalleryDayModel {
  String day;
  List<String> images;
}
