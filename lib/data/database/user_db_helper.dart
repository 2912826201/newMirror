import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/user_dto.dart';
import 'package:sqflite/sqflite.dart';

/// user_db_helper
/// Created by yangjiayi on 2020/11/3.

class UserDBHelper {
  Future<int> insertUser(UserDto user) async {
    Database db = await DBHelper().openDB();
    //因为此表只存当前用户自己的数据 所以插入数据前先清掉表中所有数据
    user.uid = await db.transaction((txn) async {
      //事务中只能用txn不能用db
      await txn.delete(TABLE_NAME_USER);
      var result = await txn.insert(TABLE_NAME_USER, user.toMap());
      return result;
    });
    await DBHelper().closeDB(db);
    return user.uid;
  }

  Future<UserDto> queryUser() async {
    Database db = await DBHelper().openDB();
    UserDto user;
    //只取第一条数据
    List<Map<String, dynamic>> result = await db.query(TABLE_NAME_USER, limit: 1);
    if (result.isNotEmpty) {
      user = UserDto.fromMap(result.first);
    }
    await DBHelper().closeDB(db);
    return user;
  }
}
