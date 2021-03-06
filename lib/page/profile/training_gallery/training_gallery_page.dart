import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/widget/ScaffoldChatPage.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';
import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Scaffold;
import 'package:intl/intl.dart';
import 'package:mirror/api/training/training_gallery_api.dart';
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
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/loading.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// training_gallery_page
/// Created by yangjiayi on 2021/1/20.

class TrainingGalleryPage extends StatefulWidget {
  @override
  _TrainingGalleryState createState() => _TrainingGalleryState();
}

// 在插入新数据时 要根据时间日期插入到相应位置 所以循环分页加载直至加载全部数据
class _TrainingGalleryState extends State<TrainingGalleryPage> {
  final int _imageMaxSelection = 2;
  final int _pageSize = 100;

  bool _hasNext = true;
  int _lastTime;

  List<TrainingGalleryDayModel> _dataList = [];

  bool _isSelectionMode = false;
  CustomAppBar _normalModeAppBar;
  CustomAppBar _selectionModeAppBar;
  final List<TrainingGalleryImageModel> _selectedImageList = [];
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd');
  ItemScrollController itemScrollController = ItemScrollController();

  _initData() async {
    await _requestDataList();

    SuspensionUtil.setShowSuspensionStatus(_dataList);

    if (mounted) {
      setState(() {});
    }
  }

  _requestDataList() async {
    ListModel<TrainingGalleryDayModel> listModel = await getAlbum(_pageSize, lastTime: _lastTime);
    if (listModel != null) {
      if(listModel.hasNext!=null&& listModel.hasNext is int) {
        _hasNext = listModel.hasNext == 1;
      }else{
        _hasNext=false;
      }
      _lastTime = listModel?.lastTime;
      _dataList.addAll(listModel.list);
      if (_hasNext) {
        await _requestDataList();
      }
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }
  @override
  void initState() {
    super.initState();
    context.read<UserInteractiveNotifier>().value.showImageFrame = false;
    _initAppBar();
    _initData();
  }

  int _getImageSize() {
    int pagesize = 0;
    _dataList.forEach((element) {
      element.list.forEach((element) {
        pagesize++;
      });
    });
    return pagesize;
  }

  _initAppBar() {
    _selectionModeAppBar = CustomAppBar(
      titleString: "健身相册",
      leading: CustomAppBarTextButton("取消", AppColor.white, () {
        context.read<UserInteractiveNotifier>().changeShowImageFrame(false);
      }),
    );
    _normalModeAppBar = CustomAppBar(
      titleString: "健身相册",
      actions: [
        CustomAppBarIconButton(
            svgName: AppIcon.nav_camera,
            iconColor: AppColor.white,
            onTap: () {
              AppRouter.navigateToMediaPickerPage(
                  context, 1, typeImage, false, startPageGallery, false, _handleMediaResult);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.watch<UserInteractiveNotifier>().value.showImageFrame ? _selectionModeAppBar : _normalModeAppBar,
      body: _buildBody(),
      backgroundColor: AppColor.mainBlack,
      handleStatusBarTap: () {
        itemScrollController.scrollTo(index: 0, duration: Duration(milliseconds: 300));
      },
    );
  }

  Widget _buildBody() {
    if (_dataList.isEmpty) {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 224,
                width: 224,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "还没有照片",
                style: AppStyle.text1Regular14,
              )
            ],
          ),
        ),
      );
    } else {
      return Container(
        child: Column(
          children: [
            Expanded(
                child: AzListView(
                  itemScrollController: itemScrollController,
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
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        model.month,
        style: AppStyle.whiteMedium18,
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
              style: AppStyle.text1Medium16,
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
    if (context.read<UserInteractiveNotifier>().value.showImageFrame) {
      for (TrainingGalleryImageModel selected in _selectedImageList) {
        if (selected.id == imageModel.id) {
          isSelected = true;
          break;
        }
      }
    }
    return GestureDetector(
      onTap: () {
        if (context.read<UserInteractiveNotifier>().value.showImageFrame) {
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
          } else {
            //未选中 达到最大数量 提示用户只能选择2张
            ToastShow.show(msg: "最多选择2张照片", context: context);
          }
        } else {
          AppRouter.navigateToTrainingGalleryDetailPage(context, _dataList, (result) {
            if (RuntimeProperties.galleryResult == null) {
              return;
            }
            TrainingGalleryResult galleryResult = RuntimeProperties.galleryResult;
            RuntimeProperties.galleryResult  = null;
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
            context.read<ProfileNotifier>().setImagePageSize(_getImageSize());
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
              placeholder: (context, url) => Container(
                color: AppColor.imageBgGrey,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.imageBgGrey,
              ),
            ),
          ),
          isSelected
              ? Container(
                  padding: const EdgeInsets.all(6),
                  alignment: Alignment.bottomRight,
                  color: AppColor.imageBgGrey.withOpacity(0.35),
                  child: AppIcon.getAppIcon(AppIcon.selection_selected, 24),
                )
              : Container()
        ],
      ),
    );
  }

  _handleMediaResult(dynamic result) async {
    SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
    if (true != result || files == null) {
      print("没有选择媒体文件");
      return;
    }
    RuntimeProperties.selectedMediaFiles = null;
    print(files.type + ":" + files.list.toString());

    if (files.type != mediaTypeKeyImage) {
      return;
    }

    Loading.showLoading(context,infoText: "正在上传...请稍候");
    // _showRetryDialog(files, null);
    await _uploadImage(files);
  }

  _uploadImage(SelectedMediaFiles files) async {

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
          element.file = imageFile;
        }
      });
      UploadResults uploadResults = await FileUtil().uploadPics(fileList, (percent) {
        print("总进度:$percent");
      });

      await _afterUpload(files, uploadResults);

      Loading.hideLoading(context);
    } catch (e) {
      Loading.hideLoading(context);
      print("回调保存失败:$e");
      _showRetryDialog(files, null);
      // ToastShow.show(msg: "回调保存失败", context: context);
    }
  }

