import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'camera_record_page.dart';
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
  MediaPickerPage(this.maxImageAmount, this.mediaType, this.needCrop, this.startPage, this.cropOnlySquare,
      {Key key, this.publishMode, this.fixedWidth, this.fixedHeight, this.startCount = 0, this.topicId})
      : super(key: key);

  final int maxImageAmount;
  final int mediaType;
  final bool needCrop;
  final int startPage;
  final bool cropOnlySquare;
  final int publishMode;
  final int fixedWidth;
  final int fixedHeight;
  final int startCount;
  final int topicId;

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPickerPage> {
  int _selectedIndex;
  PageController _pageController;
  List<Widget> _pageList = [];

  int _recordMode;
  int _lastTimeStamp = 0;
  int _tabSwitchInterval = 750;

  @override
  void initState() {
    super.initState();
    //根据入参中的起始页来确定一开始进哪个页面
    _selectedIndex = widget.startPage;
    if (widget.startPage == _videoIndex) {
      _recordMode = 1;
      _pageController = PageController(initialPage: _photoIndex);
    } else if (widget.startPage == _photoIndex) {
      _recordMode = 0;
      _pageController = PageController(initialPage: _photoIndex);
    } else {
      _recordMode = 0;
      _pageController = PageController(initialPage: _galleryIndex);
    }
    _pageList.add(
      //需要在这里就把provider创建出来，以便页面内的所有context都能在provider下
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SelectedMapNotifier(widget.maxImageAmount, 1)),
          ChangeNotifierProvider(create: (_) => PreviewHeightNotifier(ScreenUtil.instance.screenWidthDp)),
        ],
        child: GalleryPage(
          maxImageAmount: widget.maxImageAmount,
          requestType: widget.mediaType == typeImageAndVideo ? RequestType.common : RequestType.image,
          needCrop: widget.needCrop,
          cropOnlySquare: widget.cropOnlySquare,
          publishMode: widget.publishMode,
          fixedHeight: widget.fixedHeight,
          fixedWidth: widget.fixedWidth,
          startCount: widget.startCount,
          topicId: widget.topicId,
        ),
      ),
    );
    _pageList.add(
      CameraRecordPage(
        publishMode: widget.publishMode,
        fixedHeight: widget.fixedHeight,
        fixedWidth: widget.fixedWidth,
        topicId: widget.topicId,
        startMode: _recordMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("MediaPickerPage_____________________________________________build");
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pageList,
        onPageChanged: null,
        //禁止左右划切换页面
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.mainBlack,
        child: SizedBox(
          height: 48,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              _buildButton(_galleryIndex, "相册", _onGallerySelected),
              _buildButton(_photoIndex, "拍照", _onPhotoSelected),
              widget.mediaType == typeImageAndVideo ? _buildButton(_videoIndex, "拍视频", _onVideoSelected) : Container()
            ],
          ),
        ),
      ),
    );
  }

  //新版三个tab的切换逻辑为
  //只有两个页面，相册页和录制页，录制页分为拍照和拍视频两种模式，在页面初始化时就要确定模式
  //当相册页和录制页互相切换时，PageView切换页面，并且在切换至录制页前将录制页移除重新添加指定初始模式的录制页
  //录制页的拍照和拍视频两个页面互相切换只需要调用录制页的切换模式方法即可，但要等切换成功后再改变tab
  //TODO 这里仍有优化空间 比如上次切换到的录制页和这次模式一样，则可以不移除重新添加，当只有相册和拍照两个tab时也不需要移除重新添加
  void _onGallerySelected() {
    if (_selectedIndex != _galleryIndex) {
      int timeStamp = DateTime.now().millisecondsSinceEpoch;
      if (timeStamp - _lastTimeStamp < _tabSwitchInterval) {
        return;
      }
      setState(() {
        _lastTimeStamp = timeStamp;
        _selectedIndex = _galleryIndex;
        _pageController.animateToPage(_selectedIndex, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
      });
    }
  }

  void _onPhotoSelected() {
    if (_selectedIndex != _photoIndex) {
      if (_selectedIndex == _galleryIndex) {
        int timeStamp = DateTime.now().millisecondsSinceEpoch;
        if (timeStamp - _lastTimeStamp < _tabSwitchInterval) {
          return;
        }

        EventBus.getDefault().post(registerName: GALLERY_LEAVE);

        setState(() {
          _lastTimeStamp = timeStamp;
          _recordMode = 0;
          _selectedIndex = _photoIndex;
          _pageList.removeLast();
          _pageList.add(CameraRecordPage(
            publishMode: widget.publishMode,
            fixedHeight: widget.fixedHeight,
            fixedWidth: widget.fixedWidth,
            topicId: widget.topicId,
            startMode: _recordMode,
          ));
          _pageController.animateToPage(_selectedIndex, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
        });
      } else {
        CameraRecordPage recordPage = _pageList.last as CameraRecordPage;
        bool result = recordPage.switchMode(0);
        if (result) {
          setState(() {
            _recordMode = 0;
            _selectedIndex = _photoIndex;
          });
        }
      }
    }
  }

  void _onVideoSelected() {
    if (_selectedIndex != _videoIndex) {
      if (_selectedIndex == _galleryIndex) {
        int timeStamp = DateTime.now().millisecondsSinceEpoch;
        if (timeStamp - _lastTimeStamp < _tabSwitchInterval) {
          return;
        }

        EventBus.getDefault().post(registerName: GALLERY_LEAVE);

        setState(() {
          _lastTimeStamp = timeStamp;
          _recordMode = 1;
          _selectedIndex = _videoIndex;
          _pageList.removeLast();
          _pageList.add(CameraRecordPage(
            publishMode: widget.publishMode,
            fixedHeight: widget.fixedHeight,
            fixedWidth: widget.fixedWidth,
            topicId: widget.topicId,
            startMode: _recordMode,
          ));
          _pageController.animateToPage(_photoIndex, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
        });
      } else {
        CameraRecordPage recordPage = _pageList.last as CameraRecordPage;
        bool result = recordPage.switchMode(1);
        if (result) {
          setState(() {
            _recordMode = 1;
            _selectedIndex = _videoIndex;
          });
        }
      }
    }
  }

  Widget _buildButton(int index, String text, Function onTap) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,
                  style: _selectedIndex == index
                      ? TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: AppColor.white)
                      : TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: AppColor.white.withOpacity(0.35))),
              _selectedIndex == index
                  ? Container(
                      width: 16,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColor.mainYellow,
                        borderRadius: BorderRadius.circular(1.5),
                      ))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
