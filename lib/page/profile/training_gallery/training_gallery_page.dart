import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/training_gallery_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/list_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/loading.dart';

/// training_gallery_page
/// Created by yangjiayi on 2021/1/20.

class TrainingGalleryPage extends StatefulWidget {
  @override
  _TrainingGalleryState createState() => _TrainingGalleryState();
}

class _TrainingGalleryState extends State<TrainingGalleryPage> {
  final int _imageMaxSelection = 2;

  bool hasNext;
  int lastTime;

  List<TrainingGalleryDayModel> _dataList = [];

  bool _isSelectionMode = false;
  AppBar _normalModeAppBar;
  AppBar _selectionModeAppBar;
  final List<TrainingGalleryImageModel> _selectedImageList = [];

  _initData() async {
    ListModel<TrainingGalleryDayModel> listModel = await getAlbum(20);
    hasNext = listModel.hasNext == 1;
    lastTime = listModel.lastTime;
    _dataList.addAll(listModel.list);

    SuspensionUtil.setShowSuspensionStatus(_dataList);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initAppBar();
    _initData();
  }

  _initAppBar() {
    _selectionModeAppBar = AppBar(
      backgroundColor: AppColor.white,
      brightness: Brightness.light,
      title: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "健身相册",
                style: AppStyle.textMedium18,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSelectionMode = false;
                });
              },
              child: Text(
                "取消",
                style: AppStyle.textPrimary2Medium16,
              ),
            ),
          )
        ],
      ),
      automaticallyImplyLeading: false,
    );
    _normalModeAppBar = AppBar(
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
        Container(
          alignment: Alignment.center,
          //TODO 这里为了保证和左边返回按钮一样宽 之后要改
          width: 56,
          child: IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: AppColor.black,
              ),
              onPressed: () {
                AppRouter.navigateToMediaPickerPage(
                    context, 1, typeImage, false, startPageGallery, false, false, _uploadImage);
              }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _selectionModeAppBar : _normalModeAppBar,
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
            _buildBottomView(),
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
                  itemCount: model.list.length,
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
    TrainingGalleryImageModel imageModel = _dataList[dayIndex].list[index];
    bool isSelected = false;
    if (_isSelectionMode) {
      for (TrainingGalleryImageModel selected in _selectedImageList) {
        if (selected.id == imageModel.id) {
          isSelected = true;
          break;
        }
      }
    }
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          if (isSelected) {
            //已选中 取消选择
            setState(() {
              _selectedImageList.remove(imageModel);
            });
          } else if (_selectedImageList.length < _imageMaxSelection) {
            //未选中 且未达到最大数量 添加选择
            setState(() {
              _selectedImageList.add(imageModel);
            });
          }
        } else {
          AppRouter.navigateToTrainingGalleryDetailPage(context, _dataList, (result) {
            if (result == null) {
              return;
            }

            TrainingGalleryResult galleryResult = result as TrainingGalleryResult;
            //TODO 目前只处理删除操作结果 还没有同步更新我的页面的相册数量
            //要确保遍历后再进行增删操作
            if (galleryResult.operation == -1) {
              Set<int> deleteImageIdSet = Set<int>();
              galleryResult.list.forEach((deleteImage) {
                deleteImageIdSet.add(deleteImage.id);
              });

              List<TrainingGalleryDayModel> deleteDayList = [];
              for (TrainingGalleryDayModel day in _dataList) {
                List<TrainingGalleryImageModel> deleteImageList = [];
                for (TrainingGalleryImageModel image in day.list) {
                  if (deleteImageIdSet.contains(image.id)) {
                    deleteImageList.add(image);
                  }
                }
                if (deleteImageList.isNotEmpty) {
                  deleteImageList.forEach((deleteImage) {
                    day.list.remove(deleteImage);
                  });
                  //检查是否列表中还有数据 如果没有则整条要删掉
                  if (day.list.isEmpty) {
                    deleteDayList.add(day);
                  }
                }
              }
              if (deleteDayList.isNotEmpty) {
                deleteDayList.forEach((deleteDay) {
                  _dataList.remove(deleteDay);
                });
                // 有整条删掉的数据后默认重新更新tag 不做复杂的数据的比较了
                SuspensionUtil.setShowSuspensionStatus(_dataList);
              }
              setState(() {});
            }
          }, dayIndex: dayIndex, imageIndex: index);
        }
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: imageModel.url,
              fit: BoxFit.cover,
            ),
          ),
          isSelected
              ? Container(
                  padding: const EdgeInsets.all(6),
                  alignment: Alignment.bottomRight,
                  color: AppColor.textPrimary2.withOpacity(0.35),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColor.mainRed,
                    size: 24,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  _uploadImage(dynamic result) async {
    SelectedMediaFiles files = Application.selectedMediaFiles;
    if (true != result || files == null) {
      print("没有选择媒体文件");
      return;
    }
    Application.selectedMediaFiles = null;
    print(files.type + ":" + files.list.toString());

    if (files.type != mediaTypeKeyImage) {
      return;
    }

    Loading.showLoading(context);

    try {
      for (MediaFileModel model in files.list) {
        if (model.croppedImage != null) {
          print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
          ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
          print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
          Uint8List picBytes = byteData.buffer.asUint8List();
          print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
          model.croppedImageData = picBytes;
        }
      }

      List<File> fileList = [];
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      int i = 0;
      files.list.forEach((element) async {
        if (element.croppedImageData == null) {
          fileList.add(element.file);
        } else {
          i++;
          File imageFile = await FileUtil().writeImageDataToFile(element.croppedImageData, timeStr + i.toString());
          fileList.add(imageFile);
        }
      });
      UploadResults uploadResults = await FileUtil().uploadPics(fileList, (percent) {
        print("总进度:$percent");
      });

      if (uploadResults.isSuccess) {
        //整理接口入参 调接口
        List<Map<String, dynamic>> paramList = [];
        for (int i = 0; i < files.list.length; i++) {
          MediaFileModel mediaFileModel = files.list[i];
          paramList.add(TrainingGalleryImageModel(
                  url: uploadResults.resultMap[mediaFileModel.file.path].url,
                  width: mediaFileModel.sizeInfo.width.toDouble(),
                  height: mediaFileModel.sizeInfo.height.toDouble())
              .toJson());
        }
        List<TrainingGalleryImageModel> saveList = await saveAlbum(paramList);
        if (saveList != null) {
          //插入数据
          if (_dataList.isNotEmpty && saveList.first.dateTime == _dataList.first.dateTime) {
            //如果列表不为空 且第一条的日期和结果相同 则插入已有数据
            setState(() {
              _dataList.first.list.insertAll(0, saveList);
            });
          } else {
            //插入新数据
            setState(() {
              if (_dataList.isNotEmpty) {
                //要把是不是显示月份标签修改了
                _dataList[0].isShowSuspension = false;
              }
              _dataList.insert(0,
                  TrainingGalleryDayModel(dateTime: saveList.first.dateTime, list: saveList)..isShowSuspension = true);
            });
          }
        } else {
          ToastShow.show(msg: "保存失败", context: context);
        }
      } else {
        ToastShow.show(msg: "上传失败", context: context);
      }
    } catch (e) {
      print(e);
      ToastShow.show(msg: "保存失败", context: context);
    }

    Loading.hideLoading(context);
  }

  Widget _buildBottomView() {
    if (_isSelectionMode) {
      return Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, ScreenUtil.instance.bottomBarHeight),
        height: 145 + ScreenUtil.instance.bottomBarHeight,
        color: AppColor.textPrimary2,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "已选择${_selectedImageList.length}/$_imageMaxSelection张照片",
                    style: TextStyle(color: AppColor.white.withOpacity(0.65), fontSize: 14),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "继续",
                      style: _selectedImageList.length == _imageMaxSelection
                          ? TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 14)
                          : TextStyle(color: AppColor.white.withOpacity(0.85 * 0.24), fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 97,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedImageList.length > 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageList.removeAt(0);
                            });
                          },
                          child: Container(
                            height: 93,
                            width: 93,
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                    imageUrl: _selectedImageList[0].url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  color: AppColor.textPrimary2.withOpacity(0.35),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: AppColor.mainRed,
                                    size: 24,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    width: 12,
                  ),
                  _selectedImageList.length > 1
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageList.removeAt(1);
                            });
                          },
                          child: Container(
                            height: 93,
                            width: 93,
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                    imageUrl: _selectedImageList[1].url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  color: AppColor.textPrimary2.withOpacity(0.35),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: AppColor.mainRed,
                                    size: 24,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          print("制作对比图");
          setState(() {
            _selectedImageList.clear();
            _isSelectionMode = true;
          });
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
      );
    }
  }
}

class TrainingGalleryResult {
  //-1删除 1添加
  int operation;
  List<TrainingGalleryImageModel> list;
}