  _afterUpload(SelectedMediaFiles files, UploadResults uploadResults) async {
    if (uploadResults.isSuccess) {
      //整理接口入参 调接口
      List<Map<String, dynamic>> paramList = [];
      for (int i = 0; i < files.list.length; i++) {
        MediaFileModel mediaFileModel = files.list[i];
        paramList.add(TrainingGalleryImageModel(
                url: uploadResults.resultMap[mediaFileModel.file.path].url,
                width: mediaFileModel.sizeInfo.width.toDouble(),
                height: mediaFileModel.sizeInfo.height.toDouble(),
                createTime: mediaFileModel.sizeInfo.createTime)
            .toJson());
      }
      List<TrainingGalleryImageModel> saveList = await saveAlbum(paramList);

      if (saveList != null) {
        saveList.forEach((saveImage) {
          _insertImageToDataList(saveImage);
        });
        setState(() {});
        context.read<ProfileNotifier>().setImagePageSize(_getImageSize());
      } else {
        Loading.hideLoading(context);
        _showRetryDialog(files, uploadResults);
        print("接口保存失败");
        // ToastShow.show(msg: "接口保存失败", context: context);
      }
    } else {
      Loading.hideLoading(context);
      _showRetryDialog(files, null);
      print("文件上传失败");
      // ToastShow.show(msg: "文件上传失败", context: context);
    }
  }

  //如果uploadResults为空 视为没有完成上传
  _showRetryDialog(SelectedMediaFiles files, UploadResults uploadResults) {
    showAppDialog(
      context,
      title: "上传失败",
      info: "照片上传失败，是否点击重试",
      barrierDismissible: false,
      confirm: AppDialogButton("重试", () {
        //如果执行完再关闭弹窗可能会无限循环关不掉
        Navigator.pop(context);
        if (uploadResults == null) {
          _uploadImage(files);
        } else {
          _afterUpload(files, uploadResults);
        }
        return false;
      }),
      cancel: AppDialogButton("取消", () {
        return true;
      }),
    );
  }

