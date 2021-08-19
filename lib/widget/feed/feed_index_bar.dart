import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

import '../icon.dart';

// 通讯录索引bar
class IndexBar extends StatefulWidget {
  //创建索引条回调
  final void Function(String str) indexBarCallBack;
  final bool isShow;

  IndexBar({this.indexBarCallBack, this.isShow = true});

  @override
  _IndexBarState createState() => _IndexBarState();
}

int getIdex(BuildContext context, Offset globalPosition, List index_word) {
//  拿到box
  RenderBox box = context.findRenderObject();
//  拿到y值
  double y = box.globalToLocal(globalPosition).dy;
//  算出字符高度  box 的总高度 / 2 / 字符开头数组个数
  var itemHeight = ScreenUtil.instance.height / 2 / index_word.length;
  //算出第几个item，并且给一个取值范围   ~/ y除以item的高度取整  clamp 取值返回 0 -
  int index = (y ~/ itemHeight).clamp(0, index_word.length - 1);

  print('现在选中的是${index_word[index]}');
  return index;
}

class _IndexBarState extends State<IndexBar> {
  double _indicatorY = 0.0; //悬浮窗位置
  String _indicatorText = 'A'; //显示的字母
  bool _indocatorHidden = true; //是否隐藏悬浮窗

  final List<String> _index_word = [];
  List<String> indicatorTextList = [];

// 索引文字颜色
  List<Color> _index_color = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//----------------------- 1 -------------------------------
//    1、根据实际数据显示右侧bar
//    _index_word.add('#');
//    _listDatas.addAll(datas);
//    //排序!
//    _listDatas.sort((Friends a, Friends b) {
//      return a.indexLetter.compareTo(b.indexLetter);
//    });

    // 经过循环，将每一个头的首字母放入index_word数组
//    for (int i = 0; i < _listDatas.length; i++) {
//      if (i < 1 || _listDatas[i].indexLetter != _listDatas[i - 1].indexLetter) {
//        _index_word.add(_listDatas[i].indexLetter);
//      }
//    }

    //----------------------- 2 -------------------------------
//    2、右侧bar显示全部字母
    _index_word.addAll(INDEX_WORDS);
    for (var i = 0; i < _index_word.length; i++) {
      _index_color.add(AppColor.textWhite40);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> words = [];
    for (int i = 0; i < _index_word.length; i++) {
      if (i == 0) {
        words.add(Expanded(
          child: AppIcon.getAppIcon(AppIcon.input_search, 12),
        ));
      } else {
        words.add(Expanded(
            child: Text(
          _index_word[i],
          style: TextStyle(fontSize: 11, color: _index_color[i]),
        )));
      }
    }

    return Visibility(
      visible: widget.isShow,
      child: Positioned(
        right: 15.0,
        height: ScreenUtil.instance.height / 2,
        top: ScreenUtil.instance.height / 6,
        width: 120,
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment(0, _indicatorY),
              width: 100,
              child: _indocatorHidden
                  ? null
                  : Stack(
                      alignment: Alignment(-0.2, 0), //0, 0 是中心顶部是0，-1  左边中心是-1，0
                      children: <Widget>[
                        AppIcon.getAppIcon(AppIcon.pin_bubble_index_bar, 28),
                        _indicatorText == '🔍'
                            ? AppIcon.getAppIcon(AppIcon.input_search, 12,color: AppColor.white)
                            : Text(
                                _indicatorText,
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                      ],
                    ), //气泡
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 20,
                // child: ListView.builder(
                //   scrollDirection: Axis.vertical,
                //     itemCount: _index_word.length,
                //     itemBuilder: (context,)
                // ),
                child: Column(
                  children: words,
                ),
              ),
              onVerticalDragUpdate: (DragUpdateDetails details) {
                int index = getIdex(context, details.globalPosition, _index_word);
                setState(() {
                  _indicatorText = _index_word[index];

                  //   for (var i = 0; i < _index_color.length;i++) {
                  //     if (_index_word[index] == _indicatorText) {
                  //       _index_color[index] =  AppColor.bgBlack;
                  //   } else {
                  //       _index_color[index] =  AppColor.textSecondary;
                  //     }
                  // }
                  //根据我们索引条的Alignment的Y值进行运算的。从 -1.1 到 1.1
                  //整个的Y包含的值是2.2
                  _indicatorY = 2.2 / _index_word.length * index - 1.1;
                  _indocatorHidden = false;
                });
                widget.indexBarCallBack(_index_word[index]);
              }, //按住屏幕移动手指实时更新触摸的位置坐标

              onVerticalDragDown: (DragDownDetails details) {
                //globalPosition 自身坐标系
                int index = getIdex(context, details.globalPosition, _index_word);
                _indicatorText = _index_word[index];
                _indicatorY = 2.2 / _index_word.length * index - 1.1;
                _indocatorHidden = false;
                widget.indexBarCallBack(_index_word[index]);
                print('现在点击的位置是${details.globalPosition}');
                setState(() {
                  // if (_index_word[index] == _indicatorText) {
                  //   _index_color[index] =  AppColor.bgBlack;
                  // }
                });
              }, //触摸开始

              onVerticalDragEnd: (DragEndDetails details) {
                setState(() {
                  _indocatorHidden = true;
                  // _index_color.clear();
                  // for(var i = 0; i < _index_word.length;i++) {
                  //   _index_color.add(AppColor.textSecondary);
                  // }
                  // _textColor =  AppColor.textSecondary;
                }); //触摸结束
              },
            ) //这个是索引条
          ],
        ),
      ),
    );
  }
}

const INDEX_WORDS = [
  '🔍',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];
List<String> names = [
  'Lina',
  '菲儿',
  '安莉',
  '阿贵',
  '鞍山市',
  "13131",
  "!#%",
  '🔍',
  '马上就到吉安',
  'aw',
  'dasda',
  '先存着',
  '茁壮成长',
  '啦啦啦',
  '密密麻麻所',
  '了杜拉拉',
  '卡顿快速反馈',
  'uuu',
  '天通苑',
  '啪啪啪',
  '二位若无',
  '不是吧',
  'oooo',
  '你忙吧表空间和',
  '库',
  'UI',
  'IPO',
  'BNM',
  '我偶偶',
  '已已',
  '哦哦哦',
  '已',
  '应用于',
  '通天塔',
  '让人',
  '嗯嗯',
  '无误',
  '请求',
  '换行',
  '公告',
  '方法',
  '单独',
  '搜索',
  '啊啊',
  '种植',
  '消息',
  '传出',
  '不不v ',
  '不不不',
  '你你你',
  '你你你',
  '买买买',
  '了劳累过度',
  'AA制',
  '阿萨斯',
  '硕大的撒',
  '大概放电饭锅',
  '回复回复',
  '讲话稿几个'
];
