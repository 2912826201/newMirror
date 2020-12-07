import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:sqflite/sqflite.dart';

/// conversation_db_helper
/// Created by yangjiayi on 2020/11/30.

class ConversationDBHelper {
  Future<bool> insertConversation(ConversationDto conversation) async {
    Database db = await DBHelper().openDB();
    //先删掉已有数据 再插入数据
    var transactionResult = await db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_ID = '${conversation.id}'");
      var result = await txn.insert(TABLE_NAME_CONVERSATION, conversation.toMap());
      return result;
    });
    await DBHelper().closeDB(db);
    return transactionResult == 1;
  }

  Future<List<ConversationDto>> queryConversation(int uid, int isTop) async {
    Database db = await DBHelper().openDB();
    List<ConversationDto> list = [];
    //只取第一条数据
    List<Map<String, dynamic>> result = await db.query(TABLE_NAME_CONVERSATION,
        where: "$COLUMN_NAME_CONVERSATION_UID = $uid and $COLUMN_NAME_CONVERSATION_ISTOP = $isTop",
        orderBy: "$COLUMN_NAME_CONVERSATION_UPDATETIME desc");
    for (Map<String, dynamic> map in result) {
      list.add(ConversationDto.fromMap(map));
    }

    await DBHelper().closeDB(db);
    return list;
  }

  Future<void> clearConversation(int uid) async {
    Database db = await DBHelper().openDB();
    await db.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_UID = $uid");
    await DBHelper().closeDB(db);
  }
  //批量插入数据
 Future<bool> insertConversations(List<ConversationDto> conversations) async{
   Database db = await DBHelper().openDB();
   List<bool> results = List<bool>();
   //先删掉已有数据 再插入数据
     var transactionResult = await db.transaction((txn) async {
       conversations.forEach((conversation)  async{
       //事务中只能用txn不能用db
       await txn.delete(TABLE_NAME_CONVERSATION, where: "$COLUMN_NAME_CONVERSATION_ID = '${conversation.id}'");
       var result = await txn.insert(TABLE_NAME_CONVERSATION, conversation.toMap());
       print("save single data ${result}");
       results.add(result == 1 ? true : false);
     });
       bool initial = false;
       results.forEach((element) {
         initial = initial & element;
       });
       return initial;
   });
   await DBHelper().closeDB(db);
   return (transactionResult == 1);
 }

}
