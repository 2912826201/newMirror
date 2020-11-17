import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'gallery_page.dart';

/// media_picker_page
/// Created by yangjiayi on 2020/11/9.

int _galleryIndex = 0; // 相册
int _photoIndex = 1; // 拍照
int _videoIndex = 2; // 拍视频

//限定一下文件类型的入参范围
int typeImage = 0;
int typeImageAndVideo = 1;

class MediaPickerPage extends StatefulWidget {
  MediaPickerPage(this.maxImageAmount, this.mediaType, this.needCrop, {Key key, this.cropOnlySquare = false})
      : super(key: key);

  final int maxImageAmount;
  final int mediaType;
  final bool needCrop;
  final bool cropOnlySquare;

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
    _pageList.add(
        //需要在这里就把provider创建出来，以便页面内的所有context都能在provider下
        ChangeNotifierProvider(
            create: (_) => SelectedMapNotifier(widget.maxImageAmount, 1),
            child: GalleryPage(
              maxImageAmount: widget.maxImageAmount,
              requestType: widget.mediaType == typeImageAndVideo ? RequestType.common : RequestType.image,
              needCrop: widget.needCrop,
              cropOnlySquare: widget.cropOnlySquare,
            )));
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
