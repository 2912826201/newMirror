import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedListDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnimatedListDemo();

}

class _AnimatedListDemo extends State<AnimatedListDemo> with SingleTickerProviderStateMixin {
  List<int> _list = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 10; i++) {
      _list.add(i);
    }
  }

  // void _addItem() {
  //   final int _index = _list.length;
  //   _list.insert(_index, _index);
  //   _listKey.currentState.insertItem(_index);
  // }

  void _removeItem() {
    print("进了");
    final int _index = _list.length - 1;
    var item = _list[_index].toString();
    _listKey.currentState.removeItem(_index, (context, animation) => _buildItem(item, animation));
    _list.removeAt(_index);
    print("出去了");
  }

  Widget _buildItem(String _item, Animation _animation) {
    return SizeTransition(
      sizeFactor: _animation,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            print("点击了）））））））））））））））");
            _removeItem();
          },
          child: Card(
            child: ListTile(
              title: Text(
                _item,
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _list.length,
        itemBuilder: (BuildContext context, int index, Animation animation) {
          return _buildItem(_list[index].toString(), animation);
        },
      ),
    );
  }
}
