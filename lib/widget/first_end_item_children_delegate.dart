import 'package:flutter/cupertino.dart';

typedef FirstEndCallback = void Function(int firstIndex, int lastIndex);

/// 继承SliverChildBuilderDelegate  可以对列表的监听
class FirstEndItemChildrenDelegate extends SliverChildBuilderDelegate {
  FirstEndCallback firstEndCallback;

  FirstEndItemChildrenDelegate(
    Widget Function(BuildContext, int) builder, {
    int childCount,
    this.firstEndCallback,
    bool addAutomaticKeepAlive = true,
    bool addRepaintBoundaries = true,
  }) : super(builder,
            childCount: childCount,
            addAutomaticKeepAlives: addAutomaticKeepAlive,
            addRepaintBoundaries: addRepaintBoundaries);

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    if (firstEndCallback != null) {
      firstEndCallback(firstIndex, lastIndex);
    }
  }

  ///可不重写 重写不能为null  默认是true  添加进来的实例与之前的实例是否相同 相同返回true 反之false
  ///listView 暂时没有看到应用场景 源码中使用在 SliverFillViewport 中
  @override
  bool shouldRebuild(SliverChildBuilderDelegate oldDelegate) {
    return super.shouldRebuild(oldDelegate);
  }
}
