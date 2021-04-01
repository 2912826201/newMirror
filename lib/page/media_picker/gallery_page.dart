import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/image_cropper.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

/// gallery_page
/// Created by yangjiayi on 2020/11/12.

final int _horizontalCount = 4;
final double _itemMargin = 1;
final int _galleryPageSize = 100;
final int _commitInterval = 1000;

// 相册的选择GridView视图 需要能够区分选择图片或视频 选择图片数量 是否裁剪 裁剪是否只是正方形
//TODO 目前没有做响应实时相册变化时的处理 完善时可以考虑实现
//FIXME 当有文件损坏等情况发生的场景需要应对
class GalleryPage extends StatefulWidget {
  GalleryPage(
      {Key key,
      this.maxImageAmount = 1,
      this.requestType = RequestType.common,
      this.needCrop = false,
      this.cropOnlySquare = false,
      this.publishMode = 0,
      this.fixedWidth,
      this.fixedHeight,
      this.startCount = 0,
      this.topicId})
      : super(key: key);

  final int maxImageAmount;
  final int maxVideoAmount = 1;
  final bool needCrop;
  final bool cropOnlySquare;
  final int publishMode;
  final int fixedWidth;
  final int fixedHeight;
  final int startCount;
  final int topicId;

  // image是图片 common是图片和视频 目前需求只会用到这两种
  final RequestType requestType;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

// AutomaticKeepAliveClientMixin支持重新切回页面后保持之前页面状态
// 需求修改 去掉了保留状态的需求
// class _GalleryPageState extends State<GalleryPage> with AutomaticKeepAliveClientMixin {
class _GalleryPageState extends State<GalleryPage> with WidgetsBindingObserver {
  var _cropperKey = GlobalKey<_GalleryPageState>();

  double _screenWidth = 0;
  double _itemSize = 0;
  double _previewMaxHeight = 0;
  double _previewMinHeight = 0;

  // 是否正在获取数据 防止同时重复请求
  bool _isFetchingData = false;

  // 当前路径的图片视频数
  int _mediaAmount = 0;

  // 相册列表
  List<AssetPathEntity> _albums = [];
  int _currentAlbumIndex = 0;

  // 资源实体的列表
  List<AssetEntity> _galleryList = [];

  // 实际资源文件的Map 因AssetEntity获取File是异步的 所以单独把获取后的结果存一下 避免重复耗时获取和减少处理异步回调的工序
  Map<String, File> _fileMap = {};

  // 资源缩略图的Map 因AssetEntity获取缩略图是异步的 所以单独把获取后的结果存一下 避免重复耗时获取和减少处理异步回调的工序
  Map<String, Uint8List> _thumbMap = {};

  // 已经请求的数据数量 因为要做过滤所以不能用_galleryList的长度
  int _galleryListLength = 0;

  bool _permissionGranted;

  bool _isPaused = false;

  // 右上角下一步按钮点击的时间戳
  int _commitTimeStamp = 0;

  bool _isGettingImage = false;

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //从notifier中取值
    _previewMaxHeight = context.read<PreviewHeightNotifier>().maxHeight;
    _previewMinHeight = context.read<PreviewHeightNotifier>().minHeight;

    //如果固定尺寸不为空 则赋值到notifier
    if (widget.fixedWidth != null && widget.fixedHeight != null) {
      context
          .read<SelectedMapNotifier>()
          .setFixedImageSize(Size(widget.fixedWidth.toDouble(), widget.fixedHeight.toDouble()));
    }

    _checkPermission();
  }