  Widget _buildBottomView() {
    if (context.watch<UserInteractiveNotifier>().value.showImageFrame) {
      return Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, ScreenUtil.instance.bottomBarHeight),
        height: 145 + ScreenUtil.instance.bottomBarHeight,
        color: AppColor.layoutBgGrey,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "已选择${_selectedImageList.length}/$_imageMaxSelection张照片",
                    style: AppStyle.text1Regular14,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (_selectedImageList.length == _imageMaxSelection) {
                        //按时间排序入参
                        DateTime time0 = _dateTimeFormat.parse(_selectedImageList[0].dateTime);
                        DateTime time1 = _dateTimeFormat.parse(_selectedImageList[1].dateTime);
                        if (time1.isBefore(time0)) {
                          AppRouter.navigateToTrainingGalleryComparisonPage(
                              context, _selectedImageList[1], _selectedImageList[0]);
                        } else {
                          AppRouter.navigateToTrainingGalleryComparisonPage(
                              context, _selectedImageList[0], _selectedImageList[1]);
                        }
                      }
                    },
                    child: Text(
                      "继续",
                      style: _selectedImageList.length == _imageMaxSelection
                          ? AppStyle.whiteRegular14
                          : AppStyle.text1Regular14,
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
                            height: ScreenUtil.instance.bottomBarHeight == 0 ? 74 : 93,
                            width: ScreenUtil.instance.bottomBarHeight == 0 ? 74 : 93,
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                    imageUrl: _selectedImageList[0].url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColor.imageBgGrey,
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColor.imageBgGrey,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  color: AppColor.imageBgGrey.withOpacity(0.35),
                                  child: AppIcon.getAppIcon(AppIcon.selection_remove, 24),
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
                            height: ScreenUtil.instance.bottomBarHeight == 0 ? 74 : 93,
                            width: ScreenUtil.instance.bottomBarHeight == 0 ? 74 : 93,
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                    imageUrl: _selectedImageList[1].url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColor.imageBgGrey,
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColor.imageBgGrey,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  color: AppColor.imageBgGrey.withOpacity(0.35),
                                  child: AppIcon.getAppIcon(AppIcon.selection_remove, 24),
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
            context.read<UserInteractiveNotifier>().changeShowImageFrame(true);
          });
        },
        child: Container(
          padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
          height: 48 + ScreenUtil.instance.bottomBarHeight,
          color: AppColor.layoutBgGrey,
          alignment: Alignment.center,
          child: Text(
            "制作对比图",
            style: AppStyle.whiteRegular16,
          ),
        ),
      );
    }
  }

  _insertImageToDataList(TrainingGalleryImageModel saveImage) {
    if (_dataList.isNotEmpty) {
      DateTime imageTime = _dateTimeFormat.parse(saveImage.dateTime);
      for (int i = 0; i < _dataList.length; i++) {
        TrainingGalleryDayModel dayModel = _dataList[i];
        DateTime dayTime = _dateTimeFormat.parse(dayModel.dateTime);
        //时间倒序排列 所以当日期等于dayModel的值时插入该dayModel的list 小于时继续遍历 大于时新建并插入dayModel 小于最后一条也新建
        if (imageTime.isAtSameMomentAs(dayTime)) {
          dayModel.list.add(saveImage);
          //倒序排列
          dayModel.list.sort((a, b) => b.createTime.compareTo(a.createTime));
          //插入imageList并不影响日期标签
          //一定要break 不然可能会无限添加
          break;
        } else if (imageTime.isAfter(dayTime)) {
          TrainingGalleryDayModel newDayModel = TrainingGalleryDayModel();
          newDayModel.dateTime = saveImage.dateTime;
          newDayModel.list = [saveImage];
          _dataList.insert(i, newDayModel);
          //新建并插入dayModel可能会影响日期标签 所以重新设置
          SuspensionUtil.setShowSuspensionStatus(_dataList);
          //一定要break 不然可能会无限添加
          break;
        } else if (i == _dataList.length - 1 && imageTime.isBefore(dayTime)) {
          TrainingGalleryDayModel newDayModel = TrainingGalleryDayModel();
          newDayModel.dateTime = saveImage.dateTime;
          newDayModel.list = [saveImage];
          _dataList.add(newDayModel);
          //新建并插入dayModel可能会影响日期标签 所以重新设置
          SuspensionUtil.setShowSuspensionStatus(_dataList);
          //一定要break 不然可能会无限添加
          break;
        }
      }
    } else {
      TrainingGalleryDayModel newDayModel = TrainingGalleryDayModel();
      newDayModel.dateTime = saveImage.dateTime;
      newDayModel.list = [saveImage];
      _dataList.add(newDayModel);
      SuspensionUtil.setShowSuspensionStatus(_dataList);
    }
  }
}

class TrainingGalleryResult {
  //-1删除 1添加
  int operation;
  List<TrainingGalleryImageModel> list;
}
