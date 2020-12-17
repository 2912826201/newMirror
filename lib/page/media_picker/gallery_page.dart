import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/image_cropper.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

/// gallery_page
/// Created by yangjiayi on 2020/11/12.

final int _horizontalCount = 4;
final double _itemMargin = 0;
final int _galleryPageSize = 100;

//1.9:1 和 4:5
final double maxVideoRatio = 1.9;
final double minVideoRatio = 0.8;

// 相册的选择GridView视图 需要能够区分选择图片或视频 选择图片数量 是否裁剪 裁剪是否只是正方形
//TODO 目前没有做响应实时相册变化时的处理 完善时可以考虑实现
class GalleryPage extends StatefulWidget {
  GalleryPage(
      {Key key,
      this.maxImageAmount = 1,
      this.requestType = RequestType.common,
      this.needCrop = false,
      this.cropOnlySquare = false,
      this.isGoToPublish = false})
      : super(key: key);

  final int maxImageAmount;
  final int maxVideoAmount = 1;
  final bool needCrop;
  final bool cropOnlySquare;
  final bool isGoToPublish;

  // image是图片 common是图片和视频 目前需求只会用到这两种
  final RequestType requestType;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

// AutomaticKeepAliveClientMixin支持重新切回页面后保持之前页面状态
class _GalleryPageState extends State<GalleryPage> with AutomaticKeepAliveClientMixin {
  var _cropperKey = GlobalKey<_GalleryPageState>();

  double _screenWidth = 0;
  double _itemSize = 0;
  double _previewMaxHeight = 0;
  double _previewMinHeight = 0;

  // 是否正在获取数据 防止同时重复请求
  bool _isFetchingData = false;

  // 当前路径的图片视频数
  int _mediaAmount = 0;

  // 资源实体的列表
  List<AssetEntity> _galleryList = [];

  // 实际资源文件的Map 因AssetEntity获取File是异步的 所以单独把获取后的结果存一下 避免重复耗时获取和减少处理异步回调的工序
  Map<String, File> _fileMap = {};

  // 资源缩略图的Map 因AssetEntity获取缩略图是异步的 所以单独把获取后的结果存一下 避免重复耗时获取和减少处理异步回调的工序
  Map<String, Uint8List> _thumbMap = {};

  @override
  void initState() {
    super.initState();
    //初始化时立刻获取一次数据
    _fetchGalleryData(true);
  }

  //TODO 获取相册数据 需要排除掉不符合规则的文件
  _fetchGalleryData(bool isNew) async {
    if (_isFetchingData) {
      // 正在获取过程中则不做操作
      return;
    }
    _isFetchingData = true;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      // load the album list
      //TODO 这里需要设置路径
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(hasAll: true, onlyAll: true, type: widget.requestType);
      print(albums);
      //TODO 默认取第一个
      _mediaAmount = albums.first.assetCount;
      context.read<SelectedMapNotifier>().setFolderName(albums.first.name);
      //TODO 需要完善翻页机制
      List<AssetEntity> media =
          await albums[0].getAssetListRange(start: _galleryList.length, end: _galleryList.length + _galleryPageSize);
      print(media);

      setState(() {
        _galleryList.addAll(media);
      });

      _isFetchingData = false;
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      _isFetchingData = false;
    }

