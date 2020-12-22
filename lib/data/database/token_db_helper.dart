import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:sqflite/sqflite.dart';

/// token_db_helper
/// Created by yangjiayi on 2020/11/23.

class TokenDBHelper {
  Future<bool> insertToken(TokenDto token) async {
    // Database db = await DBHelper().openDB();
    //因为此表只存当前用户自己的数据 所以插入数据前先清掉表中所有数据
    var transactionResult = await DBHelper.instance.db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_TOKEN);
      var result = await txn.insert(TABLE_NAME_TOKEN, token.toMap());
      return result;
    });
    // await DBHelper().closeDB(db);
    return transactionResult == 1;
  }

  Future<TokenDto> queryToken() async {
    // Database db = await DBHelper().openDB();
    TokenDto token;
    //只取第一条数据
    List<Map<String, dynamic>> result = await DBHelper.instance.db.query(TABLE_NAME_TOKEN, limit: 1);
    if (result.isNotEmpty) {
      token = TokenDto.fromMap(result.first);
    }
    // await DBHelper().closeDB(db);
    return token;
  }
}
