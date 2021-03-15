import 'dart:collection';

/// lru_list
/// Created by sl on 2021/3/13.
class LruList<T> {
  // 存储最大长度 现在设置的1000条
  final int maxLength;
  Queue<T> _list = new Queue();

  LruList({this.maxLength});

  bool contains(T element) {
    return _list.contains(element);
  }

  void add(T element) {
    if (_list.length >= maxLength - 1) {
      _list.removeFirst();
    }
    _list.addLast(element);
  }
  // Sl添加
  void clear() {
    _list.clear();
  }
  int length() {
    return _list.length;
  }
}
