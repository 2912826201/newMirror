import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// gallery_grid
/// Created by yangjiayi on 2020/11/12.


int _horizontalCount = 4;
double _itemMargin = 2;
double _itemSize = 0;
int _galleryPageSize = 100;

// 相册的GridView视图 需要能够区分选择图片或视频 选择图片数量
class GalleryGrid extends StatefulWidget {
  GalleryGrid({Key key, this.maxImageAmount = 1, this.requestType = RequestType.common}) : super(key: key);

  final int maxImageAmount;
  final int maxVideoAmount = 1;

  // image是图片 common是图片和视频 目前需求只会用到这两种
  final RequestType requestType;

  @override
  _GalleryGridState createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> with AutomaticKeepAliveClientMixin {
  // 是否正在获取数据 防止同时重复请求
  bool _isFetchingData = false;

  // 当前路径的图片视频数
  int _mediaAmount = 0;
  List<AssetEntity> _galleryList = [];

  @override
  void initState() {
    super.initState();
    _fetchGalleryData(true);
  }

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
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: widget.requestType);
      print(albums);
      _mediaAmount = albums[0].assetCount;
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //TODO 获取屏幕宽高以设置图片大小 获取方法需要统一封装
    double screenWidth = MediaQuery.of(context).size.width;
    print("屏幕宽为：$screenWidth");
    _itemSize = (screenWidth - _itemMargin * (_horizontalCount - 1)) / _horizontalCount;
    print("item宽为：$_itemSize");
    return ChangeNotifierProvider(
      create: (_) => _SelectedMapNotifier(widget.maxImageAmount, widget.maxVideoAmount),
      child: GridView.builder(
          itemCount: _galleryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _horizontalCount,
              childAspectRatio: 1,
              mainAxisSpacing: _itemMargin,
              crossAxisSpacing: _itemMargin),
          itemBuilder: (BuildContext context, int index) {
            AssetEntity entity = _galleryList[index];
            return FutureBuilder(
              future: entity.thumbDataWithSize(_itemSize.toInt(), _itemSize.toInt()),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // print("#${index} item loaded");
                  // 当加载到距离list的长度还有一行时 请求下一页数据
                  if (_galleryList.length < _mediaAmount && _galleryList.length - index <= _horizontalCount * 2) {
                    _fetchGalleryData(false);
                  }
                  return GestureDetector(
                      onTap: () => _onGridItemTap(context, index),
                      child: Stack(overflow: Overflow.clip, children: [
                        Image.memory(
                          snapshot.data,
                          fit: BoxFit.cover,
                          height: _itemSize,
                          width: _itemSize,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: context.watch<_SelectedMapNotifier>().selectedMap.containsKey(entity.id)
                              ? Text(
                            context.watch<_SelectedMapNotifier>().selectedMap[entity.id].order.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )
                              : Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: Colors.white,
                          ),
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
                        )
                      ]));
                } else {
                  return Container();
                }
              },
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  //TODO 点击事件 需要区分是本体还是选框
  _onGridItemTap(BuildContext context, int index) {
    print("点了第$index张图");
    AssetEntity entity = _galleryList[index];
    entity.file.then((value) => print(entity.id + ":" + value.uri.toString()));
    context.read<_SelectedMapNotifier>().handleMapChange(entity);
  }
}

class _OrderedAssetEntity {
  _OrderedAssetEntity(this.order, this.entity);

  int order;
  AssetEntity entity;
}

class _SelectedMapNotifier with ChangeNotifier {
  _SelectedMapNotifier(this.maxImageAmount, this.maxVideoAmount);

  int maxImageAmount;
  int maxVideoAmount;

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
}