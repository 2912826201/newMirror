import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';

/// conversation_db_helper
/// Created by yangjiayi on 2020/11/30.

class ConversationDBHelper {
  Future<bool> insertConversation(ConversationDto conversation) async {
    // Database db = await DBHelper().openDB();
    //先删掉已有数据 再插入数据
    var transactionResult = await DBHelper.instance.db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_ID = '${conversation.id}'");
      var result = await txn.insert(TABLE_NAME_CONVERSATION, conversation.toMap());
      return result;
    });
    // await DBHelper().closeDB(db);
    return transactionResult > 0;
  }

  //这里正序查出即可 后续操作会倒序处理
  Future<List<ConversationDto>> queryConversation(int uid, int isTop) async {
    // Database db = await DBHelper().openDB();
    List<ConversationDto> list = [];
    List<Map<String, dynamic>> result = await DBHelper.instance.db.query(TABLE_NAME_CONVERSATION,
        where: "$COLUMN_NAME_CONVERSATION_UID = $uid and $COLUMN_NAME_CONVERSATION_ISTOP = $isTop",
        orderBy: "$COLUMN_NAME_CONVERSATION_UPDATETIME asc");
    for (Map<String, dynamic> map in result) {
      list.add(ConversationDto.fromMap(map));
    }

    // await DBHelper().closeDB(db);
    return list;
  }

  Future<void> clearConversation(int uid) async {
    // Database db = await DBHelper().openDB();
    await DBHelper.instance.db.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_UID = $uid");
    // await DBHelper().closeDB(db);
  }

  //批量插入数据
  Future<bool> insertConversationList(List<ConversationDto> conversations) async {
    // Database db = await DBHelper().openDB();
    int totalResult = 0;
    //先删掉已有数据 再插入数据
    var transactionResult = await DBHelper.instance.db.transaction((txn) async {
      conversations.forEach((conversation) async {
        //事务中只能用txn不能用db
        await txn.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_ID = '${conversation.id}'");
        var result = await txn.insert(TABLE_NAME_CONVERSATION, conversation.toMap());
        totalResult += result;
      });
      return totalResult;
    });
    // await DBHelper().closeDB(db);
    return (transactionResult == conversations.length);
  }

  //更新会话（可用于更新未读数，名称头像等确定已存在会话的信息）
  Future<bool> updateConversation(ConversationDto dto) async {
    // Database db = await DBHelper().openDB();
    int result = await DBHelper.instance.db
        .update(TABLE_NAME_CONVERSATION, dto.toMap(), where: "$COLUMN_NAME_CONVERSATION_ID = '${dto.id}'");
    // await DBHelper().closeDB(db);
    return result > 0;
  }
}
