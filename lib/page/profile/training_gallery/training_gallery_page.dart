import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';

/// training_gallery_page
/// Created by yangjiayi on 2021/1/20.

class TrainingGalleryPage extends StatefulWidget {
  @override
  _TrainingGalleryState createState() => _TrainingGalleryState();
}

class _TrainingGalleryState extends State<TrainingGalleryPage> {
  List<TrainingGalleryDayModel> _dataList = [];

  _initData() {
    _dataList.add(TrainingGalleryDayModel()
      ..month = "1月 2021"
      ..day = "18"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/4431155151f0b9b3da5f150b7b4273bcc525afe1.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/2c7f0d9854199fa61ffeb06af05f3c81fd30e19d.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/a4cd4bf40a10d6d1a841ab4246db86d8df713c64.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i1.hdslb.com/bfs/archive/08a1ac97644b93563cd17a601a81803528133f71.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/857d28d02e35ef9eefcdfea0b8b00d608a08e682.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i1.hdslb.com/bfs/archive/7bd977dacfe35cecb5ea13df2673bb453ea53195.jpg"
      ]);
    _dataList.add(TrainingGalleryDayModel()
      ..month = "1月 2021"
      ..day = "10"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/2b8bf21ed1117b345aa596f34b6c53c310a801cb.jpg"
      ]);
    _dataList.add(TrainingGalleryDayModel()
      ..month = "1月 2021"
      ..day = "1"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/6dad8b9612336e1c9fd88dd54a7eac08909e410e.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/8e58184f1dca7e82cc801d3dc170b98ec7333a42.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/53b58742ebb860bd0ada1e9fd048c48bb8383c51.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/76f307eab11e961ad92ced6de85f85d8d600c9f3.jpg"
      ]);
    _dataList.add(TrainingGalleryDayModel()
      ..month = "11月 2020"
      ..day = "11"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/4431155151f0b9b3da5f150b7b4273bcc525afe1.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/2c7f0d9854199fa61ffeb06af05f3c81fd30e19d.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/a4cd4bf40a10d6d1a841ab4246db86d8df713c64.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i1.hdslb.com/bfs/archive/08a1ac97644b93563cd17a601a81803528133f71.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/857d28d02e35ef9eefcdfea0b8b00d608a08e682.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/de2b17a1e96a26c3b8222b316f8417fba45c7737.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i1.hdslb.com/bfs/archive/7bd977dacfe35cecb5ea13df2673bb453ea53195.jpg"
      ]);
    _dataList.add(TrainingGalleryDayModel()
      ..month = "11月 2020"
      ..day = "15"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/2b8bf21ed1117b345aa596f34b6c53c310a801cb.jpg"
      ]);
    _dataList.add(TrainingGalleryDayModel()
      ..month = "10月 2020"
      ..day = "20"
      ..images = [
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/6dad8b9612336e1c9fd88dd54a7eac08909e410e.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i0.hdslb.com/bfs/archive/8e58184f1dca7e82cc801d3dc170b98ec7333a42.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/53b58742ebb860bd0ada1e9fd048c48bb8383c51.jpg",
        TrainingGalleryImageModel()
          ..url = "https://i2.hdslb.com/bfs/archive/76f307eab11e961ad92ced6de85f85d8d600c9f3.jpg"
      ]);

    SuspensionUtil.setShowSuspensionStatus(_dataList);

    if (mounted) {
      setState(() {});
    }
  }

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
    if (_dataList.isEmpty) {
      return Container(
        color: AppColor.white,
        child: Center(
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
        ),
      );
    } else {
      return Container(
        color: AppColor.white,
        child: Column(
          children: [
            Expanded(
                child: AzListView(
              padding: EdgeInsets.zero,
              itemBuilder: _buildItem,
              susItemBuilder: _buildHeader,
              itemCount: _dataList.length,
              data: _dataList,
              indexBarData: [],
            )),
            GestureDetector(
              onTap: () {
                print("制作对比图");
              },
              child: Container(
                padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
                height: 48 + ScreenUtil.instance.bottomBarHeight,
                color: AppColor.textPrimary2,
                alignment: Alignment.center,
                child: Text(
                  "制作对比图",
                  style: AppStyle.whiteRegular16,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, int index) {
    TrainingGalleryDayModel model = _dataList[index];
    return Container(
      height: 48,
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        model.month,
        style: AppStyle.textMedium18,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int dayIndex) {
    TrainingGalleryDayModel model = _dataList[dayIndex];
    bool isLastDayInMonth = false;
    if (dayIndex < _dataList.length - 1 && _dataList[dayIndex + 1].month != model.month) {
      isLastDayInMonth = true;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 30, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            child: Text(
              model.day,
            ),
          ),
          Expanded(
            child: Container(
              padding:
                  isLastDayInMonth ? const EdgeInsets.fromLTRB(0, 5, 0, 12) : const EdgeInsets.fromLTRB(0, 5, 0, 23),
              child: GridView.builder(
                  itemCount: model.images.length,
                  shrinkWrap: true,
                  //padding要设置为0，不然默认下方会有一定距离
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1, crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
                  itemBuilder: (context, index) {
                    return _buildImage(context, index, dayIndex);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, int index, int dayIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TrainingGalleryDetailPage(
            _dataList,
            dayIndex: dayIndex,
            imageIndex: index,
          );
        }));
      },
      child: CachedNetworkImage(
        imageUrl: _dataList[dayIndex].images[index].url,
        fit: BoxFit.cover,
      ),
    );
  }
}

// 要继承这个ISuspensionBean
class TrainingGalleryDayModel with ISuspensionBean {
  String month;
  String day;
  List<TrainingGalleryImageModel> images;

  @override
  String getSuspensionTag() => month;
}

class TrainingGalleryImageModel {
  int id;
  String url;
  int createTime;
}
