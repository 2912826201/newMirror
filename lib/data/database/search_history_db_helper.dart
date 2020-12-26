import 'package:mirror/data/dto/search_history_dto.dart';

import 'db_helper.dart';

/// search_history_db_helper
/// Created by yangjiayi on 2020/12/25.

class SearchHistoryDBHelper {
  Future<bool> insertSearchHistory(int uid, String word) async {
    SearchHistoryDto dto = SearchHistoryDto(DateTime.now().millisecondsSinceEpoch, uid, word);
    //同样的用户和搜索词不能重复 所以删掉之前的相同数据 插入新的
    var transactionResult = await DBHelper.instance.db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_SEARCHHISTORY,
          where: "$COLUMN_NAME_SEARCHHISTORY_UID = $uid and $COLUMN_NAME_SEARCHHISTORY_WORD = $word");
      var result = await txn.insert(TABLE_NAME_SEARCHHISTORY, dto.toMap());
      return result;
    });
    return transactionResult > 0;
  }

  Future<List<SearchHistoryDto>> querySearchHistory(int uid) async {
    List<SearchHistoryDto> list = [];

    List<Map<String, dynamic>> result = await DBHelper.instance.db.query(TABLE_NAME_SEARCHHISTORY,
        where: "$COLUMN_NAME_SEARCHHISTORY_UID = $uid", limit: 10, orderBy: "$COLUMN_NAME_SEARCHHISTORY_ID desc");
    for (Map<String, dynamic> map in result) {
      list.add(SearchHistoryDto.fromMap(map));
    }
    return list;
  }

  Future<void> clearSearchHistory(int uid) async {
    await DBHelper.instance.db.delete(TABLE_NAME_SEARCHHISTORY, where: "$COLUMN_NAME_SEARCHHISTORY_UID = $uid");
  }
}
