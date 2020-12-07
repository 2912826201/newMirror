import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/media_picker/camera_photo_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'gallery_page.dart';

/// media_picker_page
/// Created by yangjiayi on 2020/11/9.

//TODO 进这个页面前就要请求一下权限 不然很可能会因权限问题导致页面有问题

// 各tab页的index
int _galleryIndex = 0; // 相册
int _photoIndex = 1; // 拍照
int _videoIndex = 2; // 拍视频

//限定一下文件类型和初始页面的入参范围
int typeImage = 0;
int typeImageAndVideo = 1;

int startPageGallery = _galleryIndex;
int startPagePhoto = _photoIndex;

class MediaPickerPage extends StatefulWidget {
  MediaPickerPage(this.maxImageAmount, this.mediaType, this.needCrop, this.startPage,
      {Key key, this.cropOnlySquare = false})
      : super(key: key);

  final int maxImageAmount;
  final int mediaType;
  final bool needCrop;
  final bool cropOnlySquare;
  final int startPage;

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPickerPage> {
  int _selectedIndex;
  PageController _pageController;
  List<Widget> _pageList = [];

  @override
  void initState() {
    super.initState();
    //根据入参中的起始页来确定一开始进哪个页面
    _selectedIndex = widget.startPage;
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
    _pageList.add(CameraPhotoPage());
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
        color: AppColor.bgBlack,
        child: SizedBox(
          height: 48,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              _buildButton(_galleryIndex, "相册", _onGallerySelected),
              _buildButton(_photoIndex, "拍照", _onPhotoSelected),
              _buildButton(_videoIndex, "拍视频", _onVideoSelected),
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

  Widget _buildButton(int index, String text, Function onTap) {
    return Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text,
                    style: _selectedIndex == index
                        ? TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: AppColor.white)
                        : TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16, color: AppColor.white.withOpacity(0.35))),
                _selectedIndex == index
                    ? Container(
                        width: 16,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColor.mainRed,
                          borderRadius: BorderRadius.circular(1.5),
                        ))
                    : Container(),
              ],
            ),
          ),
        ));
  }
}
