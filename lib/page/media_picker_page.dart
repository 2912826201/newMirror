import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

/// media_picker_page
/// Created by yangjiayi on 2020/11/9.

int _horizontalCount = 4;
double _itemMargin = 2;
double _itemSize = 0;
int _galleryIndex = 0;
int _photoIndex = 1;
int _videoIndex = 2;
int _galleryPageSize = 100;

class MediaPickerPage extends StatefulWidget {
  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPickerPage> {
  int _selectedIndex = _galleryIndex;
  PageController _pageController;
  List<Widget> _pageList = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    //FIXME 测试用暂时写9 需要上个页面传参进来
    _pageList.add(_GalleryGrid(maxAmount: 9));
    _pageList.add(Container(
      color: Colors.grey,
    ));
    _pageList.add(Container(
      color: Colors.greenAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: _pageController,
        children: _pageList,
        onPageChanged: null,
        //禁止左右划切换页面
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 48,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                  flex: 1,
                  child: FlatButton(
                    height: 48,
                    padding: EdgeInsets.zero,
                    onPressed: _onGallerySelected,
                    child: Text("相册", style: TextStyle(color: _selectedIndex == 0 ? Colors.red : Colors.black)),
                  )),
              Expanded(
                  flex: 1,
                  child: FlatButton(
                    height: 48,
                    padding: EdgeInsets.zero,
                    onPressed: _onPhotoSelected,
                    child: Text("拍照", style: TextStyle(color: _selectedIndex == 1 ? Colors.red : Colors.black)),
                  )),
              Expanded(
                  flex: 1,
                  child: FlatButton(
                    height: 48,
                    padding: EdgeInsets.zero,
                    onPressed: _onVideoSelected,
                    child: Text("拍视频", style: TextStyle(color: _selectedIndex == 2 ? Colors.red : Colors.black)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _onGallerySelected() {
    if (_selectedIndex != _galleryIndex) {
      setState(() {
        _selectedIndex = _galleryIndex;
        _pageController.jumpToPage(_selectedIndex);
      });
    }
  }

  void _onPhotoSelected() {
    if (_selectedIndex != _photoIndex) {
      setState(() {
        _selectedIndex = _photoIndex;
        _pageController.jumpToPage(_selectedIndex);
      });
    }
  }

  void _onVideoSelected() {
    if (_selectedIndex != _videoIndex) {
      setState(() {
        _selectedIndex = _videoIndex;
        _pageController.jumpToPage(_selectedIndex);
      });
    }
  }
}

// 相册的GridView视图 需要能够区分选择图片或视频 选择图片数量
class _GalleryGrid extends StatefulWidget {
  _GalleryGrid({Key key, this.maxAmount}) : super(key: key);

  final int maxAmount;

  @override
  _GalleryGridState createState() => _GalleryGridState();
}

class _GalleryGridState extends State<_GalleryGrid> with AutomaticKeepAliveClientMixin {
  List<AssetEntity> _galleryList = [];

  @override
  void initState() {
    super.initState();
    _fetchGalleryData();
  }

  _fetchGalleryData() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      // load the album list
      //TODO 这里需要设置路径
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
      print(albums);
      //TODO 需要完善翻页机制
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, _galleryPageSize);
      print(media);
      setState(() {
        _galleryList = media;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO 获取屏幕宽高以设置图片大小 获取方法需要统一封装
    double screenWidth = MediaQuery.of(context).size.width;
    print("屏幕宽为：$screenWidth");
    _itemSize = (screenWidth - _itemMargin * (_horizontalCount - 1)) / _horizontalCount;
    print("item宽为：$_itemSize");
    return ChangeNotifierProvider(
      create: (_) => _SelectedMapNotifier(widget.maxAmount),
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
  _SelectedMapNotifier(this.maxAmount);

  int maxAmount;

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
  }

  _addToSelectedMap(AssetEntity entity) {
    //在添加数据时 排序为已选数量+1
    _OrderedAssetEntity orderedEntity = _OrderedAssetEntity(_selectedMap.length + 1, entity);
    _selectedMap[entity.id] = orderedEntity;
  }

  handleMapChange(AssetEntity entity) {
    if (_selectedMap.keys.contains(entity.id)) {
      //已在所选列表中
      _removeFromSelectedMap(entity);
      notifyListeners();
    } else if (_selectedMap.length < maxAmount) {
      //未在所选列表中 且已选数量未达到上限
      _addToSelectedMap(entity);
      notifyListeners();
    }
  }
}
