import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/image_cropper.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// gallery_page
/// Created by yangjiayi on 2020/11/12.

final int _horizontalCount = 4;
final double _itemMargin = 0;
final int _galleryPageSize = 100;

// 相册的选择GridView视图 需要能够区分选择图片或视频 选择图片数量 是否裁剪 裁剪是否只是正方形
//TODO 目前没有做响应实时相册变化时的处理 完善时可以考虑实现
class GalleryPage extends StatefulWidget {
  GalleryPage(
      {Key key,
      this.maxImageAmount = 1,
      this.requestType = RequestType.common,
      this.needCrop = false,
      this.cropOnlySquare = false})
      : super(key: key);

  final int maxImageAmount;
  final int maxVideoAmount = 1;
  final bool needCrop;
  final bool cropOnlySquare;

  // image是图片 common是图片和视频 目前需求只会用到这两种
  final RequestType requestType;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with AutomaticKeepAliveClientMixin {
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

  //获取相册数据
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
          await PhotoManager.getAssetPathList(hasAll: true, onlyAll: false, type: widget.requestType);
      print(albums);
      _mediaAmount = albums[0].assetCount;
      context.read<SelectedMapNotifier>().setFolderName(albums[0].name);
      //TODO 需要完善翻页机制
      List<AssetEntity> media =
          await albums[0].getAssetListRange(start: _galleryList.length, end: _galleryList.length + _galleryPageSize);
      print(media);
      //FIXME 会闪一下
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
              children: [
                ScrollConfiguration(
                  behavior: NoBlueEffectBehavior(),
                  child: _buildScrollBody(),
                ),
                Positioned(
                    top: context.watch<_PreviewHeightNotifier>().previewHeight - _previewMaxHeight,
                    child: Container(
                      width: _previewMaxHeight,
                      height: _previewMaxHeight,
                      child: Builder(
                        builder: (context) {
                          AssetEntity entity = context.select((SelectedMapNotifier notifier) => notifier.currentEntity);
                          return entity == null
                              ? Container()
                              : CropperImage(
                                  FileImage(_fileMap[entity.id]),
                                  round: 0,
                                );
                        },
                      ),
                    ))
              ],
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // item本体点击事件
  _onGridItemTap(BuildContext context, AssetEntity entity) {
    if (_fileMap[entity.id] == null) {
      entity.file.then((value) {
        _fileMap[entity.id] = value;
        print(entity.id + ":" + value.path);
        if (widget.needCrop) {
          // 裁剪模式需要将其置入裁剪框
          context.read<SelectedMapNotifier>().setCurrentEntity(entity);
        } else {
          //TODO 非裁剪模式跳转展示大图
        }
      });
    } else {
      print(entity.id + ":" + _fileMap[entity.id].path);
      if (widget.needCrop) {
        // 裁剪模式需要将其置入裁剪框
        context.read<SelectedMapNotifier>().setCurrentEntity(entity);
      } else {
        //TODO 非裁剪模式跳转展示大图
      }
    }
  }

  // item选框点击事件
  //TODO 当点中选框的文件并不是当前预览的文件时 还要将其选中设置预览
  _onCheckBoxTap(BuildContext context, AssetEntity entity) {
    entity.file.then((value) => print(entity.id + ":" + value.path));
    context.read<SelectedMapNotifier>().handleMapChange(entity);
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
          Image.memory(
            _thumbMap[entity.id],
            fit: BoxFit.cover,
            height: _itemSize,
            width: _itemSize,
          ),
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )
                      : Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: Colors.white,
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
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
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
                      style: BorderStyle.solid)))
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
}

// 用来记录排序
class _OrderedAssetEntity {
  _OrderedAssetEntity(this.order, this.entity);

  int order;
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

  Map<String, _OrderedAssetEntity> _selectedMap = Map<String, _OrderedAssetEntity>();

  Map<String, _OrderedAssetEntity> get selectedMap => _selectedMap;

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

  handleMapChange(AssetEntity entity) {
    if (_selectedType != null && entity.type != _selectedType) {
      // 已选类型不为空 且与所选文件类型不符时不做操作
      return;
    }
    if (_selectedMap.keys.contains(entity.id)) {
      //已在所选列表中
      _removeFromSelectedMap(entity);
      notifyListeners();
    } else if (!isFull()) {
      //未在所选列表中 且已选数量未达到上限
      _addToSelectedMap(entity);
      notifyListeners();
    }
  }

  setFolderName(String name) {
    _folderName = name;
    notifyListeners();
  }

  setCurrentEntity(AssetEntity entity) {
    _currentEntity = entity;
    notifyListeners();
  }
}

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
          onTap: () {
            Map<String, _OrderedAssetEntity> result = context.read<SelectedMapNotifier>().selectedMap;
            if (!result.isEmpty) {
              Navigator.pop(context, result);
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
            child: Text("完成", style: TextStyle(color: AppColor.white, fontSize: 14)),
          ),
        )
      ],
    );
  });
}

// 约束Grid尺寸样式的delegate
SliverGridDelegateWithFixedCrossAxisCount _galleryGridDelegate() {
  return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _horizontalCount,
      childAspectRatio: 1,
      mainAxisSpacing: _itemMargin,
      crossAxisSpacing: _itemMargin);
}

// 裁剪预览区域的delegate
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
