import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/profile/imagedetails.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ProFileDetailesCarousel extends StatefulWidget {
  double height;

  ProFileDetailesCarousel({this.height});

  @override
  State<StatefulWidget> createState() {
    return _DetailesCarouselState();
  }
}
class _DetailesCarouselState extends State<ProFileDetailesCarousel> {
  AutoScrollController _AutoScrollController;
  int _position = 0;
  List<String> _ImageList = [
    "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1491622188,2856001475&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3345450554,3432169032&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3412286164,295662108&fm=26&gp=0.jpg",
    "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2176413831,288079380&fm=26&gp=0.jpg",
    "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3685176780,1974427386&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=4076357916,2563835014&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2194651031,1721494085&fm=26&gp=0.jpg",
    "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=5574358,167660515&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2650148262,1983191614&fm=26&gp=0.jpg",
    "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=988082858,737428313&fm=26&gp=0.jpg",
    "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1156052660,1542011209&fm=26&gp=0.jpg",
    "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1093994136,1797019275&fm=26&gp=0.jpg",
  ];
  @override
  void initState() {
    super.initState();
    _AutoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal);
  }
  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.instance.screenWidthDp;
    return Column(
      children: [
        Container(
          color: AppColor.black,
          child: Stack(
          children: [
            Container(
              width: width,
              height: 500,
              child: Swiper(
                itemCount: _ImageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _ImageItem(index,width);
                },
                loop: false,
                onIndexChanged: (index) {
                  setState(() {
                    _position = index;
                  });
                    slidingPosition(index);
                },
              ),
            ),
            Positioned(
              top: 13,
              right: 16,
              child: Offstage(
                offstage: _ImageList.length == 1,
                child: Container(
                  padding:
                      EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: AppColor.textPrimary1_50),
                  child: Text(
                    "${_position + 1}/${_ImageList.length}",
                    style: TextStyle(color: AppColor.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),),
        Offstage(
          offstage: _ImageList.length == 1,
          child: Container(
            width: getWidth(),
            height: 10,
            margin: EdgeInsets.only(top: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _AutoScrollController,
              itemCount: _ImageList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _AutoScrollController,
                  index: index,
                  child: Container(
                    width: elementSize(index),
                    height: elementSize(index),
                    margin: EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: index == _position ? Colors.black : Colors.grey, shape: BoxShape.circle)));
              }),
          ),
        )
      ],
    );
  }
Widget _ImageItem(int index,double width){
    return GestureDetector(
      child:Image.network(
        _ImageList[index],
        fit: BoxFit.cover,
      ),
      onTap: (){
          openPageFunction(_ImageList[index],500,width ,index);
    },
    );
}

  ///照片详情页过度动画
  void openPageFunction(String url,double height,double width,int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
          ///目标页面
          return ImageDetails(index:index,ImageList: _ImageList,);
        },
        ///打开新的页面用时
        transitionDuration: Duration(milliseconds: 500),
        ///关半页岩用时
        reverseTransitionDuration: Duration(milliseconds: 300),
        ///过渡动画构建
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
          ) {
          ///渐变过渡动画
          return FadeTransition(
            /// 透明度从 0.0-1.0
            opacity: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                ///动画曲线规则，这里使用的是先快后慢
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }



  double getWidth() {
    var num = _ImageList.length;
    if (num <= 5) {
      return 3 * 8.0 + 6 + 10;
    } else {
      if (_position == 0 || _position == 1 || _position == 2 || _position == num - 1 || _position == num - 2 || _position == num - 3) {
        return 3 * 8.0 + 6 + 10;
      }
      if (_position >= 3 && _position + 3 < num) {
        return 2 * 8.0 + 2 * 5.0 + 10 + 2;
      }
    }
    return 5 * 8.0;
  }
  double elementSize(int index) {
    if (_ImageList.length <= 5) {
      if (index == _position) {
        return 7;
      } else {
        return 5;
      }
    } else {
      if (_position == 0 || _position == 1 || _position == 2) {
        if (index == _position) {
          return 7;
        } else if (index == 4) {
          return 3;
        } else {
          return 5;
        }
      }
      if (_position >= 3 && _position + 3 < _ImageList.length) {
        if (index == _position) {
          return 7;
        } else if (_position - index == 2 || index - _position == 2) {
          return 3;
        } else {
          return 5;
        }
      }
      if (_position == _ImageList.length - 1 ||
        _position == _ImageList.length - 2 ||
        _position == _ImageList.length - 3) {
        if (index == _position) {
          return 7;
        } else if (index + 2 == _position && _position == _ImageList.length - 3) {
          return 3;
        } else if (index + 3 == _position && _position == _ImageList.length - 2) {
          return 3;
        } else if (index + 4 == _position && _position == _ImageList.length - 1) {
          return 3;
        } else {
          return 5;
        }
      }
    }
  }
  slidingPosition(int index) async {
    print("索引$index");
    if (_ImageList.length > 5) {
      if (index >= 3 && index + 2 < _ImageList.length) {
        await _AutoScrollController.scrollToIndex(index - 2,
            preferPosition: AutoScrollPosition.begin);
        _AutoScrollController.highlight(index - 2);
      }
      if (index == 2) {
        await _AutoScrollController.scrollToIndex(index,
            preferPosition: AutoScrollPosition.end);
        _AutoScrollController.highlight(index);
      }
    }
  }
}