    // 在裁剪模式中 刷新列表后重置选中项
    if (widget.needCrop && isNew) {
      if (_galleryList.isEmpty) {
        // 列表为空 则清空
        context.read<SelectedMapNotifier>().setCurrentEntity(null);
      } else {
        // 列表不为空 选中第一条
        _onGridItemTap(context, _galleryList.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 获取屏幕宽以设置各布局大小
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    print("屏幕宽为：$_screenWidth");
    _itemSize = (_screenWidth - _itemMargin * (_horizontalCount - 1)) / _horizontalCount;
    print("item宽为：$_itemSize");
    _previewMaxHeight = _screenWidth;
    _previewMinHeight = _screenWidth / 2;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.bgBlack,
          title: _buildAppBar(),
        ),
        body: ChangeNotifierProvider(
            create: (_) =>
                _PreviewHeightNotifier(_previewMaxHeight, maxHeight: _previewMaxHeight, minHeight: _previewMinHeight),
            builder: (context, _) {
              return Stack(
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
                          top: context.watch<_PreviewHeightNotifier>().previewHeight - _previewMaxHeight,
                          child: Container(
                            color: AppColor.bgBlack,
                            width: _previewMaxHeight,
                            height: _previewMaxHeight,
                            child: Builder(
                              builder: (context) {
                                AssetEntity entity =
                                    context.select((SelectedMapNotifier notifier) => notifier.currentEntity);
                                return entity == null
                                    ? Container()
                                    : entity.type == AssetType.video
                                        ? VideoPreviewArea(_fileMap[entity.id], _screenWidth)
                                        : entity.type == AssetType.image
                                            ? CropperImage(
                                                FileImage(_fileMap[entity.id]),
                                                round: 0,
                                                key: _cropperKey,
                                              )
                                            : Container();
                              },
                            ),
                          ))
                      : Container(),
                ],
              );
            }));
  }

  @override
  bool get wantKeepAlive => true;

  // item本体点击事件
  _onGridItemTap(BuildContext context, AssetEntity entity) async {
    final notifier = context.read<SelectedMapNotifier>();
    if (notifier.currentEntity != null && entity.id == notifier.currentEntity.id) {
      //如果之前选中的和点到的一样 则不做操作
      return;
    }

    // 在裁剪模式中如果之前预览的已被选中 那么获取其图像 保存下来 然后再去预览新点中的图像
    // 当最后一张图是预览并选中时 需要在点击下一步按钮时获取这张图
    if (widget.needCrop) {
      if (notifier.currentEntity != null && notifier.selectedMap.containsKey(notifier.currentEntity.id)) {
        _getImage(context, notifier.currentEntity.id);
      }
    }

    //FIXME 这里iOS如果文件在iCloud 会取不到。。。
    if (_fileMap[entity.id] == null) {
      entity.file.then((value) {
        _fileMap[entity.id] = value;
        print(entity.id + ":" + value.path);
        if (widget.needCrop) {
          // 裁剪模式需要将其置入裁剪框2
          notifier.setCurrentEntity(entity);
        } else {
          //TODO 非裁剪模式跳转展示大图
        }
      });
    } else {
      print(entity.id + ":" + _fileMap[entity.id].path);
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
    entity.file.then((value) => print(entity.id + ":" + value.path));
    bool isNew = context.read<SelectedMapNotifier>().handleMapChange(entity);
    if (isNew) {
      _onGridItemTap(context, entity);
    }
  }

  Widget _buildGridItem(BuildContext context, int index) {
    // print("#${index} item loaded");
    // 当加载到距离list的长度还有一行时 请求下一页数据
    if (_galleryList.length < _mediaAmount && _galleryList.length - index <= _horizontalCount * 2) {
      _fetchGalleryData(false);
    }
    AssetEntity entity = _galleryList[index];
    // 一定要返回某种形式的Builder 不然context.select会报错
    if (_thumbMap[entity.id] == null) {
      return FutureBuilder(
        future: entity.thumbDataWithSize(_itemSize.toInt(), _itemSize.toInt()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _thumbMap[entity.id] = snapshot.data;
            return _buildGridItemCell(context, entity);
          } else {
            return Container();
          }
        },
      );
    } else {
      return Builder(builder: (context) => _buildGridItemCell(context, entity));
    }
  }

  Widget _buildGridItemCell(BuildContext context, AssetEntity entity) {
    return GestureDetector(
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
          Image.memory(
            _thumbMap[entity.id],
            fit: BoxFit.cover,
            height: _itemSize,
            width: _itemSize,
          ),
          Container(
              height: _itemSize,
              width: _itemSize,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: context.select((SelectedMapNotifier notifier) =>
                          notifier.currentEntity == null || notifier.currentEntity.id != entity.id
                              ? AppColor.transparent
                              : AppColor.mainRed),
                      width: 2,
                      style: BorderStyle.solid))),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
                onTap: () => _onCheckBoxTap(context, entity),
                child: Container(
                  height: 20,
                  width: 20,
                  alignment: Alignment.center,
                  child: context.watch<SelectedMapNotifier>().selectedMap.containsKey(entity.id)
                      ? Text(
                          context.watch<SelectedMapNotifier>().selectedMap[entity.id].order.toString(),
                          style: TextStyle(color: AppColor.white, fontSize: 18),
                        )
                      : Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColor.white,
                        ),
                )),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              entity.type == AssetType.image
                  ? "I"
                  : entity.type == AssetType.video
                      ? "V"
                      : "",
              style: TextStyle(color: AppColor.white, fontSize: 18),
            ),
          )
        ]));
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
                context.read<_PreviewHeightNotifier>().setOffset(metrics.pixels);
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
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(context.select((SelectedMapNotifier value) => value.folderName)),
          ),
          GestureDetector(
            onTap: () async {
              // 先处理选中的结果
              final notifier = context.read<SelectedMapNotifier>();

              String type;
              switch (notifier.selectedType) {
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

              // 在裁剪模式下 当前预览的图像如果是选中的图 则需要获取下裁剪后的图像
              if (widget.needCrop && notifier.selectedType == AssetType.image) {
                if (notifier.currentEntity != null && notifier.selectedMap.containsKey(notifier.currentEntity.id)) {
                  await _getImage(context, notifier.currentEntity.id);
                }
              }

              // 最后结果的列表
              List<MediaFileModel> mediaFileList = [];

              Map<String, _OrderedAssetEntity> selectedMap = notifier.selectedMap;
              if (selectedMap.isEmpty) {
                // 如果已选中的列表是空的 则程序有错误
                return;
              }
              // 先根据长度将model放入list
              for (int i = 0; i < selectedMap.length; i++) {
                mediaFileList.add(MediaFileModel());
              }
              // 遍历所选Map将结果赋值
              for (_OrderedAssetEntity orderedEntity in selectedMap.values) {
                // order要减1才是index
                MediaFileModel mediaFileModel = mediaFileList[orderedEntity.order - 1];
                // 根据类型处理文件信息及尺寸信息
                if (widget.needCrop) {
                  switch (notifier.selectedType) {
                    case AssetType.image:
                      mediaFileModel.croppedImage = notifier.imageMap[orderedEntity.entity.id];
                      mediaFileModel.sizeInfo.height = mediaFileModel.croppedImage.height;
                      mediaFileModel.sizeInfo.width = mediaFileModel.croppedImage.width;
                      break;
                    case AssetType.video:
                      mediaFileModel.file = _fileMap[orderedEntity.entity.id];
                      mediaFileModel.thumb = _thumbMap[orderedEntity.entity.id];
                      mediaFileModel.sizeInfo.height = orderedEntity.entity.height;
                      mediaFileModel.sizeInfo.width = orderedEntity.entity.width;
                      mediaFileModel.sizeInfo.duration = orderedEntity.entity.duration;
                      SizeInfo sizeInfo = notifier.offsetMap[mediaFileModel.file.path];
                      if (sizeInfo != null) {
                        mediaFileModel.sizeInfo.offsetRatioX = sizeInfo.offsetRatioX;
                        mediaFileModel.sizeInfo.offsetRatioY = sizeInfo.offsetRatioY;
                      }
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
                }
              }
              // 赋值并退出页面
              SelectedMediaFiles files = SelectedMediaFiles();
              files.type = type;
              files.list = mediaFileList;

              Application.selectedMediaFiles = files;

              Navigator.pop(context, true);

              if (widget.isGoToPublish) {
                AppRouter.navigateToReleasePage(context);
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 28,
              width: 60,
              decoration: BoxDecoration(
                  color: context.select((SelectedMapNotifier value) => value.selectedMap.isEmpty)
                      ? AppColor.bgWhite
                      : AppColor.mainRed,
                  borderRadius: BorderRadius.circular(14)),
              child: Text("下一步", style: TextStyle(color: AppColor.white, fontSize: 14)),
            ),
          )
        ],
      );
    });
  }

  _getImage(BuildContext context, String id) async {
    print("开始获取" + DateTime.now().millisecondsSinceEpoch.toString());

    ui.Image image = await (_cropperKey.currentContext as CropperImageElement).outImage();

    print("已获取到ui.Image" + DateTime.now().millisecondsSinceEpoch.toString());
    print(image);
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
    // Uint8List picBytes = byteData.buffer.asUint8List();
    // print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
    context.read<SelectedMapNotifier>().addImage(id, image);
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

  String _folderName = "";

  String get folderName => _folderName;

  AssetEntity _currentEntity;

  AssetEntity get currentEntity => _currentEntity;

  // 所选类型只能有一种
  AssetType _selectedType;

  AssetType get selectedType => _selectedType;

  Map<String, _OrderedAssetEntity> _selectedMap = {};

  Map<String, _OrderedAssetEntity> get selectedMap => _selectedMap;

  // 记录视频的偏移值
  Map<String, SizeInfo> _offsetMap = {};

  Map<String, SizeInfo> get offsetMap => _offsetMap;

  // 用来存放已经裁剪好的图像数据
  Map<String, ui.Image> _imageMap = {};

  Map<String, ui.Image> get imageMap => _imageMap;

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
    }
  }

  _addToSelectedMap(AssetEntity entity) {
    if (_selectedMap.isEmpty) {
      // 如果是第一条数据 则设置已选类型
      _selectedType = entity.type;
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

  setFolderName(String name) {
    _folderName = name;
    notifyListeners();
  }

  setCurrentEntity(AssetEntity entity) {
    // 判断是否真的变化 如果一方为null时 统一视为变化
    if (_currentEntity == null || entity == null || _currentEntity.id != entity.id) {
      _currentEntity = entity;
      notifyListeners();
    }
  }

  addImage(String id, ui.Image image) {
    _imageMap[id] = image;
  }

  removeImage(String id) {
    _imageMap.remove(id);
  }

  setOffset(String key, double offsetRatioX, double offsetRatioY) {
    SizeInfo sizeInfo = SizeInfo();
    sizeInfo.offsetRatioX = offsetRatioX;
    sizeInfo.offsetRatioY = offsetRatioY;
    _offsetMap[key] = sizeInfo;
  }
}

// 用于监听及更新裁剪预览布局的高度
class _PreviewHeightNotifier with ChangeNotifier {
  _PreviewHeightNotifier(this._previewHeight, {@required this.maxHeight, @required this.minHeight});

  double maxHeight;
  double minHeight;

  double _previewHeight;

  double get previewHeight => _previewHeight;

  double _offset = 0;

  setOffset(double offset) {
    // 根据滚动距离计算预览框高度
    // 向上滑动的距离 正即为向上滑 负则为向下滑 0则为没有动
    double distance = offset - _offset;
    // 算完后赋值
    _offset = offset;
    // 理论上新的高度为旧的高度减去向上滑动的距离
    double previewHeight = _previewHeight - distance;
    // 结果如果超出范围 纠正为范围阈值
    if (previewHeight > maxHeight) {
      previewHeight = maxHeight;
    } else if (previewHeight < minHeight) {
      previewHeight = minHeight;
    }
    // 算完后赋值
    _previewHeight = previewHeight;

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
  VideoPreviewArea(this.file, this.previewWidth, {Key key}) : super(key: key);

  final File file;
  final double previewWidth;

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
              // _controller.play();
            }
            Size _previewSize = _getVideoPreviewSize(_controller.value.aspectRatio, widget.previewWidth);
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

// 获取视频预览区域宽高
Size _getVideoPreviewSize(double ratio, double _previewWidth) {
  double _videoWidth;
  double _videoHeight;

  if (ratio < minVideoRatio) {
    //细高的情况 先限定最宽的宽度 再根据ratio算出高度
    _videoWidth = _previewWidth * minVideoRatio;
    _videoHeight = _previewWidth * minVideoRatio / ratio;
  } else if (ratio < 1) {
    //填满高度
    _videoHeight = _previewWidth;
    _videoWidth = _previewWidth * ratio;
  } else if (ratio > maxVideoRatio) {
    //扁长的情况 先限定最高的高度 再根据ratio算出宽度
    _videoHeight = _previewWidth / maxVideoRatio;
    _videoWidth = _previewWidth * ratio / maxVideoRatio;
  } else if (ratio > 1) {
    //填满宽度
    _videoHeight = _previewWidth / ratio;
    _videoWidth = _previewWidth;
  } else {
    //剩余的就是ratio == 1的情况
    _videoHeight = _previewWidth;
    _videoWidth = _previewWidth;
  }
  return Size(_videoWidth, _videoHeight);
}