  //TODO 还需要处理iOS只给部分照片权限的情况
  _checkPermission() async {
    bool isGranted;
    //安卓和iOS的权限不一样
    if (Application.platform == 0) {
      isGranted = (await Permission.storage.status)?.isGranted;
    } else {
      isGranted = (await Permission.photos.status)?.isGranted;
    }

    if (isGranted == null) {
      isGranted = false;
    }
    if (isGranted == _permissionGranted) {
      //和当前权限一致 无需做处理
      return;
    } else if (isGranted) {
      //有权限 取数据
      _permissionGranted = isGranted;
      _fetchGalleryData(true);
    } else {
      //无权限 刷新界面
      _permissionGranted = isGranted;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 返回前台 检查权限
    // 只有paused才是真的离开了页面 会在弹窗弹出时进入inactived
    if (state == AppLifecycleState.resumed) {
      if (_isPaused) {
        _isPaused = false;
        _checkPermission();
      }
    }
    if (state == AppLifecycleState.paused) {
      _isPaused = true;
    }
  }

  // 获取相册数据
  _fetchGalleryData(bool isNew) async {
    if (_isFetchingData) {
      // 正在获取过程中则不做操作
      return;
    }
    _isFetchingData = true;
    // 已在之前做了权限请求不需要再请求
    if (_permissionGranted) {
      // success
      // load the album list
      if (_albums.isEmpty) {
        //相册目录列表为空时获取一下 加上筛选条件
        FilterOptionGroup filter = FilterOptionGroup();
        filter.setOption(
            AssetType.video,
            FilterOption(
                durationConstraint: DurationConstraint(min: Duration(seconds: 1), max: Duration(seconds: 60))));
        List<AssetPathEntity> pathList = await PhotoManager.getAssetPathList(
            hasAll: true, onlyAll: false, type: widget.requestType, filterOption: filter);
        //有可能全部照片、最近项目不在第一个 要重新排列一下
        List<AssetPathEntity> notAllList = [];
        for (AssetPathEntity assetPathEntity in pathList) {
          if (assetPathEntity.isAll) {
            _albums.add(assetPathEntity);
          } else {
            notAllList.add(assetPathEntity);
          }
        }
        _albums.addAll(notAllList);
        print(_albums);
      }

      //TODO 获取相册后还是空的情况需要测试是什么情况
      if (_albums.isNotEmpty) {
        _mediaAmount = _albums[_currentAlbumIndex].assetCount;
        if (isNew) {
          // 如果是该相册第一次请求 清空列表数据
          _galleryList.clear();
          _galleryListLength = 0;
        }
        // 用_galleryListLength做为已加载数量来进行分页请求
        List<AssetEntity> media = await _albums[_currentAlbumIndex]
            .getAssetListRange(start: _galleryListLength, end: _galleryListLength + _galleryPageSize);
        print(media);
        _galleryListLength += media.length;

        //TODO 对列表进行过滤 在查目录时做了视频时长过滤 这里没有其他过滤的话 暂时注释掉 直接addAll
        // for (AssetEntity assetEntity in media) {
        //   if (assetEntity.type == AssetType.image) {
        //     //FIXME 图片暂时无法过滤gif
        //     _galleryList.add(assetEntity);
        //   } else if (assetEntity.type == AssetType.video) {
        //     // 只保留小于60秒的视频
        //     if (assetEntity.duration < 60) {
        //       _galleryList.add(assetEntity);
        //     } else {
        //       print("过滤了视频：$assetEntity");
        //     }
        //   }
        // }
        _galleryList.addAll(media);

        if (mounted) {
          setState(() {});
        }
      }

      _isFetchingData = false;
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      _isFetchingData = false;
    }

    // 在裁剪模式中 刷新列表后重置选中项 还需要重置gridview的滚动offset和预览框位置
    if (widget.needCrop && isNew) {
      if (_galleryList.isEmpty) {
        // 列表为空 则清空
        context.read<SelectedMapNotifier>().setCurrentEntity(null);
      } else if (context.read<SelectedMapNotifier>().currentEntity == null) {
        // 列表不为空 且当前没有选中任何一条 则选中第一条
        _onGridItemTap(context, _galleryList.first);
      }

      context.read<PreviewHeightNotifier>().reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 保留状态需要执行父方法
    // super.build(context);
    // 获取屏幕宽以设置各布局大小
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    print("屏幕宽为：$_screenWidth");
    _itemSize = (_screenWidth - _itemMargin * (_horizontalCount - 1)) / _horizontalCount;
    print("item宽为：$_itemSize");
    return _permissionGranted != null && _permissionGranted
        ? Scaffold(
            appBar: _buildAppBar(),
            body: Stack(
              overflow: Overflow.clip,
              children: [
                // 背景
                Container(
                  color: AppColor.bgBlack,
                ),
                // 列表
                ScrollConfiguration(
                  behavior: NoBlueEffectBehavior(),
                  child: _buildScrollBody(),
                ),
                widget.needCrop
                    ?
                    // 裁剪区域
                    Positioned(
                        top: context.watch<PreviewHeightNotifier>().previewHeight - _previewMaxHeight,
                        child: Container(
                          color: AppColor.black,
                          width: _previewMaxHeight,
                          height: _previewMaxHeight,
                          child: Builder(
                            builder: (context) {
                              AssetEntity entity =
                                  context.select((SelectedMapNotifier notifier) => notifier.currentEntity);
                              Size selectedSize =
                                  context.select((SelectedMapNotifier notifier) => notifier.selectedImageSize);
                              return entity == null
                                  ? Container()
                                  : Stack(
                                      children: [
                                        entity.type == AssetType.video
                                            ? VideoPreviewArea(
                                                _fileMap[entity.id],
                                                _screenWidth,
                                                context.select(
                                                    (SelectedMapNotifier notifier) => notifier.useOriginalRatio))
                                            : entity.type == AssetType.image
                                                ? CropperImage(
                                                    _fileMap[entity.id] != null
                                                        ? FileImage(_fileMap[entity.id])
                                                        : MemoryImage(_thumbMap[entity.id] ?? Uint8List.fromList([])),
                                                    round: 0,
                                                    maskPadding: 0,
                                                    outHeight: (selectedSize == null
                                                            ? _getImageOutSize(
                                                                entity,
                                                                context.select((SelectedMapNotifier notifier) =>
                                                                    notifier.useOriginalRatio))
                                                            : selectedSize)
                                                        .height,
                                                    outWidth: (selectedSize == null
                                                            ? _getImageOutSize(
                                                                entity,
                                                                context.select((SelectedMapNotifier notifier) =>
                                                                    notifier.useOriginalRatio))
                                                            : selectedSize)
                                                        .width,
                                                    key: _cropperKey,
                                                    backBoxColor0: AppColor.transparent,
                                                    backBoxColor1: AppColor.transparent,
                                                  )
                                                : Container(),
                                        _fileMap[entity.id] == null
                                            ? Center(
                                                child: CircularProgressIndicator(),
                                              )
                                            : Container(),
                                      ],
                                    );
                            },
                          ),
                        ),
                      )
                    : Container(),
                widget.needCrop &&
                        !widget.cropOnlySquare &&
                        context.select((SelectedMapNotifier notifier) => notifier.selectedImageSize == null)
                    ? Positioned(
                        top: context.watch<PreviewHeightNotifier>().previewHeight - 12 - 36,
                        left: 12,
                        child: AppIconButton(
                          isCircle: true,
                          bgColor: AppColor.textPrimary2.withOpacity(0.65),
                          onTap: _changeCurrentRatio,
                          iconSize: 24,
                          svgName: AppIcon.gallery_fullsize,
                          buttonWidth: 36,
                          buttonHeight: 36,
                        ),
                      )
                    : Container(),
                context.select((SelectedMapNotifier value) => value.isAlbumListShow) ? _buildAlbumList() : Container(),
              ],
            ),
          )
        : Scaffold(
            // 无权限时的布局
            backgroundColor: AppColor.bgBlack,
            appBar: CustomAppBar(
              backgroundColor: AppColor.black,
              brightness: Brightness.dark,
              hasLeading: widget.publishMode == 2 ? false : true,
              leading: CustomAppBarIconButton(
                  svgName: AppIcon.nav_close,
                  iconColor: AppColor.white,
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ),
            body: Container(
              width: _screenWidth,
              child: _permissionGranted != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "请授权iFitness照片权限",
                          style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16),
                        ),
                        Text(
                          "便于您进行照片编辑和图片保存",
                          style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            PermissionStatus status;
                            //安卓和iOS的权限不一样
                            if (Application.platform == 0) {
                              status = await Permission.storage.status;
                            } else {
                              status = await Permission.photos.status;
                            }

                            if (status.isGranted) {
                              _permissionGranted = true;
                              _fetchGalleryData(true);
                            } else if (status.isPermanentlyDenied) {
                              //安卓的禁止且之后不提示
                              AppSettings.openAppSettings();
                            } else {
                              //安卓或者从未请求过权限则重新请求 iOS跳设置页
                              if (Application.platform == 0) {
                                status = await Permission.storage.request();
                                if (status.isGranted) {
                                  _permissionGranted = true;
                                  _fetchGalleryData(true);
                                }
                              } else {
                                if (status.isUndetermined) {
                                  status = await Permission.photos.status;
                                  if (status.isGranted) {
                                    _permissionGranted = true;
                                    _fetchGalleryData(true);
                                  }
                                } else {
                                  AppSettings.openAppSettings();
                                }
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 34,
                            width: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(color: AppColor.mainRed.withOpacity(0.85), width: 0.5),
                            ),
                            child: Text(
                              "去授权",
                              style: TextStyle(color: AppColor.mainRed.withOpacity(0.85), fontSize: 16),
                            ),
                          ),
                        ),
                        // 为了尽量让按钮居中
                        SizedBox(
                          height: 56,
                        ),
                      ],
                    )
                  : Container(),
            ),
          );
  }

  // item本体点击事件
  _onGridItemTap(BuildContext context, AssetEntity entity) async {
    if (_isGettingImage) {
      return;
    }

    final notifier = context.read<SelectedMapNotifier>();
    if (notifier.currentEntity != null && entity.id == notifier.currentEntity.id) {
      //如果之前选中的和点到的一样 则不做操作
      return;
    }

    // 在裁剪模式中如果之前预览的已被选中 那么获取其图像 保存下来 然后再去预览新点中的图像
    // 当最后一张图是预览并选中时 需要在点击下一步按钮时获取这张图
    if (widget.needCrop) {
      if (notifier.currentEntity != null && notifier.selectedMap.containsKey(notifier.currentEntity.id)) {
        _getImage(context, notifier.currentEntity.id, toData: false);
      }
    }

    //FIXME 这里iOS如果文件在iCloud 会取不到。。。
    if (_fileMap[entity.id] == null) {
      entity.file.then((value) {
        _fileMap[entity.id] = value;
        print("取到媒体文件：" + entity.id + ":" + value.path);
        if (notifier.currentEntity.id == entity.id) {
          //如果当前预览的和正在加载的是一致的 则刷新界面
          print("相册刷新了界面");
          setState(() {});
        }
      }).catchError((e) {
        print("媒体文件报错：" + entity.id + ":" + e);
      });
      if (widget.needCrop) {
        // 裁剪模式需要将其置入裁剪框
        notifier.setCurrentEntity(entity);
      } else {
        //TODO 非裁剪模式跳转展示大图
      }
    } else {
      print("已有媒体文件：" + entity.id + ":" + _fileMap[entity.id].path);
      if (widget.needCrop) {
        // 裁剪模式需要将其置入裁剪框
        notifier.setCurrentEntity(entity);
      } else {
        //TODO 非裁剪模式跳转展示大图
      }
    }
  }

  // item选框点击事件
  // 当点中选框的文件并不是当前预览的文件时 还要将其选中设置预览
  _onCheckBoxTap(BuildContext context, AssetEntity entity) {
    if (_isGettingImage) {
      return;
    }
    entity.file.then((value) => print(entity.id + ":" + value.path));
    bool isNew = context.read<SelectedMapNotifier>().handleMapChange(entity);
    if (isNew) {
      _onGridItemTap(context, entity);
    }
  }

  Widget _buildGridItem(BuildContext context, int index) {
    // print("#${index} item loaded");
    // 当加载到距离list的长度还有一行时 请求下一页数据
    if (_galleryListLength < _mediaAmount && _galleryList.length - index <= _horizontalCount * 2) {
      _fetchGalleryData(false);
    }
    AssetEntity entity = _galleryList[index];
    // 一定要返回某种形式的Builder 不然context.select会报错
    if (_thumbMap[entity.id] == null) {
      return Container(
        height: _itemSize,
        width: _itemSize,
        color: AppColor.textPrimary2,
        child: FutureBuilder(
          future: entity.thumbDataWithSize(_itemSize.toInt(), _itemSize.toInt()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _thumbMap[entity.id] = snapshot.data;
              return _buildGridItemCell(context, entity);
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      return Container(
        height: _itemSize,
        width: _itemSize,
        color: AppColor.textPrimary2,
        child: Builder(builder: (context) => _buildGridItemCell(context, entity)),
      );
    }
  }

  Widget _buildGridItemCell(BuildContext context, AssetEntity entity) {
    SelectedMapNotifier notifier = context.watch<SelectedMapNotifier>();
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _onGridItemTap(context, entity),
          child: Stack(overflow: Overflow.clip, children: [
            // Builder(builder: (context){
            //   if(_thumbMap[entity.id] == null){
            //     return Image.memory(
            //       _thumbMap[entity.id],
            //       fit: BoxFit.cover,
            //       height: _itemSize,
            //       width: _itemSize,
            //     );
            //   }else{
            //     print("缩略图是空的！！！");
            //     print("${entity.relativePath}");
            //     return Container();
            //   }
            //
            //
            // }),
            _thumbMap[entity.id] != null
                ? Image.memory(
                    _thumbMap[entity.id],
                    fit: BoxFit.cover,
                    height: _itemSize,
                    width: _itemSize,
                  )
                : Container(),
            Container(
              height: _itemSize,
              width: _itemSize,
              decoration: BoxDecoration(
                border: Border.all(
                    color: notifier.currentEntity == null || notifier.currentEntity.id != entity.id
                        ? AppColor.transparent
                        : AppColor.mainRed,
                    width: 2,
                    style: BorderStyle.solid),
              ),
            ),
            Positioned(
              bottom: 3.5,
              right: 4,
              child: Text(
                entity.type == AssetType.video
                    ? "${DateFormat("mm:ss").format(DateTime.fromMillisecondsSinceEpoch(entity.duration * 1000))}"
                    : entity.type == AssetType.image
                        ? ""
                        : "",
                style: TextStyle(color: AppColor.white, fontSize: 9),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onCheckBoxTap(context, entity),
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  child: notifier.selectedMap.containsKey(entity.id)
                      ? Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColor.mainRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.mainRed, width: 1),
                          ),
                          child: widget.maxImageAmount == 1 && widget.startCount == 0
                              ? Icon(
                                  Icons.check,
                                  color: AppColor.white,
                                  size: 16,
                                )
                              : Text(
                                  "${notifier.selectedMap[entity.id].order + widget.startCount}",
                                  style: TextStyle(color: AppColor.white, fontSize: 16),
                                ),
                        )
                      : Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.36),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.white, width: 1),
                          ),
                        ),
                ),
              ),
            ),
          ]),
        ),
        //选满了 但该item没有被选 则显示蒙层
        //当选了图片则视频显示蒙层，选了视频则图片显示蒙层
        (notifier.selectedType != null && entity.type != notifier.selectedType) ||
                (notifier.selectedMap.length >=
                        (notifier.selectedType == AssetType.image ? widget.maxImageAmount : widget.maxVideoAmount) &&
                    !notifier.selectedMap.containsKey(entity.id))
            ? Container(
                color: AppColor.textPrimary2.withOpacity(0.45),
              )
            : Container(),
      ],
    );
  }

  // 列表界面主体部分
  Widget _buildScrollBody() {
    if (widget.needCrop) {
      //需要裁剪
      return Builder(builder: (context) {
        return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              ScrollMetrics metrics = notification.metrics;
              // 注册通知回调
              if (notification is ScrollStartNotification) {
                // 滚动开始
              } else if (notification is ScrollUpdateNotification) {
                // 滚动位置更新
                // 当前位置
                // print("metrics.pixels当前值是：${metrics.pixels}");
                context.read<PreviewHeightNotifier>().setOffset(metrics.pixels);
              } else if (notification is ScrollEndNotification) {
                // 滚动结束
              }
              return false;
            },
            child: CustomScrollView(
              //禁止回弹效果
              physics: ClampingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                    floating: true,
                    pinned: false,
                    delegate: _PreviewHeaderDelegate(
                      // 这里就让header是个不可变的高度 所以最小高度传入和最大高度一样
                      minHeight: _previewMaxHeight,
                      maxHeight: _previewMaxHeight,
                      // child:
                      // CropperImage(
                      //   NetworkImage("http://pic1.win4000.com/wallpaper/2020-11-02/5f9f821a8d00a.jpg"),
                      //   round: 0,
                      // ),
                    )),
                SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      _buildGridItem,
                      childCount: _galleryList.length,
                    ),
                    gridDelegate: _galleryGridDelegate())
              ],
            ));
      });
    } else {
      //不需要裁剪
      return GridView.builder(
          //禁止回弹效果
          physics: ClampingScrollPhysics(),
          itemCount: _galleryList.length,
          gridDelegate: _galleryGridDelegate(),
          itemBuilder: _buildGridItem);
    }
  }

  // 构建标题栏
  Widget _buildAppBar() {
    return CustomAppBar(
      backgroundColor: AppColor.black,
      brightness: Brightness.dark,
      hasLeading: widget.publishMode == 2 ? false : true,
      leading: context.select((SelectedMapNotifier value) => value.isAlbumListShow)
          ? CustomAppBarIconButton(
              svgName: AppIcon.nav_close,
              iconColor: AppColor.white,
              onTap: () {
                context
                    .read<SelectedMapNotifier>()
                    .setIsAlbumListShow(!context.read<SelectedMapNotifier>().isAlbumListShow);
              })
          : CustomAppBarIconButton(
              svgName: AppIcon.nav_close,
              iconColor: AppColor.white,
              onTap: () {
                Navigator.pop(context);
              }),
      titleWidget: _albums.length > 0
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context
                    .read<SelectedMapNotifier>()
                    .setIsAlbumListShow(!context.read<SelectedMapNotifier>().isAlbumListShow);
              },
              child: Container(
                height: CustomAppBar.appBarHeight,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _albums[_currentAlbumIndex].name,
                      style: AppStyle.whiteRegular16,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Icon(
                      context.select((SelectedMapNotifier value) => value.isAlbumListShow)
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColor.white,
                    ),
                  ],
                ),
              ),
            )
          : Container(),
      actions: [
        Container(
          padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
          child: CustomRedButton(
            "下一步",
            context.select((SelectedMapNotifier value) => value.selectedMap.isEmpty && value.currentEntity == null)
                ? CustomRedButton.buttonStateDisable
                : CustomRedButton.buttonStateNormal,
            () async {
              int time = DateTime.now().millisecondsSinceEpoch;
              if (time - _commitTimeStamp < _commitInterval) {
                return;
              }
              _commitTimeStamp = time;

              // 先处理选中的结果
              final notifier = context.read<SelectedMapNotifier>();

              String type;
              //没有选中时将当前预览的选项视为选中 因按钮可用条件中不会出现两者都无的可能所以没进一步做非空判断
              AssetType selectedResultType = notifier.selectedType ?? notifier.currentEntity.type;
              switch (selectedResultType) {
                case AssetType.image:
                  type = mediaTypeKeyImage;
                  break;
                case AssetType.video:
                  type = mediaTypeKeyVideo;
                  break;
                default:
                  // 其他类型则程序有错误
                  return;
              }

              // 在裁剪模式下 当前预览的图像如果是选中的图（如果没有选中的 当前预览的就算选中） 则需要获取下裁剪后的图像
              if (widget.needCrop && selectedResultType == AssetType.image) {
                if (notifier.currentEntity != null &&
                    (notifier.selectedMap.isEmpty || notifier.selectedMap.containsKey(notifier.currentEntity.id))) {
                  await _getImage(context, notifier.currentEntity.id, toData: false);
                }
              }

              // 最后结果的列表
              List<MediaFileModel> mediaFileList = [];

              Map<String, _OrderedAssetEntity> selectedMap = notifier.selectedMap;
              if (selectedMap.isEmpty) {
                if (notifier.currentEntity != null) {
                  // 将当前正在预览的放入已选map中
                  _OrderedAssetEntity orderedEntity = _OrderedAssetEntity(1, notifier.currentEntity);
                  selectedMap[notifier.currentEntity.id] = orderedEntity;
                } else {
                  // 如果已选中的列表是空的 而且没有正在预览的 则程序有错误
                  return;
                }
              }
              // 先根据长度将model放入list
              for (int i = 0; i < selectedMap.length; i++) {
                mediaFileList.add(MediaFileModel());
              }
              // 遍历所选Map将结果赋值
              for (_OrderedAssetEntity orderedEntity in selectedMap.values) {
                // order要减1才是index
                MediaFileModel mediaFileModel = mediaFileList[orderedEntity.order - 1];
                mediaFileModel.type = type;
                // 根据类型处理文件信息及尺寸信息
                if (widget.needCrop) {
                  switch (selectedResultType) {
                    case AssetType.image:
                      mediaFileModel.croppedImage = notifier.imageMap[orderedEntity.entity.id];
                      mediaFileModel.croppedImageData = notifier.imageDataMap[orderedEntity.entity.id];
                      mediaFileModel.sizeInfo.height = mediaFileModel.croppedImage.height;
                      mediaFileModel.sizeInfo.width = mediaFileModel.croppedImage.width;
                      mediaFileModel.sizeInfo.createTime = DateTime.now().millisecondsSinceEpoch;
                      break;
                    case AssetType.video:
                      mediaFileModel.file = _fileMap[orderedEntity.entity.id];
                      mediaFileModel.thumb = _thumbMap[orderedEntity.entity.id];
                      mediaFileModel.sizeInfo.height = orderedEntity.entity.height;
                      mediaFileModel.sizeInfo.width = orderedEntity.entity.width;
                      mediaFileModel.sizeInfo.duration = orderedEntity.entity.duration;
                      mediaFileModel.sizeInfo.createTime = orderedEntity.entity.createDtSecond * 1000;
                      SizeInfo sizeInfo = notifier.offsetMap[mediaFileModel.file.path];
                      if (sizeInfo != null) {
                        mediaFileModel.sizeInfo.offsetRatioX = sizeInfo.offsetRatioX;
                        mediaFileModel.sizeInfo.offsetRatioY = sizeInfo.offsetRatioY;
                      }

                      mediaFileModel.sizeInfo.videoCroppedRatio =
                          notifier.videoCroppedRatioMap[mediaFileModel.file.path];

                      break;
                    default:
                      break;
                  }
                } else {
                  mediaFileModel.file = _fileMap[orderedEntity.entity.id];
                  mediaFileModel.thumb = _thumbMap[orderedEntity.entity.id];
                  mediaFileModel.sizeInfo.height = orderedEntity.entity.height;
                  mediaFileModel.sizeInfo.width = orderedEntity.entity.width;
                  mediaFileModel.sizeInfo.duration = orderedEntity.entity.duration;
                  mediaFileModel.sizeInfo.createTime = orderedEntity.entity.createDtSecond * 1000;
                }
              }
              // 赋值并退出页面
              SelectedMediaFiles files = SelectedMediaFiles();
              files.type = type;
              files.list = mediaFileList;

              Application.selectedMediaFiles = files;

              if (widget.publishMode == 1) {
                Navigator.pop(context, true);
                AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
              } else if (widget.publishMode == 2) {
                AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
                if (Application.ifPageController != null) {
                  Application.ifPageController.index = Application.ifPageController.length - 1;
                }
              } else {
                Navigator.pop(context, true);
              }
            },
            isDarkBackground: true,
          ),
        )
      ],
    );
  }

  //构建选相册目录列表
  Widget _buildAlbumList() {
    return Container(
      color: AppColor.bgBlack,
      child: ListView.builder(
          itemCount: _albums.length,
          itemBuilder: (context, index) {
            return Container(
              height: 103,
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context
                      .read<SelectedMapNotifier>()
                      .setIsAlbumListShow(!context.read<SelectedMapNotifier>().isAlbumListShow);
                  if (_currentAlbumIndex != index) {
                    _currentAlbumIndex = index;
                    _fetchGalleryData(true);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Container(
                        height: 93,
                        width: 93,
                        color: AppColor.textPrimary2,
                        //先拿第一个文件
                        child: FutureBuilder(
                          future: _albums[index].getAssetListRange(start: 0, end: 1),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              List<AssetEntity> entityList = snapshot.data;
                              if (entityList.isNotEmpty) {
                                //文件不为空时 加载缩略图 复用缩略图map 不存在则请求缩略图
                                if (_thumbMap[entityList.first.id] == null) {
                                  return FutureBuilder(
                                    future: entityList.first.thumbDataWithSize(_itemSize.toInt(), _itemSize.toInt()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        _thumbMap[entityList.first.id] = snapshot.data;
                                        return Image.memory(
                                          _thumbMap[entityList.first.id],
                                          fit: BoxFit.cover,
                                          height: 93,
                                          width: 93,
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  );
                                } else {
                                  return Image.memory(
                                    _thumbMap[entityList.first.id],
                                    fit: BoxFit.cover,
                                    height: 93,
                                    width: 93,
                                  );
                                }
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        )),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_albums[index].name}",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text("${_albums[index].assetCount}",
                              style: TextStyle(
                                color: AppColor.white.withOpacity(0.35),
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  _getImage(BuildContext context, String id, {bool toData = false}) async {
    print("开始获取" + DateTime.now().millisecondsSinceEpoch.toString());
    _isGettingImage = true;
    ui.Image image = await (_cropperKey.currentContext as CropperImageElement).outImage();

    print("1已获取到ui.Image" + DateTime.now().millisecondsSinceEpoch.toString());
    print(image);
    context.read<SelectedMapNotifier>().addImage(id, image);
    // 将图片数据先转好可节省后续转换的用时
    if (toData) {
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
      Uint8List picBytes = byteData.buffer.asUint8List();
      print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
      context.read<SelectedMapNotifier>().addImageData(id, picBytes);
    }
    _isGettingImage = false;
  }

  _changeCurrentRatio() {
    context.read<SelectedMapNotifier>().changeUseOriginalRatio();
  }
}

// 用来记录排序
class _OrderedAssetEntity {
  _OrderedAssetEntity(this.order, this.entity);

  // 顺序
  int order;

  // 资源实体
  AssetEntity entity;
}

// 选中的列表数据状态通知
class SelectedMapNotifier with ChangeNotifier {
  SelectedMapNotifier(this.maxImageAmount, this.maxVideoAmount);

  int maxImageAmount;
  int maxVideoAmount;

  bool _isAlbumListShow = false;

  bool get isAlbumListShow => _isAlbumListShow;

  AssetEntity _currentEntity;

  AssetEntity get currentEntity => _currentEntity;

  bool _useOriginalRatio = false;

  bool get useOriginalRatio => _useOriginalRatio;

  // 所选类型只能有一种
  AssetType _selectedType;

  AssetType get selectedType => _selectedType;

  Map<String, _OrderedAssetEntity> _selectedMap = {};

  Map<String, _OrderedAssetEntity> get selectedMap => _selectedMap;

  // 记录视频的偏移值
  Map<String, SizeInfo> _offsetMap = {};

  Map<String, SizeInfo> get offsetMap => _offsetMap;

  // 记录视频的裁剪预览比例
  Map<String, double> _videoCroppedRatioMap = {};

  Map<String, double> get videoCroppedRatioMap => _videoCroppedRatioMap;

  // 用来存放已经裁剪好的图像数据
  Map<String, ui.Image> _imageMap = {};

  Map<String, ui.Image> get imageMap => _imageMap;

  Map<String, Uint8List> _imageDataMap = {};

  Map<String, Uint8List> get imageDataMap => _imageDataMap;

  // 记录已选的图片裁剪尺寸
  Size _selectedImageSize;

  Size _fixedImageSize;

  Size get selectedImageSize => _fixedImageSize == null ? _selectedImageSize : _fixedImageSize;

  _removeFromSelectedMap(AssetEntity entity) {
    //删掉目标entity还要将排序重新整理
    _OrderedAssetEntity orderedEntity = _selectedMap[entity.id];
    _selectedMap.remove(entity.id);
    for (_OrderedAssetEntity e in _selectedMap.values) {
      //遍历已选列表 排序大于删除项的 将排序-1
      if (e.order > orderedEntity.order) {
        e.order--;
      }
    }
    if (_selectedMap.isEmpty) {
      // 如果已选列表为空时 清空已选类型
      _selectedType = null;
      // 清空已选图片尺寸
      _selectedImageSize = null;
    }
  }

  _addToSelectedMap(AssetEntity entity) {
    if (_selectedMap.isEmpty) {
      // 如果是第一条数据 则设置已选类型
      _selectedType = entity.type;
      // 如果所选的是图片 要记录它的尺寸 之后的图片都要沿用
      if (entity.type == AssetType.image) {
        _selectedImageSize = _getImageOutSize(entity, _useOriginalRatio);
      }
    }
    //在添加数据时 排序为已选数量+1
    _OrderedAssetEntity orderedEntity = _OrderedAssetEntity(_selectedMap.length + 1, entity);
    _selectedMap[entity.id] = orderedEntity;
  }

  bool isFull() {
    // 未知类型时先给个最低的1张上限
    int maxAmount = _selectedType == AssetType.image
        ? maxImageAmount
        : _selectedType == AssetType.video
            ? maxVideoAmount
            : 1;
    return _selectedMap.length >= maxAmount;
  }

  bool handleMapChange(AssetEntity entity) {
    bool isNewEntity = false;
    if (_selectedType != null && entity.type != _selectedType) {
      // 已选类型不为空 且与所选文件类型不符时不做操作
      return isNewEntity;
    }
    if (_selectedMap.keys.contains(entity.id)) {
      //已在所选列表中
      _removeFromSelectedMap(entity);
      notifyListeners();
    } else if (!isFull()) {
      //未在所选列表中 且已选数量未达到上限
      _addToSelectedMap(entity);
      isNewEntity = true;
      notifyListeners();
    }
    return isNewEntity;
  }

  setIsAlbumListShow(bool isShow) {
    _isAlbumListShow = isShow;
    notifyListeners();
  }

  setCurrentEntity(AssetEntity entity) {
    // 判断是否真的变化 如果一方为null时 统一视为变化
    if (_currentEntity == null || entity == null || _currentEntity.id != entity.id) {
      _currentEntity = entity;
      notifyListeners();
    }
  }

  changeUseOriginalRatio() {
    _useOriginalRatio = !_useOriginalRatio;
    notifyListeners();
  }

  setFixedImageSize(Size size) {
    _fixedImageSize = size;
  }

  addImage(String id, ui.Image image) {
    _imageMap[id] = image;
  }

  addImageData(String id, Uint8List imageData) {
    _imageDataMap[id] = imageData;
  }

  removeImage(String id) {
    _imageMap.remove(id);
  }

  removeImageData(String id) {
    _imageDataMap.remove(id);
  }

  setOffset(String key, double offsetRatioX, double offsetRatioY) {
    SizeInfo sizeInfo = SizeInfo();
    sizeInfo.offsetRatioX = offsetRatioX;
    sizeInfo.offsetRatioY = offsetRatioY;
    _offsetMap[key] = sizeInfo;
  }

  setVideoCroppedRatio(String key, double ratio) {
    _videoCroppedRatioMap[key] = ratio;
  }
}

// 用于监听及更新裁剪预览布局的高度
class PreviewHeightNotifier with ChangeNotifier {
  PreviewHeightNotifier(this._previewBaseHeight);

  double _previewBaseHeight;

  double _previewHeight;

  double get maxHeight => _previewBaseHeight;

  //最小高度根据最大高度的一定比例得出 可调整
  double get minHeight => _previewBaseHeight / 3;

  double get previewHeight => _previewHeight ?? _previewBaseHeight;

  double _offset = 0;

  reset() {
    _previewHeight = _previewBaseHeight;
    _offset = 0;

    notifyListeners();
  }

  setOffset(double offset) {
    // 根据滚动距离计算预览框高度
    // 向上滑动的距离 正即为向上滑 负则为向下滑 0则为没有动
    double distance = offset - _offset;
    // 算完后赋值
    _offset = offset;
    // 理论上新的高度为旧的高度减去向上滑动的距离
    double newPreviewHeight = previewHeight - distance;
    // 结果如果超出范围 纠正为范围阈值
    if (newPreviewHeight > maxHeight) {
      newPreviewHeight = maxHeight;
    } else if (newPreviewHeight < minHeight) {
      newPreviewHeight = minHeight;
    }
    // 算完后赋值
    _previewHeight = newPreviewHeight;

    notifyListeners();
  }
}

// 约束Grid尺寸样式的delegate
SliverGridDelegateWithFixedCrossAxisCount _galleryGridDelegate() {
  return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _horizontalCount,
      childAspectRatio: 1,
      mainAxisSpacing: _itemMargin,
      crossAxisSpacing: _itemMargin);
}

// 裁剪预览区域的delegate 目前没有把预览区域放到这个header里了 这里只是占个位置
class _PreviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PreviewHeaderDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // print("shrinkOffset当前值是：$shrinkOffset");
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_PreviewHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}

class VideoPreviewArea extends StatefulWidget {
  VideoPreviewArea(this.file, this.previewWidth, this.useOriginalRatio, {Key key}) : super(key: key);

  final File file;
  final double previewWidth;
  final bool useOriginalRatio;

  @override
  VideoPreviewState createState() => VideoPreviewState();
}

class VideoPreviewState extends State<VideoPreviewArea> {
  File _file;
  VideoPlayerController _controller;
  Future<void> _initVideoPlayerFuture;

  @override
  void initState() {
    _file = widget.file;
    context.read<SelectedMapNotifier>().setOffset(_file.path, 0.0, 0.0);
    _controller = VideoPlayerController.file(_file);
    _initVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    print("VideoPreview dispose");
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoPreviewArea oldWidget) {
    if (_controller != null && _file != widget.file) {
      _controller.dispose();
      _file = widget.file;
      context.read<SelectedMapNotifier>().setOffset(_file.path, 0.0, 0.0);
      _controller = VideoPlayerController.file(_file);
      _initVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("aspectRatio:${_controller.value.aspectRatio}");
            if (!_controller.value.isPlaying) {
              _controller.play();
            }
            _VideoPreviewSize _previewSize =
                _getVideoPreviewSize(_controller.value.aspectRatio, widget.previewWidth, widget.useOriginalRatio);
            context.watch<SelectedMapNotifier>().setVideoCroppedRatio(_file.path, _previewSize.videoCroppedRatio);
            //初始位置就是(0，0)所以暂不做初始偏移值的处理
            return ScrollConfiguration(
              behavior: NoBlueEffectBehavior(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  // 注册通知回调
                  if (notification is ScrollStartNotification) {
                    // 滚动开始
                  } else if (notification is ScrollUpdateNotification) {
                    // 滚动位置更新
                    // 当前位置
                    // print("metrics.pixels当前值是：${metrics.pixels}");
                    if (_controller.value.aspectRatio > 1) {
                      //横向
                      double offsetRatioX = -metrics.pixels / _previewSize.height / _controller.value.aspectRatio;
                      context.read<SelectedMapNotifier>().setOffset(_file.path, offsetRatioX, 0.0);
                    } else {
                      //纵向
                      double offsetRatioY = -metrics.pixels / _previewSize.width * _controller.value.aspectRatio;
                      context.read<SelectedMapNotifier>().setOffset(_file.path, 0.0, offsetRatioY);
                    }
                  } else if (notification is ScrollEndNotification) {
                    // 滚动结束
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  //禁止回弹效果
                  physics: ClampingScrollPhysics(),
                  //根据比例设置方向
                  scrollDirection: _controller.value.aspectRatio > 1 ? Axis.horizontal : Axis.vertical,
                  child: Container(
                    alignment: Alignment.center,
                    width: _previewSize.width,
                    height: _previewSize.height,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

// 获取图片裁剪输出尺寸
Size _getImageOutSize(AssetEntity entity, bool useOriginalRatio) {
  double _outWidth;
  double _outHeight;

  if (useOriginalRatio) {
    double ratio = entity.width / entity.height;
    // 因为最终图片宽度会填满屏幕宽度展示 所以图片始终保证宽度为固定标准
    // ratio的double类型计算可能会增加误差 所以不重新赋值ratio时 用宽高计算
    _outWidth = baseOutSize;
    if (ratio < minMediaRatio) {
      ratio = minMediaRatio;
      _outHeight = _outWidth / ratio;
    } else if (ratio > maxMediaRatio) {
      ratio = maxMediaRatio;
      _outHeight = _outWidth / ratio;
    } else {
      _outHeight = _outWidth * entity.height / entity.width;
    }
  } else {
    _outWidth = baseOutSize;
    _outHeight = baseOutSize;
  }

  return Size(_outWidth, _outHeight);
}

class _VideoPreviewSize extends Size {
  _VideoPreviewSize(double width, double height) : super(width, height);

  double videoCroppedRatio;
}

// 获取视频预览区域宽高
_VideoPreviewSize _getVideoPreviewSize(double ratio, double _previewWidth, bool useOriginalRatio) {
  double _videoWidth;
  double _videoHeight;
  double _videoCroppedRatio;

  if (useOriginalRatio) {
    if (ratio < minMediaRatio) {
      //细高的情况 先限定最宽的宽度 再根据ratio算出高度
      _videoWidth = _previewWidth * minMediaRatio;
      _videoHeight = _previewWidth * minMediaRatio / ratio;
      _videoCroppedRatio = minMediaRatio;
    } else if (ratio < 1) {
      //填满高度
      _videoHeight = _previewWidth;
      _videoWidth = _previewWidth * ratio;
      _videoCroppedRatio = ratio;
    } else if (ratio > maxMediaRatio) {
      //扁长的情况 先限定最高的高度 再根据ratio算出宽度
      _videoHeight = _previewWidth / maxMediaRatio;
      _videoWidth = _previewWidth * ratio / maxMediaRatio;
      _videoCroppedRatio = maxMediaRatio;
    } else if (ratio > 1) {
      //填满宽度
      _videoHeight = _previewWidth / ratio;
      _videoWidth = _previewWidth;
      _videoCroppedRatio = ratio;
    } else {
      //剩余的就是ratio == 1的情况
      _videoHeight = _previewWidth;
      _videoWidth = _previewWidth;
      _videoCroppedRatio = 1;
    }
  } else {
    if (ratio < 1) {
      //填满宽度
      _videoHeight = _previewWidth / ratio;
      _videoWidth = _previewWidth;
    } else if (ratio > 1) {
      //填满高度
      _videoHeight = _previewWidth;
      _videoWidth = _previewWidth * ratio;
    } else {
      //剩余的就是ratio == 1的情况
      _videoHeight = _previewWidth;
      _videoWidth = _previewWidth;
    }
    _videoCroppedRatio = 1;
  }

  _VideoPreviewSize _previewSize = _VideoPreviewSize(_videoWidth, _videoHeight);
  _previewSize.videoCroppedRatio = _videoCroppedRatio;
  return _previewSize;
}
