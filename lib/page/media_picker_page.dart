import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// media_picker_page
/// Created by yangjiayi on 2020/11/9.

int _horizontalCount = 4;
int _itemMargin = 0;
double _itemSize = 0;
int _galleryIndex = 0;
int _photoIndex = 1;
int _videoIndex = 2;

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
    _pageList.add(_GalleryGrid());
    _pageList.add(Container(color: Colors.grey,));
    _pageList.add(Container(color: Colors.greenAccent,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: _pageController,
        children: _pageList,
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

class _GalleryGrid extends StatefulWidget {
  @override
  _GalleryGridState createState() => _GalleryGridState();
}

class _GalleryGridState extends State<_GalleryGrid> with AutomaticKeepAliveClientMixin{
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
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
      print(albums);
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 100);
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
    double screenWidth = MediaQuery.of(context).size.width;
    print("屏幕宽为：${screenWidth}");
    _itemSize = (screenWidth - _itemMargin * (_horizontalCount - 1)) / _horizontalCount;
    print("item宽为：${_itemSize}");
    return GridView.builder(
        itemCount: _galleryList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _horizontalCount),
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: _galleryList[index].thumbDataWithSize(_itemSize.toInt(), _itemSize.toInt()),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return Image.memory(
                  snapshot.data,
                );
              return Container();
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
