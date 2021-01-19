/// list_model
/// Created by yangjiayi on 2021/1/19.

class ListModel<T> {
  int hasNext;
  int lastTime;
  int lastId;
  int lastScore;
  int totalPage;
  int totalCount;
  List<T> list;
}